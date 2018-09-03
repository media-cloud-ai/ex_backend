defmodule ExBackendWeb.BrowserChannel do
  use Phoenix.Channel
  require Logger
  alias ExBackend.Watchers
  alias ExBackendWeb.Presence
  alias ExBackend.Workflows
  alias ExBackend.WorkflowStep
  alias ExBackend.Workflows.Workflow

  intercept([
    "file_system",
    "reply_info"
  ])

  def join("browser:all", message, socket) do
    if not Enum.empty?(message) do
      send(self(), {:after_join, message})
    end

    {:ok, socket |> assign(:topics, [%{test: "lol"}])}
  end

  def join("browser:notification", message, socket) do
    watchers = Watchers.list_watchers(message)

    watcher =
      case watchers.total do
        0 ->
          {:ok, watcher} = Watchers.create_watcher(message)
          watcher

        _ ->
          watchers.data
          |> List.first()
      end

    body = %{
      id: watcher.id,
      identifier: watcher.identifier
    }

    body =
      if watcher.last_event == nil do
        body
      else
        Map.put(body, :last_event, watcher.last_event)
      end

    ExBackendWeb.Endpoint.broadcast!("browser:notification", "creation", body)
    {:ok, socket}
    # {:ok, socket |> assign(:topics, [%{test: "lol"}])}
  end

  def join("browser:" <> _kind, _params, _socket) do
    {:error, %{reason: "unknown"}}
  end

  def handle_info({:after_join, message}, socket) do
    push(socket, "presence_state", Presence.list(socket))

    {:ok, _} =
      Presence.track(socket, socket.assigns.user_id, %{
        online_at: inspect(System.system_time(:seconds)),
        message: message
      })

    {:noreply, socket}
  end

  def handle_in("get_info", %{"identifier" => identifier}, socket) do
    Logger.debug("-> IN message for identifier: #{inspect(identifier)}")

    watchers = Watchers.list_watchers(%{identifier: identifier})

    if watchers.total == 1 do
      watcher =
        watchers
        |> Map.get(:data)
        |> List.first()

      watcher = %{
        id: watcher.id,
        identifier: watcher.identifier,
        last_event: watcher.last_event
      }

      ExBackendWeb.Endpoint.broadcast!("browser:notification", "reply_info", watcher)
    end

    {:noreply, socket}
  end

  def handle_in("response", payload, socket) do
    # Logger.info("list path #{inspect(payload)}")
    ExBackendWeb.Endpoint.broadcast!("watch:all", "pouet", payload)
    {:noreply, socket}
  end

  def handle_in(
        "new_item",
        %{"date_time" => date_time, "output_filename" => filename} = _payload,
        %{assigns: %{identifier: identifier}} = socket
      ) do
    Logger.info("new item #{identifier} / #{date_time}: #{filename}")
    watchers = Watchers.list_watchers(%{identifier: identifier})

    if watchers.total == 1 do
      steps = ExBackend.Workflow.Definition.EbuIngest.get_definition(identifier, filename)

      workflow_params = %{
        reference: filename,
        flow: steps
      }

      case Workflows.create_workflow(workflow_params) do
        {:ok, %Workflow{} = workflow} ->
          WorkflowStep.start_next_step(workflow)

          ExBackendWeb.Endpoint.broadcast!("notifications:all", "new_workflow", %{
            body: %{workflow_id: workflow.id}
          })

          Logger.info("workflow created: #{inspect(workflow)}")

          watcher =
            watchers
            |> Map.get(:data)
            |> List.first()

          Watchers.update_watcher(watcher, %{last_event: date_time})

        {:error, changeset} ->
          Logger.error("unable to start workflow: #{inspect(changeset)}")
      end
    end

    {:noreply, socket}
  end

  def handle_in("new_item", payload, socket) do
    Logger.error("unsupported new item: #{inspect(payload)}")
    {:noreply, socket}
  end

  def handle_out("reply_info", payload, %{assigns: %{identifier: identifier}} = socket) do
    Logger.debug(">- OUT message #{inspect(payload)} // #{inspect(identifier)}")

    if identifier == payload.identifier do
      push(socket, "reply_info", payload)
    end

    {:noreply, socket}
  end

  def handle_out("file_system", payload, %{assigns: %{identifier: identifier}} = socket) do
    Logger.debug(">- OUT message #{inspect(payload)}")

    if identifier == payload.body.agent do
      push(socket, "file_system", payload)
    end

    {:noreply, socket}
  end
end

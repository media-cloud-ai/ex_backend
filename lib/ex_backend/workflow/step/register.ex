defmodule ExBackend.Workflow.Step.Register do
  alias ExBackend.Jobs
  alias ExBackend.Workflow.Step.Requirements

  require Logger

  @action_name "register"

  def launch(workflow, step) do
    job_params = %{
      name: @action_name,
      step_id: ExBackend.Map.get_by_key_or_atom(step, :id),
      workflow_id: workflow.id,
      params: %{}
    }

    {:ok, job} = Jobs.create_job(job_params)

    try do
      case register(workflow, step) do
        {:ok, _} ->
          Jobs.Status.set_job_status(job.id, "completed")
          {:ok, "completed"}

        {:error, message} ->
          Jobs.Status.set_job_status(job.id, "error", %{
            message: "unable to register: #{message}"
          })

          {:error, message}
      end
    rescue
      error ->
        Logger.error("#{__MODULE__} raised: #{inspect(error)}")
        Jobs.Status.set_job_status(job.id, "error", %{message: "unable to register"})
        {:error, "unable to register"}
    end
  end

  defp register(workflow, step) do
    params =
      ExBackend.Map.get_by_key_or_atom(step, :parameters, [])
      |> Enum.filter(fn param ->
        ExBackend.Map.get_by_key_or_atom(param, :id) in ["extensions", "name", "type", "language"]
      end)
      |> Enum.map(fn param ->
        %{
          ExBackend.Map.get_by_key_or_atom(param, :id) =>
            ExBackend.Map.get_by_key_or_atom(param, :value)
        }
      end)
      |> Enum.reduce(%{}, fn param, acc -> Map.merge(acc, param) end)

    extensions = ExBackend.Map.get_by_key_or_atom(params, :extensions, [])
    language = ExBackend.Map.get_by_key_or_atom(params, :language)
    name = ExBackend.Map.get_by_key_or_atom(params, :name)
    type = ExBackend.Map.get_by_key_or_atom(params, :type)

    paths =
      Requirements.get_source_files(workflow.jobs, step)
      |> Enum.filter(fn path -> String.ends_with?(path, extensions |> String.split(",")) end)

    insert(workflow.id, type, language, name, paths)
  end

  defp insert(_workflow_id, _type, _language, nil, _paths) do
    {:error, "unable to register, missing name"}
  end

  defp insert(_workflow_id, "subtitle", nil, _name, _paths) do
    {:error, "unable to register, missing language and name"}
  end

  defp insert(workflow_id, "subtitle", language, name, paths) do
    items =
      ExBackend.Registeries.list_registeries(%{"workflow_id" => workflow_id, "name" => name})
      |> Map.get(:data)

    case items do
      [] ->
        ExBackend.Registeries.create_registery(%{
          workflow_id: workflow_id,
          name: name,
          params: %{
            "subtitles": [
              %{
                language: language,
                paths: paths
              }
            ]
          }
        })

      items ->
        item = List.first(items)

        params =
          Map.get(item, :params)
          |> Map.merge(%{
            "subtitles": [
              %{
                language: language,
                paths: paths
              }
            ]
          })

        ExBackend.Registeries.update_registery(item, %{
          params: params
        })
    end

    {:ok, %{}}
  end

  defp insert(workflow_id, "manifest_dash", _language, name, paths) do
    items =
      ExBackend.Registeries.list_registeries(%{"workflow_id" => workflow_id, "name" => name})
      |> Map.get(:data)

    case items do
      [] ->
        ExBackend.Registeries.create_registery(%{
          workflow_id: workflow_id,
          name: name,
          params: %{
            "manifests": [
              %{
                format: "dash",
                paths: paths
              }
            ]
          }
        })

      items ->
        item = List.first(items)

        params =
          Map.get(item, :params)
          |> Map.merge(%{
            "manifests": [
              %{
                format: "dash",
                paths: paths
              }
            ]
          })

        ExBackend.Registeries.update_registery(item, %{
          params: params
        })
    end
    {:ok, %{}}
  end

  defp insert(_workflow_id, _type, _language, _name, _paths) do
    {:error, "unable to register, missing parameters"}
  end
end

defmodule ExBackendWeb.FileTransferChannel do
  use Phoenix.Channel
  require Logger
  alias ExBackend.Jobs

  intercept([
    "start"
  ])

  def join("transfer:upload", _message, socket) do
    {:ok, socket}
  end

  def join("transfer:" <> _kind, _params, _socket) do
    {:error, %{reason: "unknown"}}
  end

  def handle_in("upload_data", _payload, socket) do
    Logger.info("upload_packet")
    {:noreply, socket}
  end

  def handle_in("upload_completed", %{"job_id" => job_id} = payload, socket) do
    Logger.warn("upload completed for job id: #{job_id}")
    Jobs.Status.set_job_status(job_id, "completed")

    ExBackend.WorkflowStepManager.check_step_status(%{job_id: job_id})
    {:noreply, socket}
  end

  def handle_in("upload_error", %{"job_id" => job_id, "message" => description}, socket) do
    Logger.warn("upload error for job id #{job_id}: #{description}")
    Jobs.Status.set_job_status(job_id, "error", %{message: description})

    {:noreply, socket}
  end

  def handle_out("start", payload, %{assigns: %{identifier: identifier}} = socket) do
    Logger.info(">- OUT #{__MODULE__} start message #{inspect(payload)}")

    if identifier == payload.parameters.source.agent do
      push(socket, "start", payload)
    end

    {:noreply, socket}
  end
end

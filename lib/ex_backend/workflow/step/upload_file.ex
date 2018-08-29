defmodule ExBackend.Workflow.Step.UploadFile do
  alias ExBackend.Jobs
  alias ExBackend.Workflow.Step.Requirements

  @action_name "upload_file"

  def launch(workflow, step) do
    current_date =
      Timex.now()
      |> Timex.format!("%Y_%m_%d__%H_%M_%S", :strftime)

    case ExBackend.Map.get_by_key_or_atom(step, :inputs) do
      nil ->
        Jobs.create_skipped_job(workflow, @action_name)
      inputs ->
        start_upload(inputs, current_date, workflow)
    end
  end

  defp start_upload([], _current_date, _workflow), do: {:ok, "started"}
  defp start_upload([input | inputs], current_date, workflow) do
    job_params = %{
      name: @action_name,
      workflow_id: workflow.id,
      params: %{
        source: %{
          path: Map.get(input, "path"),
          agent: Map.get(input, "agent")
        },
        destination: %{
          path: "/tmp/dude/test.mp4"
        }
      }
    }

    {:ok, job} = Jobs.create_job(job_params)

    params = %{
      job_id: job.id,
      parameters: job.params
    }

    ExBackendWeb.Endpoint.broadcast!("transfer:upload", "start", params)

    start_upload(inputs, current_date, workflow)
  end
end

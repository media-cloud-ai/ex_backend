defmodule ExBackend.Workflow.Step.UploadFile do
  alias ExBackend.Jobs

  @action_name "upload_file"

  def launch(workflow, step) do
    current_date =
      Timex.now()
      |> Timex.format!("%Y_%m_%d__%H_%M_%S", :strftime)

    case ExBackend.Map.get_by_key_or_atom(step, :inputs) do
      nil ->
        Jobs.create_skipped_job(
          workflow,
          ExBackend.Map.get_by_key_or_atom(step, :id),
          @action_name
        )

      inputs ->
        start_upload(inputs, current_date, step, workflow)
    end
  end

  defp start_upload([], _current_date, _step, _workflow), do: {:ok, "started"}

  defp start_upload([input | inputs], current_date, step, workflow) do
    work_dir = System.get_env("WORK_DIR") || Application.get_env(:ex_backend, :work_dir)

    input_filename = Map.get(input, "path") || input.path
    agent = Map.get(input, "agent") || input.agent

    filename = input_filename |> Path.basename()
    output_filename = "#{work_dir}/#{workflow.id}/#{filename}"

    parameters = [
      %{
        "id" => "source_path",
        "type" => "string",
        "value" => input_filename
      },
      %{
        "id" => "source_agent",
        "type" => "string",
        "value" => agent
      },
      %{
        "id" => "destination_path",
        "type" => "string",
        "value" => output_filename
      }
    ]

    job_params = %{
      name: @action_name,
      step_id: ExBackend.Map.get_by_key_or_atom(step, :id),
      workflow_id: workflow.id,
      parameters: parameters
    }

    {:ok, job} = Jobs.create_job(job_params)

    params = %{
      job_id: job.id,
      parameters: %{
        source: %{
          path: input_filename,
          agent: agent
        },
        destination: %{
          path: output_filename
        }
      }
    }

    ExBackendWeb.Endpoint.broadcast!("transfer:upload", "start", params)

    start_upload(inputs, current_date, step, workflow)
  end
end

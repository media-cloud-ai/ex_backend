defmodule ExBackend.Workflow.Step.TtmlToMp4 do
  alias ExBackend.Jobs
  alias ExBackend.Amqp.CommonEmitter
  alias ExBackend.Workflow.Step.Requirements

  @action_name "ttml_to_mp4"

  def launch(workflow, step) do
    step_id = ExBackend.Map.get_by_key_or_atom(step, :id)

    ExBackend.Workflow.Step.Requirements.get_source_files(workflow.jobs, step)
    |> case do
      [] ->
        Jobs.create_skipped_job(workflow, step_id, @action_name)

      paths ->
        start_process(paths, workflow, step, step_id)
    end
  end

  defp start_process([], _workflow, _step, _step_id), do: {:ok, "started"}

  defp start_process([nil | paths], workflow, step, step_id) do
    start_process(paths, workflow, step, step_id)
  end

  defp start_process([path | paths], workflow, step, step_id) do
    mp4_path = String.replace(path, ".ttml", ".mp4")
    requirements = Requirements.add_required_paths(path)


    parameters =
      ExBackend.Map.get_by_key_or_atom(step, :parameters, []) ++ [
        %{
          "id" => "action",
          "type" => "string",
          "value" => @action_name
        },
        %{
          "id" => "source_path",
          "type" => "string",
          "value" => path
        },
        %{
          "id" => "destination_path",
          "type" => "string",
          "value" => mp4_path
        },
        %{
          "id" => "requirements",
          "type" => "requirements",
          "value" => requirements
        }
      ]


    job_params = %{
      name: @action_name,
      step_id: step_id,
      workflow_id: workflow.id,
      params: %{list: parameters}
    }

    {:ok, job} = Jobs.create_job(job_params)

    params = %{
      job_id: job.id,
      parameters: job.params.list
    }

    case CommonEmitter.publish_json("job_gpac", params) do
      :ok -> start_process(paths, workflow, step, step_id)
      _ -> {:error, "unable to publish message"}
    end
  end
end

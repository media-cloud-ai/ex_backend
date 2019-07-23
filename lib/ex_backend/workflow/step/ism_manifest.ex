defmodule ExBackend.Workflow.Step.IsmManifest do
  alias ExBackend.Jobs
  alias ExBackend.Amqp.CommonEmitter
  alias ExBackend.Workflow.Step.Requirements

  @action_name "ism_manifest"

  def launch(workflow, step) do
    step_id = ExBackend.Map.get_by_key_or_atom(step, :id)

    ExBackend.Workflow.Step.Requirements.get_source_files(workflow.jobs, step)
    |> case do
      [] ->
        Jobs.create_skipped_job(workflow, step_id, @action_name)

      paths ->
        manifest_path =
          Enum.filter(paths, fn path -> String.ends_with?(path, ".ism") end)
          |> List.last()

        if manifest_path == nil do
          Jobs.create_skipped_job(workflow, step_id, @action_name)
        else
          analyse_ism_manifest(workflow, step, step_id, manifest_path)
        end
    end
  end

  def analyse_ism_manifest(workflow, step, step_id, manifest_path) do
    requirements = Requirements.add_required_paths([manifest_path])

    parameters =
      ExBackend.Map.get_by_key_or_atom(step, :parameters, []) ++
        [
          %{
            "id" => "source_path",
            "type" => "string",
            "value" => manifest_path
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
      parameters: parameters
    }


    {:ok, job} = Jobs.create_job(job_params)

    message = Jobs.get_message(job)

    case CommonEmitter.publish_json("job_ism_manifest", message) do
      :ok -> {:ok, "started"}
      _ -> {:error, "unable to publish message"}
    end
  end
end

defmodule ExBackend.Workflow.Step.DashManifest do
  alias ExBackend.Jobs
  alias ExBackend.Amqp.CommonEmitter
  alias ExBackend.Workflow.Step.Requirements

  @action_name "dash_manifest"

  def launch(workflow, step) do
    step_id = ExBackend.Map.get_by_key_or_atom(step, :id)

    ExBackend.Workflow.Step.Requirements.get_source_files(workflow.jobs, step)
    |> case do
      [] ->
        Jobs.create_skipped_job(workflow, step_id, @action_name)

      paths ->
        ttml_path =
          Enum.filter(paths, fn path -> String.ends_with?(path, ".ttml") end) |> List.last()

        manifest_path =
          Enum.filter(paths, fn path -> String.ends_with?(path, ".mpd") end) |> List.last()

        requirements = Requirements.add_required_paths([ttml_path, manifest_path])

        parameters =
          ExBackend.Map.get_by_key_or_atom(step, :parameters, []) ++
            [
              %{
                "id" => "manifest_path",
                "type" => "string",
                "value" => manifest_path
              },
              %{
                "id" => "destination_path",
                "type" => "string",
                "value" => manifest_path
              },
              %{
                "id" => "ttml_path",
                "type" => "string",
                "value" => ttml_path
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

        case CommonEmitter.publish_json("job_dash_manifest", params) do
          :ok -> {:ok, "started"}
          _ -> {:error, "unable to publish message"}
        end
    end
  end
end

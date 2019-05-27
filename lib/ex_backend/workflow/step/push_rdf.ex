defmodule ExBackend.Workflow.Step.PushRdf do
  alias ExBackend.Jobs

  alias ExBackend.Amqp.CommonEmitter
  alias ExBackend.Workflow.Step.Requirements
  require Logger

  @action_name "push_rdf"

  def launch(workflow, step) do
    sources = Requirements.get_source_files(workflow.jobs, step)

    parameters =
      ExBackend.Map.get_by_key_or_atom(step, :parameters, []) ++
        [
          %{
            "id" => "reference",
            "type" => "string",
            "value" => workflow.reference
          },
          %{
            "id" => "input_paths",
            "type" => "array_of_strings",
            "value" => sources
          }
        ]

    job_params = %{
      name: @action_name,
      step_id: ExBackend.Map.get_by_key_or_atom(step, :id),
      workflow_id: workflow.id,
      params: %{list: parameters}
    }

    {:ok, job} = Jobs.create_job(job_params)

    params = %{
      job_id: job.id,
      parameters: job.params.list
    }

    case CommonEmitter.publish_json("job_rdf", params) do
      :ok -> {:ok, "started"}
      _ -> {:error, "unable to publish message"}
    end
  end
end

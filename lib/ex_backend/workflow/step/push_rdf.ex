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
      parameters: parameters
    }

    {:ok, job} = Jobs.create_job(job_params)

    message = Jobs.get_message(job)

    case CommonEmitter.publish_json("job_rdf", message) do
      :ok -> {:ok, "started"}
      _ -> {:error, "unable to publish message"}
    end
  end
end

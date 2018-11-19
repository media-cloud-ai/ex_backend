defmodule ExBackend.Workflow.Step.PushRdf do
  alias ExBackend.Jobs

  alias ExBackend.Amqp.JobRdfEmitter
  require Logger

  @action_name "push_rdf"

  def launch(workflow, step) do
    parameters =
      Map.get(step, "parameters")
      |> List.insert_at(-1, %{
        "id" => "reference",
        "type" => "string",
        "value" => workflow.reference
      })

    job_params = %{
      name: @action_name,
      step_id: ExBackend.Map.get_by_key_or_atom(step, :id),
      workflow_id: workflow.id,
      params: %{ list: parameters }
    }

    {:ok, job} = Jobs.create_job(job_params)

    params = %{
      job_id: job.id,
      parameters: job.params.list
    }

    JobRdfEmitter.publish_json(params)
    {:ok, "started"}
  end
end

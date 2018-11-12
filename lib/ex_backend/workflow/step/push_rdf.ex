defmodule ExBackend.Workflow.Step.PushRdf do
  alias ExBackend.Jobs

  alias ExBackend.Amqp.JobRdfEmitter
  require Logger

  @action_name "push_rdf"

  def launch(workflow, step) do
    job_params = %{
      name: @action_name,
      step_id: ExBackend.Map.get_by_key_or_atom(step, :id),
      workflow_id: workflow.id,
      params: %{
        reference: workflow.reference
      }
    }

    {:ok, job} = Jobs.create_job(job_params)

    params = %{
      job_id: job.id,
      parameters: job.params
    }

    JobRdfEmitter.publish_json(params)
    {:ok, "started"}
  end
end

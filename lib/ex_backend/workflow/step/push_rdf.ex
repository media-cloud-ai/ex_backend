defmodule ExBackend.Workflow.Step.PushRdf do
  alias ExBackend.Jobs

  alias ExBackend.Rdf.Converter
  alias ExBackend.Rdf.PerfectMemory
  require Logger

  @action_name "push_rdf"

  def launch(workflow) do
    job_params = %{
      name: @action_name,
      workflow_id: workflow.id,
      params: %{}
    }
    {:ok, job} = Jobs.create_job(job_params)

    try do
      case convert_and_submit(workflow) do
        {:ok, _} ->
          Jobs.Status.set_job_status(job.id, "completed")
          {:ok, "completed"}
        {:error, message} ->
          Jobs.Status.set_job_status(job.id, "error", %{message: "unable to publish RDF: #{message}"})
          {:error, message}
      end
    rescue
      error ->
        Logger.error "publish rdf raised: #{error}"
        Jobs.Status.set_job_status(job.id, "error", %{message: "unable to publish RDF"})
        {:error, "unable to publish RDF"}
    end
  end

  def convert_and_submit(workflow) do
    r = Converter.get_rdf(workflow.reference) |> IO.inspect
    case r do
      {:ok, rdf} -> PerfectMemory.publish_rdf(rdf)
      {:error, message} -> {:error, message}
    end
  end
end

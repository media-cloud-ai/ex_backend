defmodule ExSubtilBackend.WorkflowStepManager do
  require Logger

  use GenServer
  alias ExSubtilBackend.Repo
  alias ExSubtilBackend.WorkflowStep

  def init(args) do
    {:ok, args}
  end

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def check_step_status(message) do
    GenServer.cast(__MODULE__, {:check_step_status, message})
  end

  def handle_cast({:check_step_status, %{job_id: job_id}}, state) do
    Logger.warn("#{__MODULE__}: check for job #{job_id}")

    job = ExSubtilBackend.Jobs.get_job!(job_id)

    topic = "update_workflow_" <> Integer.to_string(job.workflow_id)

    ExSubtilBackendWeb.Endpoint.broadcast!("notifications:all", topic, %{
      body: %{workflow_id: job.workflow_id}
    })

    if ExSubtilBackend.Workflows.jobs_without_status?(job.workflow_id) == true do
      job = Repo.preload(job, :workflow)
      WorkflowStep.start_next_step(job.workflow)
    end

    {:noreply, state}
  end

  def handle_cast({:check_step_status, message}, state) do
    Logger.error("#{__MODULE__}: unable to handle message: #{inspect(message)}")
    {:noreply, state}
  end
end

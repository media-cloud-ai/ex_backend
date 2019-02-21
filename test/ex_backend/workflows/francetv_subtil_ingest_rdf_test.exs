defmodule ExBackend.FrancetvSubtilIngestRdfTest do
  use ExBackendWeb.ConnCase

  alias ExBackend.Workflows
  alias ExBackend.WorkflowStep
  require Logger

  setup do
    channel = ExBackend.HelpersTest.get_amqp_connection()

    on_exit fn ->
      ExBackend.HelpersTest.consume_messages(channel, "job_rdf", 1)
    end
    :ok
  end

  describe "francetv_subtil_ingest_dash_workflow" do
    test "il etait une fois la vie" do
      steps = ExBackend.Workflow.Definition.FrancetvSubtilRdfIngest.get_definition()

      workflow_params = %{
        reference: "99787afd-ba2d-410f-b03e-66cf2efb3ed5",
        flow: steps
      }

      {:ok, workflow} = Workflows.create_workflow(workflow_params)

      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      ExBackend.HelpersTest.check(workflow.id, 1)
      ExBackend.HelpersTest.check(workflow.id, "push_rdf", 1)

      ExBackend.HelpersTest.complete_jobs(workflow.id, "push_rdf")
      {:ok, "completed"} = WorkflowStep.start_next_step(workflow)
    end
  end
end

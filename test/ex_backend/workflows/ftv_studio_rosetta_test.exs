defmodule ExBackend.FtvStudioRosettaTest do
  use ExBackendWeb.ConnCase

  alias ExBackend.Workflows
  alias ExBackend.WorkflowStep

  require Logger

  setup do
    channel = ExBackend.HelpersTest.get_amqp_connection()

    on_exit(fn ->
      destination_paths = 
        ExBackend.HelpersTest.consume_messages(channel, "job_ftp", 3)
        |> Enum.map(fn job ->
          Map.get(job, "parameters")
          |> Enum.filter(fn p -> Map.get(p, "id") == "destination_path" end)
          |> Enum.map(fn p ->
            Map.get(p, "value")
          end)
          |> List.first
        end)

      assert String.starts_with?(Enum.at(destination_paths, 0), "/data/")
      assert String.ends_with?(Enum.at(destination_paths, 0), "/path.mp4")
      assert String.starts_with?(Enum.at(destination_paths, 1), "666/")
      assert String.ends_with?(Enum.at(destination_paths, 1), "/path.mp4")
      assert String.starts_with?(Enum.at(destination_paths, 2), "666/")
      assert String.ends_with?(Enum.at(destination_paths, 2), "/path.ttml")

      ExBackend.HelpersTest.consume_messages(channel, "job_http", 1)
      ExBackend.HelpersTest.consume_messages(channel, "job_file_system", 1)
    end)

    :ok
  end

  describe "francetv_subtil_acs_workflow" do
    test "bad id" do
      steps =
        ExBackend.Workflow.Definition.FtvStudioRosetta.get_definition(
          ["ftp://source/path.mp4"],
          "http://static/source/path.ttml"
        )

      workflow_params = %{
        reference: "666",
        flow: steps
      }

      {:ok, workflow} = Workflows.create_workflow(workflow_params)
      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      ExBackend.HelpersTest.check(workflow.id, 1)
      ExBackend.HelpersTest.check(workflow.id, "download_ftp", 1)
      ExBackend.HelpersTest.complete_jobs(workflow.id, "download_ftp")

      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      ExBackend.HelpersTest.check(workflow.id, 2)
      ExBackend.HelpersTest.check(workflow.id, "download_http", 1)
      ExBackend.HelpersTest.complete_jobs(workflow.id, "download_http")

      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      ExBackend.HelpersTest.check(workflow.id, 4)
      ExBackend.HelpersTest.check(workflow.id, "upload_ftp", 2)
      ExBackend.HelpersTest.complete_jobs(workflow.id, "upload_ftp")

      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      ExBackend.HelpersTest.check(workflow.id, 5)
      ExBackend.HelpersTest.check(workflow.id, "download_ftp", 1)
      ExBackend.HelpersTest.check(workflow.id, "download_http", 1)
      ExBackend.HelpersTest.check(workflow.id, "upload_ftp", 2)
      ExBackend.HelpersTest.check(workflow.id, "clean_workspace", 1)

      {:ok, "completed"} = WorkflowStep.start_next_step(workflow)
      ExBackend.HelpersTest.check(workflow.id, 5)
    end
  end
end

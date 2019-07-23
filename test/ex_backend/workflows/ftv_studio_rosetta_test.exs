defmodule ExBackend.FtvStudioRosettaTest do
  use ExBackendWeb.ConnCase

  alias ExBackend.Workflows
  alias ExBackend.WorkflowStep

  require Logger

  setup do
    channel = ExBackend.HelpersTest.get_amqp_connection()

    on_exit(fn ->
      destination_paths =
        ExBackend.HelpersTest.consume_messages(channel, "job_ftp", 4)
        |> Enum.map(fn job ->
          Map.get(job, "parameters")
          |> Enum.filter(fn p -> Map.get(p, "id") == "destination_path" end)
          |> Enum.map(fn p ->
            Map.get(p, "value")
          end)
          |> List.first()
        end)

      assert String.starts_with?(Enum.at(destination_paths, 0), "/data/")
      assert String.ends_with?(Enum.at(destination_paths, 0), "/path.mp4")
      assert String.starts_with?(Enum.at(destination_paths, 1), "/data/")
      assert String.ends_with?(Enum.at(destination_paths, 1), "/path.ttml")

      assert Enum.at(destination_paths, 2) ==
               "F2/Un-jour-un-destin/20190220_2243/F2_20190220_2243_Un-jour-un-destin_Karl-Lagerfeld-etre-et-paraitre.mp4"

      assert Enum.at(destination_paths, 3) ==
               "F2/Un-jour-un-destin/20190220_2243/F2_20190220_2243_Un-jour-un-destin_Karl-Lagerfeld-etre-et-paraitre.ttml"

      ExBackend.HelpersTest.consume_messages(channel, "job_file_system", 1)
    end)

    :ok
  end

  describe "francetv_studio_rosetta_workflow" do
    test "bad id" do
      output_pattern =
        "F2/Un-jour-un-destin/20190220_2243/F2_20190220_2243_Un-jour-un-destin_Karl-Lagerfeld-etre-et-paraitre#input_extension"

      workflow_params =
        ExBackend.Workflow.Definition.FtvStudioRosetta.get_definition_for_akamai_input(
          ["ftp://source/path.mp4"],
          "http://static/source/path.ttml",
          output_pattern,
          "/prefix"
        )
        |> Map.put(:reference, "39984e00-055c-4aa8-902c-1d6cab12d2da")

      {:ok, workflow} = Workflows.create_workflow(workflow_params)
      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      ExBackend.HelpersTest.check(workflow.id, 1)
      ExBackend.HelpersTest.check(workflow.id, "download_ftp", 1)
      ExBackend.HelpersTest.complete_jobs(workflow.id, "download_ftp")

      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      ExBackend.HelpersTest.check(workflow.id, 2)
      ExBackend.HelpersTest.check(workflow.id, "download_ftp", 2)
      ExBackend.HelpersTest.complete_jobs(workflow.id, "download_ftp")

      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      ExBackend.HelpersTest.check(workflow.id, 4)
      ExBackend.HelpersTest.check(workflow.id, "upload_ftp", 2)
      ExBackend.HelpersTest.complete_jobs(workflow.id, "upload_ftp")

      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      ExBackend.HelpersTest.check(workflow.id, 5)
      ExBackend.HelpersTest.check(workflow.id, "download_ftp", 2)
      ExBackend.HelpersTest.check(workflow.id, "upload_ftp", 2)
      ExBackend.HelpersTest.check(workflow.id, "clean_workspace", 1)

      {:ok, "completed"} = WorkflowStep.start_next_step(workflow)
      ExBackend.HelpersTest.check(workflow.id, "download_ftp", 2)
      ExBackend.HelpersTest.check(workflow.id, "upload_ftp", 2)
      ExBackend.HelpersTest.check(workflow.id, "clean_workspace", 1)
      ExBackend.HelpersTest.check(workflow.id, "send_notification", 1)
      ExBackend.HelpersTest.check(workflow.id, 6)
    end
  end
end

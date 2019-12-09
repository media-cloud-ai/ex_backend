defmodule ExBackend.FtvStudioRosettaTest do
  use ExBackendWeb.ConnCase

  alias StepFlow.Step
  alias StepFlow.Workflows

  require Logger

  setup do
    channel = ExBackend.HelpersTest.get_amqp_connection()

    on_exit(fn ->
      destination_paths =
        ExBackend.HelpersTest.consume_messages(channel, "job_queue_not_found", 5)
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
               "F2/Emission_test/F2_2019_12_08_Emission_test_Additional_Title.ttml"

      assert Enum.at(destination_paths, 3) ==
               "F2/Emission_test/F2_2019_12_08_Emission_test_Additional_Title.mp4"

    end)

    :ok
  end

  describe "francetv_studio_rosetta_workflow" do
    test "bad id" do
      case ExBackend.Credentials.get_credential_by_key("ATTESOR_FTVACCESS_ENDPOINT") do
        nil ->
          ExBackend.Credentials.create_credential(%{
            key: "ATTESOR_FTVACCESS_ENDPOINT",
            value: "https://demo.media-io.com/mockup/francetv"
          })
        _ -> nil
      end
      case ExBackend.Credentials.get_credential_by_key("ATTESOR_FTVACCESS_TOKEN") do
        nil ->
          ExBackend.Credentials.create_credential(%{
            key: "ATTESOR_FTVACCESS_TOKEN",
            value: "my_personal_token"
          })
        _ -> nil
      end

      workflow_params =
        ExBackend.Workflow.Definition.FtvStudioRosetta.get_definition_for_akamai_input(
          ["ftp://source/path.mp4"],
          "http://static/source/path.ttml",
          [
            %{
              id: "channel",
              type: "string",
              value: "F2"
            },
            %{
              id: "title",
              type: "string",
              value: "Emission_test"
            },
            %{
              id: "broadcasted_at",
              type: "string",
              value: "2019_12_08"
            },
            %{
              id: "additional_title",
              type: "string",
              value: "Additional_Title"
            }
          ]
        )
        |> Map.put(:reference, "39984e00-055c-4aa8-902c-1d6cab12d2da")

      {:ok, workflow} = Workflows.create_workflow(workflow_params)
      {:ok, "started"} = Step.start_next(workflow)

      ExBackend.HelpersTest.check(workflow.id, 2)
      ExBackend.HelpersTest.check(workflow.id, "job_transfer", 2)
      ExBackend.HelpersTest.complete_jobs(workflow.id, "job_transfer")

      {:ok, "started"} = Step.start_next(workflow)
      ExBackend.HelpersTest.check(workflow.id, 4)
      ExBackend.HelpersTest.check(workflow.id, "job_transfer", 4)
      ExBackend.HelpersTest.complete_jobs(workflow.id, "job_transfer")

      {:ok, "started"} = Step.start_next(workflow)
      ExBackend.HelpersTest.check(workflow.id, 5)
      ExBackend.HelpersTest.check(workflow.id, "job_transfer", 4)
      ExBackend.HelpersTest.check(workflow.id, "job_file_system", 1)
      ExBackend.HelpersTest.complete_jobs(workflow.id, "job_file_system")

      {:ok, "completed"} = Step.start_next(workflow)
      ExBackend.HelpersTest.check(workflow.id, "job_transfer", 4)
      ExBackend.HelpersTest.check(workflow.id, "job_file_system", 1)

      ExBackend.HelpersTest.check(workflow.id, 5)
    end
  end
end

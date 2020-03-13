defmodule ExBackend.FtvStudioRosettaTest do
  use ExBackendWeb.ConnCase

  alias StepFlow.Step
  alias StepFlow.Workflows

  import FakeServer
  alias FakeServer.Response
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

      assert Enum.member?(
               destination_paths,
               "F2/emission_test/F2_2019_12_08_emission_test_additional_title.mp4"
             )

      assert Enum.member?(
               destination_paths,
               "F2/emission_test/F2_2019_12_08_emission_test_additional_title.ttml"
             )
    end)

    :ok
  end

  describe "francetv_studio_rosetta_workflow_akamais" do
    test_with_server "akamai source content" do
      route("/notifications", fn request ->
        request.body
        |> Jason.decode!()

        if Map.get(request.headers, "content-type") == "application/json" &&
             Map.get(request.headers, "authorization") == "Bearer JWT_TOKEN" do
          Response.ok!(~s({"status": "ok"}))
        else
          Response.no_content!()
        end
      end)

      workflow_params =
        ExBackend.Workflow.Definition.FtvStudioRosetta.get_definition_for_akamai_input(
          ["aws://source/path.mp4"],
          "http://static/source/aws/path.ttml",
          [
            %{
              id: "short_channel",
              type: "string",
              value: "F2"
            },
            %{
              id: "channel",
              type: "string",
              value: "france-2"
            },
            %{
              id: "title",
              type: "string",
              value: "Emission test"
            },
            %{
              id: "broadcasted_at",
              type: "string",
              value: "2019_12_08"
            },
            %{
              id: "formatted_title",
              type: "string",
              value: "emission_test"
            },
            %{
              id: "formatted_broadcasted_at",
              type: "string",
              value: "2019_12_08"
            },
            %{
              id: "formatted_additional_title",
              type: "string",
              value: "additional_title"
            },
            %{
              id: "additional_title",
              type: "string",
              value: "Additional Title"
            },
            %{
              id: "aedra_id",
              type: "string",
              value: "FO02455384_28813401"
            },
            %{
              id: "legacy_id",
              type: "string",
              value: "224705433"
            },
            %{
              id: "broadcasted_live",
              type: "boolean",
              value: false
            },
            %{
              id: "duration",
              type: "string",
              value: "PT43M42S"
            },
            %{
              id: "expected_at",
              type: "string",
              value: "2020-03-12T14:30:00+01:00"
            },
            %{
              id: "expected_duration",
              type: "string",
              value: "PT45M"
            },
            %{
              id: "ftvcut_id",
              type: "string",
              value: nil
            },
            %{
              id: "oscar_id",
              type: "string",
              value: nil
            },
            %{
              id: "plurimedia_broadcast_id",
              type: "integer",
              value: 224_705_433
            },
            %{
              id: "plurimedia_collection_ids",
              type: "array_of_integers",
              value: [30_826_685, 30_823_521]
            },
            %{
              id: "plurimedia_program_id",
              type: "integer",
              value: 128_909_645
            },
            %{
              id: "rosetta_notification_endpoint",
              type: "string",
              value: "http://#{FakeServer.address()}/notifications"
            },
            %{
              id: "rosetta_notification_token",
              type: "string",
              value: "JWT_TOKEN"
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
      ExBackend.HelpersTest.check(workflow.id, "job_notification", 1)

      ExBackend.HelpersTest.check(workflow.id, 6)
    end
  end
end

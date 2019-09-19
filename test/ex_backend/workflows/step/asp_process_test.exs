defmodule ExBackend.Workflow.Step.AspProcessTest do
  use ExUnit.Case, async: false
  alias ExBackend.Workflow.Step.AspProcess
  alias ExBackend.Workflows.Workflow
  alias ExBackend.Jobs
  alias ExBackend.Jobs.Job

  import ExMock

  doctest AspProcess

  @action_name "asp_process"

  test "skipped step" do
    with_mock Jobs, [create_skipped_job: fn(_workflow, _step_id, _action_name) -> {:skipped, nil} end] do
      workflow = %Workflow{
        id: 666,
        reference: "reference_id",
        flow: %{steps: []},
        jobs: []
      }

      step_id = 0
      step = %{
        "id" => step_id,
        "parameters" => []
      }

      result = AspProcess.launch(workflow, step)
      assert called Jobs.create_skipped_job(workflow, step_id, @action_name)
      assert result == {:skipped, nil}
    end
  end

  test "started step" do
    with_mock Jobs, [
      create_job: fn(job_params) ->
        {:ok, %Job{
            id: 1,
            step_id: job_params.step_id,
            name: job_params.name,
            parameters: job_params.parameters
          }
        }
      end,
      # This is same as original, but we cannot mock a unique function in a module
      get_message: fn(%Job{} = job) -> %{
        job_id: job.id,
        parameters: job.parameters
      } end
    ] do
      workflow = %Workflow{
        id: 666,
        reference: "reference_id",
        flow: %{steps: []},
        jobs: [
          %Job{
            id: 0,
            step_id: 555,
            name: "some_job",
            parameters: [
              %{
                "id" => "destination_path",
                "type" => "string",
                "value" => [
                  "/path/to/video_file.mp4",
                  "/path/to/subtitles_file.ttml"
                ]
              }
            ]
          }
        ]
      }

      step_id = 0
      step = %{
        "id" => step_id,
        "parent_ids" => [555],
        "parameters" => [
        ]
      }

      result = AspProcess.launch(workflow, step)
      assert called Jobs.create_job(:_)
      assert called Jobs.get_message(:_)
      assert result == {:ok, "started"}
    end
  end

end

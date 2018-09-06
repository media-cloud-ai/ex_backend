defmodule ExBackend.FrancetvSubtilIngestTest do
  use ExBackendWeb.ConnCase

  alias ExBackend.Workflows
  alias ExBackend.WorkflowStep

  require Logger

  def check_count_all_job(workflow_id, total) do
    all_jobs =
      ExBackend.Jobs.list_jobs(%{
        "workflow_id" => workflow_id |> Integer.to_string(),
        "size" => 50
      })
      |> Map.get(:data)

    assert length(all_jobs) == total
  end

  def check_count_all_job(workflow_id, type, total) do
    all_jobs =
      ExBackend.Jobs.list_jobs(%{
        "job_type" => type,
        "workflow_id" => workflow_id |> Integer.to_string(),
        "size" => 50
      })
      |> Map.get(:data)

    assert length(all_jobs) == total
  end

  def complete_jobs(workflow_id, type) do
    all_jobs =
      ExBackend.Jobs.list_jobs(%{
        "job_type" => type,
        "workflow_id" => workflow_id |> Integer.to_string(),
        "size" => 50
      })
      |> Map.get(:data)

    for job <- all_jobs do
      ExBackend.Jobs.Status.set_job_status(job.id, "completed")
    end
  end

  def set_gpac_outputs(workflow_id, type, paths) do
    all_jobs =
      ExBackend.Jobs.list_jobs(%{
        "job_type" => type,
        "workflow_id" => workflow_id |> Integer.to_string(),
        "size" => 50
      })
      |> Map.get(:data)

    for job <- all_jobs do
      params =
        job.params
        |> Map.put(:destination, %{paths: paths})

      ExBackend.Jobs.update_job(job, %{params: params})
    end
  end

  describe "francetv_subtil_ingest_workflow" do
    test "bad id" do
      acs_enable = false

      steps = ExBackend.Workflow.Definition.FrancetvSubtilIngest.get_definition(acs_enable)

      workflow_params = %{
        reference: "bad_movie_id",
        flow: steps
      }

      {:ok, workflow} = Workflows.create_workflow(workflow_params)
      {:ok, "started"} = WorkflowStep.start_next_step(workflow)

      download_jobs =
        ExBackend.Jobs.list_jobs(%{
          "job_type" => "download_ftp",
          "workflow_id" => workflow.id |> Integer.to_string()
        })
        |> Map.get(:data)

      assert length(download_jobs) == 1

      {:error, "unable to publish RDF"} = WorkflowStep.start_next_step(workflow)
    end

    test "il etait une fois la vie" do
      acs_enable = false

      steps = ExBackend.Workflow.Definition.FrancetvSubtilIngest.get_definition(acs_enable)

      workflow_params = %{
        reference: "99787afd-ba2d-410f-b03e-66cf2efb3ed5",
        flow: steps
      }

      {:ok, workflow} = Workflows.create_workflow(workflow_params)

      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      check_count_all_job(workflow.id, 5)
      check_count_all_job(workflow.id, "download_ftp", 5)
      complete_jobs(workflow.id, "download_ftp")

      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      check_count_all_job(workflow.id, 6)
      check_count_all_job(workflow.id, "download_http", 1)
      complete_jobs(workflow.id, "download_http")

      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      check_count_all_job(workflow.id, 7)
      check_count_all_job(workflow.id, "audio_extraction", 1)
      complete_jobs(workflow.id, "audio_extraction")

      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      check_count_all_job(workflow.id, 11)
      check_count_all_job(workflow.id, "ttml_to_mp4", 1)
      complete_jobs(workflow.id, "ttml_to_mp4")
      set_gpac_outputs(workflow.id, "ttml_to_mp4", "subtitle.mp4")

      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      check_count_all_job(workflow.id, 12)
      check_count_all_job(workflow.id, "set_language", 1)
      complete_jobs(workflow.id, "set_language")
      set_gpac_outputs(workflow.id, "set_language", "subtitle-fra.mp4")

      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      check_count_all_job(workflow.id, 13)
      check_count_all_job(workflow.id, "generate_dash", 1)
      complete_jobs(workflow.id, "generate_dash")

      set_gpac_outputs(workflow.id, "generate_dash", [
        "/tmp/manifest.mpd",
        "/tmp/video_track.mp4",
        "/tmp/audio_track.mp4"
      ])

      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      check_count_all_job(workflow.id, 16)
      check_count_all_job(workflow.id, "upload_ftp", 3)
      complete_jobs(workflow.id, "upload_ftp")

      {:error, "unable to publish RDF"} = WorkflowStep.start_next_step(workflow)
    end

    test "il etait une fois la vie with ACS" do
      acs_enable = true

      steps = ExBackend.Workflow.Definition.FrancetvSubtilIngest.get_definition(acs_enable)

      workflow_params = %{
        reference: "99787afd-ba2d-410f-b03e-66cf2efb3ed5",
        flow: steps
      }

      {:ok, workflow} = Workflows.create_workflow(workflow_params)

      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      check_count_all_job(workflow.id, 5)
      check_count_all_job(workflow.id, "download_ftp", 5)
      complete_jobs(workflow.id, "download_ftp")

      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      check_count_all_job(workflow.id, 6)
      check_count_all_job(workflow.id, "download_http", 1)
      complete_jobs(workflow.id, "download_http")

      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      check_count_all_job(workflow.id, 7)
      check_count_all_job(workflow.id, "audio_extraction", 1)
      complete_jobs(workflow.id, "audio_extraction")

      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      check_count_all_job(workflow.id, 11)
      check_count_all_job(workflow.id, "ttml_to_mp4", 1)
      complete_jobs(workflow.id, "ttml_to_mp4")

      {:ok, "started"} = WorkflowStep.start_next_step(workflow)
      check_count_all_job(workflow.id, 13)
      check_count_all_job(workflow.id, "set_language", 1)
      complete_jobs(workflow.id, "set_language")
      check_count_all_job(workflow.id, "generate_dash", 1)
      complete_jobs(workflow.id, "generate_dash")
      check_count_all_job(workflow.id, "upload_ftp", 0)
      complete_jobs(workflow.id, "upload_ftp")

      {:error, "unable to publish RDF"} = WorkflowStep.start_next_step(workflow)
    end
  end
end

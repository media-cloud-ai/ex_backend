defmodule ExBackend.HelpersTest do
  use ExBackendWeb.ConnCase

  require Logger

  def check(workflow_id, total) do
    all_jobs =
      ExBackend.Jobs.list_jobs(%{
        "workflow_id" => workflow_id |> Integer.to_string(),
        "size" => 50
      })
      |> Map.get(:data)

    assert length(all_jobs) == total
  end

  def check(workflow_id, type, total) do
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

    all_jobs
  end

  def set_output_files(workflow_id, type, paths) do
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
end

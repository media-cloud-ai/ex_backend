defmodule ExBackend.JobsTest do
  use ExBackend.DataCase

  alias ExBackend.WorkflowsTest
  alias StepFlow.Jobs
  alias StepFlow.Jobs.Job
  alias StepFlow.Repo

  describe "jobs" do
    @valid_attrs %{name: "some name", step_id: 0, parameters: []}
    @update_attrs %{name: "some updated name", step_id: 1, parameters: [%{key: "value"}]}
    @invalid_attrs %{name: nil, step_id: nil, workflow_id: nil, parameters: nil}

    def job_fixture(attrs \\ %{}) do
      workflow = WorkflowsTest.workflow_fixture()

      params =
        @valid_attrs
        |> Map.put(:workflow_id, workflow.id)

      {:ok, job} =
        attrs
        |> Enum.into(params)
        |> Jobs.create_job()

      job
    end

    test "list_jobs/0 returns all jobs" do
      job =
        job_fixture()
        |> Repo.preload(:status)

      assert Jobs.list_jobs().total >= 1
    end

    test "get_job!/1 returns the job with given id" do
      job = job_fixture()
      assert Jobs.get_job!(job.id) == job
    end

    test "create_job/1 with valid data creates a job" do
      workflow = WorkflowsTest.workflow_fixture()

      params =
        @valid_attrs
        |> Map.put(:workflow_id, workflow.id)

      assert {:ok, %Job{} = job} = Jobs.create_job(params)
      assert job.name == "some name"
      assert job.parameters == []
    end

    test "create_job/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Jobs.create_job(@invalid_attrs)
    end

    test "update_job/2 with valid data updates the job" do
      job = job_fixture()
      assert {:ok, job} = Jobs.update_job(job, @update_attrs)
      assert %Job{} = job
      assert job.name == "some updated name"
      assert job.parameters == [%{key: "value"}]
    end

    test "update_job/2 with invalid data returns error changeset" do
      job = job_fixture()
      assert {:error, %Ecto.Changeset{}} = Jobs.update_job(job, @invalid_attrs)
      assert job == Jobs.get_job!(job.id)
    end

    test "delete_job/1 deletes the job" do
      job = job_fixture()
      assert {:ok, %Job{}} = Jobs.delete_job(job)
      assert_raise Ecto.NoResultsError, fn -> Jobs.get_job!(job.id) end
    end

    test "change_job/1 returns a job changeset" do
      job = job_fixture()
      assert %Ecto.Changeset{} = Jobs.change_job(job)
    end
  end
end

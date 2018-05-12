defmodule ExSubtilBackend.WorkflowsTest do
  use ExSubtilBackend.DataCase

  alias ExSubtilBackend.Workflows
  alias ExSubtilBackend.Repo

  describe "workflows" do
    alias ExSubtilBackend.Workflows.Workflow

    @valid_attrs %{reference: "some id", flow: %{steps: []}}
    @update_attrs %{reference: "some updated id", flow: %{steps: [%{action: "something"}]}}
    @invalid_attrs %{reference: nil, flow: nil}

    def workflow_fixture(attrs \\ %{}) do
      {:ok, workflow} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Workflows.create_workflow()

      workflow
    end

    test "list_workflows/0 returns all workflows" do
      workflow =
        workflow_fixture()
        |> Repo.preload([:artifacts, :jobs])

      assert Workflows.list_workflows() == %{data: [workflow], page: 0, size: 10, total: 1}
    end

    test "get_workflow!/1 returns the workflow with given id" do
      workflow =
        workflow_fixture()
        |> Repo.preload([:artifacts, :jobs])

      assert Workflows.get_workflow!(workflow.id) == workflow
    end

    test "create_workflow/1 with valid data creates a workflow" do
      assert {:ok, %Workflow{} = workflow} = Workflows.create_workflow(@valid_attrs)
      assert workflow.reference == "some id"
      assert workflow.flow == %{steps: []}
    end

    test "create_workflow/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Workflows.create_workflow(@invalid_attrs)
    end

    test "update_workflow/2 with valid data updates the workflow" do
      workflow = workflow_fixture()
      assert {:ok, workflow} = Workflows.update_workflow(workflow, @update_attrs)
      assert %Workflow{} = workflow
      assert workflow.reference == "some updated id"
      assert workflow.flow == %{steps: [%{action: "something"}]}
    end

    test "update_workflow/2 with invalid data returns error changeset" do
      workflow =
        workflow_fixture()
        |> Repo.preload([:artifacts, :jobs])

      assert {:error, %Ecto.Changeset{}} = Workflows.update_workflow(workflow, @invalid_attrs)
      assert workflow == Workflows.get_workflow!(workflow.id)
    end

    test "delete_workflow/1 deletes the workflow" do
      workflow = workflow_fixture()
      assert {:ok, %Workflow{}} = Workflows.delete_workflow(workflow)
      assert_raise Ecto.NoResultsError, fn -> Workflows.get_workflow!(workflow.id) end
    end

    test "change_workflow/1 returns a workflow changeset" do
      workflow = workflow_fixture()
      assert %Ecto.Changeset{} = Workflows.change_workflow(workflow)
    end
  end
end

defmodule ExBackendWeb.WorkflowsPageView do
  use ExBackendWeb, :view

  require Logger

  def render("index.json", %{
        workflows_page: %{workflows: workflows, durations: durations, users: users, total: total}
      }) do
    workflows =
      render_many(workflows, StepFlow.WorkflowView, "workflow_full.json")
      |> Enum.sort_by(& &1.id, :desc)

    durations =
      render_many(durations, StepFlow.DurationsView, "durations.json")
      |> Enum.sort_by(& &1.workflow_id, :desc)

    users =
      users
      |> Enum.sort_by(&elem(&1, 0), :asc)
      |> Enum.map(fn {_, user} -> render_one(user, ExBackendWeb.UserView, "user.json") end)

    workflows_with_durations_and_user =
      Enum.zip([workflows, durations, users])
      |> Enum.map(fn {workflow, durations, user} ->
        workflow
        |> set_durations_to_workflow(durations)
        |> set_user_to_workflow(user)
      end)

    %{
      data: workflows_with_durations_and_user,
      total: total
    }
  end

  defp set_durations_to_workflow(workflow, durations) do
    if workflow.id == durations.workflow_id do
      workflow |> Map.put("durations", durations)
    else
      Logger.warning(
        "Workflow id (#{workflow.id}) not matching with durations workflow_id #{durations.workflow_id}"
      )

      workflow
    end
  end

  defp set_user_to_workflow(workflow, user) do
    if workflow.user_uuid == user.uuid do
      workflow |> Map.put("user", user)
    else
      Logger.warning(
        "Workflow user_uuid (#{workflow.user_uuid}) not matching with user uuid #{user.uuid}"
      )

      workflow
    end
  end
end

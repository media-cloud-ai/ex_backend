defmodule ExSubtilBackendWeb.WorkflowView do
  use ExSubtilBackendWeb, :view
  alias ExSubtilBackendWeb.WorkflowView

  def render("index.json", %{workflows: %{data: workflows, total: total}}) do
    %{
      data: render_many(workflows, WorkflowView, "workflow.json"),
      total: total
    }
  end

  def render("show.json", %{workflow: workflow}) do
    %{data: render_one(workflow, WorkflowView, "workflow.json")}
  end

  def render("workflow.json", %{workflow: workflow}) do
    %{
      reference: workflow.reference,
      flow: workflow.flow,
      created_at: workflow.inserted_at,
    }
  end
end

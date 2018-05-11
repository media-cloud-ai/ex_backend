defmodule ExSubtilBackendWeb.WorkflowEventsView do
  use ExSubtilBackendWeb, :view
  alias ExSubtilBackendWeb.WorkflowView

  def render("show.json", %{workflow: workflow}) do
    %{data: render_one(workflow, WorkflowView, "workflow.json")}
  end
end

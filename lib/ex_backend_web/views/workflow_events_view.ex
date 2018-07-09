defmodule ExBackendWeb.WorkflowEventsView do
  use ExBackendWeb, :view
  alias ExBackendWeb.WorkflowView

  def render("show.json", %{workflow: workflow}) do
    %{data: render_one(workflow, WorkflowView, "workflow.json")}
  end
end

defmodule ExSubtilBackendWeb.JobView do
  use ExSubtilBackendWeb, :view
  alias ExSubtilBackendWeb.JobView

  def render("index.json", %{jobs: jobs}) do
    %{data: render_many(jobs, JobView, "job.json")}
  end

  def render("show.json", %{job: job}) do
    %{data: render_one(job, JobView, "job.json")}
  end

  def render("job.json", %{job: job}) do
    if is_tuple(job) do
      case job do
        {:error, changeset} -> %{errors: changeset |> ExSubtilBackendWeb.ChangesetView.translate_errors}
        _ -> %{errors: ["unknown error"]}
      end
    else
      status =
        if is_list(job.status) do
          render_many(job.status, ExSubtilBackendWeb.StatusView, "state.json")
        else
          []
        end

      %{
        id: job.id,
        name: job.name,
        params: job.params,
        status: status,
        inserted_at: job.inserted_at
      }
    end
  end
end

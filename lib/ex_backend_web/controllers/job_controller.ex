defmodule ExBackendWeb.JobController do
  use ExBackendWeb, :controller

  import ExBackendWeb.Authorize

  alias ExBackend.Jobs
  alias ExBackend.Jobs.Job
  alias ExBackend.Amqp.JobFtpEmitter

  action_fallback(ExBackendWeb.FallbackController)

  # the following plugs are defined in the controllers/authorize.ex file
  plug(:user_check when action in [:index, :show, :update, :delete])
  plug(:right_technician_check when action in [:index, :show, :update, :delete])

  def index(conn, params) do
    jobs = Jobs.list_jobs(params)
    render(conn, "index.json", jobs: jobs)
  end

  def create(conn, %{"job" => job_params}) do
    case Jobs.create_job(job_params) do
      {:ok, %Job{} = job} ->
        params = %{
          job_id: job.id,
          parameters: job.params
        }

        JobFtpEmitter.publish_json(params)

        conn
        |> put_status(:created)
        |> render("show.json", job: job)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(ExBackendWeb.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    job = Jobs.get_job!(id)
    render(conn, "show.json", job: job)
  end

  def update(conn, %{"id" => id, "job" => job_params}) do
    job = Jobs.get_job!(id)

    with {:ok, %Job{} = job} <- Jobs.update_job(job, job_params) do
      render(conn, "show.json", job: job)
    end
  end

  def delete(conn, %{"id" => id}) do
    job = Jobs.get_job!(id)

    with {:ok, %Job{}} <- Jobs.delete_job(job) do
      send_resp(conn, :no_content, "")
    end
  end
end

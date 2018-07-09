defmodule ExBackendWeb.RdfController do
  use ExBackendWeb, :controller

  import ExBackendWeb.Authorize

  action_fallback(ExBackendWeb.FallbackController)

  alias ExBackend.Rdf.Converter
  alias ExBackend.Rdf.PerfectMemory

  # the following plugs are defined in the controllers/authorize.ex file
  plug(:user_check when action in [:create, :show])
  plug(:right_technician_check when action in [:create, :show])

  def create(conn, params) do
    video_id = Map.get(params, "videos_id")

    response =
      Converter.get_rdf(video_id)
      |> PerfectMemory.publish_rdf()

    case response do
      201 ->
        conn
        |> put_status(:created)
        |> json(%{status: :ok})

      _ ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{status: :ok})
    end
  end

  def show(conn, params) do
    rdf_serialized =
      params
      |> Map.get("videos_id")
      |> Converter.get_rdf()

    conn
    |> json(%{content: rdf_serialized})
  end
end

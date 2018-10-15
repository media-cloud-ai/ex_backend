defmodule ExBackendWeb.RdfController do
  use ExBackendWeb, :controller

  require Logger
  import ExBackendWeb.Authorize

  action_fallback(ExBackendWeb.FallbackController)

  alias ExBackend.Rdf.Converter
  alias ExBackend.Rdf.PerfectMemory

  # the following plugs are defined in the controllers/authorize.ex file
  plug(:user_check when action in [:create, :show])
  plug(:right_technician_check when action in [:create, :show])

  def create(conn, params) do
    video_id = Map.get(params, "catalog_id")

    response =
      case Converter.get_rdf(video_id) do
        {:ok, rdf_serialized} ->
          PerfectMemory.publish_rdf(rdf_serialized)

        _ ->
          500
      end

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
    params
    |> Map.get("catalog_id")
    |> Converter.get_rdf()
    |> case do
      {:ok, rdf_serialized} -> json(conn, %{content: rdf_serialized})
      {:error, message} ->
        Logger.error("#{message}")
        conn
        |> put_status(:service_unavailable)
        |> json(%{message: message})
    end
  end
end

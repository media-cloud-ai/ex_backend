defmodule ExBackendWeb.Amqp.AmqpController do
  use ExBackendWeb, :controller

  import ExBackendWeb.Authorize
  require Logger

  # the following plugs are defined in the controllers/authorize.ex file
  plug(:user_check when action in [:queues, :connections])
  plug(:right_technician_check when action in [:queues, :connections])

  def queues(conn, _params) do
    case get_amqp_informations("queues") do
      {:ok, queues} -> json(conn, %{status: "ok", queues: queues})
      {:error, message} -> json(conn, %{status: "error", message: message})
    end
  end

  def connections(conn, _params) do
    case get_amqp_informations("connections") do
      {:ok, connections} -> json(conn, %{status: "ok", connections: connections})
      {:error, message} -> json(conn, %{status: "error", message: message})
    end
  end

  def get_amqp_informations(endpoint) do
    hostname = System.get_env("AMQP_HOSTNAME") || Application.get_env(:amqp, :hostname)
    username = System.get_env("AMQP_USERNAME") || Application.get_env(:amqp, :username)
    password = System.get_env("AMQP_PASSWORD") || Application.get_env(:amqp, :password)

    port =
      System.get_env("AMQP_MANAGEMENT_PORT") || Application.get_env(:amqp, :management_port) ||
        15672
        |> port_format

    url = "http://" <> hostname <> ":" <> port <> "/api/" <> endpoint

    case HTTPotion.get(url, basic_auth: {username, password}) do
      %HTTPotion.ErrorResponse{message: message} ->
        Logger.error("Unable to connect to #{url}")
        %{error: message}

      response ->
        Poison.decode(response.body)
    end
  end

  defp port_format(port) when is_integer(port) do
    Integer.to_string(port)
  end

  defp port_format(port) do
    port
  end
end

defmodule ExBackendWeb.Amqp.AmqpController do
  use ExBackendWeb, :controller

  import ExBackendWeb.Authorize

  # the following plugs are defined in the controllers/authorize.ex file
  plug(:user_check when action in [:queues, :connections])
  plug(:right_technician_check when action in [:queues, :connections])

  def queues(conn, _params) do
    queues = get_amqp_informations("queues")

    conn
    |> json(%{queues: queues})
  end

  def connections(conn, _params) do
    connections = get_amqp_informations("connections")

    conn
    |> json(%{connections: connections})
  end

  def get_amqp_informations(endpoint) do
    hostname = System.get_env("AMQP_HOSTNAME") || Application.get_env(:amqp, :hostname)
    username = System.get_env("AMQP_USERNAME") || Application.get_env(:amqp, :username)
    password = System.get_env("AMQP_PASSWORD") || Application.get_env(:amqp, :password)

    port =
      System.get_env("AMQP_MANAGEMENT_PORT") || Application.get_env(:amqp, :management_port) ||
        15672
        |> port_format

    HTTPotion.get(
      "http://" <> hostname <> ":" <> port <> "/api/" <> endpoint,
      basic_auth: {username, password}
    ).body
    |> Poison.decode!()
  end

  defp port_format(port) when is_integer(port) do
    Integer.to_string(port)
  end

  defp port_format(port) do
    port
  end
end

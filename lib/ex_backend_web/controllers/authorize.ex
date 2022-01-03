defmodule ExBackendWeb.Authorize do
  @moduledoc false

  import Plug.Conn
  import Phoenix.Controller

  # This function can be used to customize the `action` function in
  # the controller so that only authenticated users can access each route.
  # See the [Authorization wiki page](https://github.com/riverrun/phauxth/wiki/Authorization)
  # for more information and examples.
  def auth_action(%Plug.Conn{assigns: %{current_user: nil}} = conn, _) do
    error(conn, :unauthorized, 401)
  end

  def auth_action(
        %Plug.Conn{assigns: %{current_user: current_user}, params: params} = conn,
        module
      ) do
    apply(module, action_name(conn), [conn, params, current_user])
  end

  # Plug to only allow authenticated users to access the resource.
  # See the user controller for an example.
  def user_check(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts) do
    error(conn, :unauthorized, 401)
  end

  def user_check(conn, _opts), do: conn

  # Plug to only allow unauthenticated users to access the resource.
  # See the session controller for an example.
  def guest_check(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts), do: conn

  def guest_check(%Plug.Conn{assigns: %{current_user: _current_user}} = conn, _opts) do
    put_status(conn, :unauthorized)
    |> put_view(ExBackendWeb.AuthView)
    |> render("logged_in.json", [])
    |> halt
  end

  # Plug to only allow authenticated users with the correct id to access the resource.
  # See the user controller for an example.
  def id_check(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts) do
    error(conn, :unauthorized, 401)
  end

  def id_check(
        %Plug.Conn{params: %{"id" => id}, assigns: %{current_user: current_user}} = conn,
        _opts
      ) do
    (id == to_string(current_user.id) and conn) || error(conn, :forbidden, 403)
  end

  def right_administrator_check(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts) do
    error(conn, :unauthorized, 401)
  end

  def right_administrator_check(
        %Plug.Conn{assigns: %{current_user: current_user}} = conn,
        _opts
      ) do
    (Enum.member?(current_user.roles, "administrator") and conn) || error(conn, :forbidden, 403)
  end

  def right_technician_check(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts) do
    error(conn, :unauthorized, 401)
  end

  def right_technician_check(
        %Plug.Conn{assigns: %{current_user: current_user}} = conn,
        _opts
      ) do
    (Enum.member?(current_user.roles, "technician") and conn) || error(conn, :forbidden, 403)
  end

  def right_editor_check(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts) do
    error(conn, :unauthorized, 401)
  end

  def right_editor_check(
        %Plug.Conn{assigns: %{current_user: current_user}} = conn,
        _opts
      ) do
    (Enum.member?(current_user.roles, "editor") and conn) || error(conn, :forbidden, 403)
  end

  def right_ftvstudio_check(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts) do
    error(conn, :unauthorized, 401)
  end

  def right_ftvstudio_check(
        %Plug.Conn{assigns: %{current_user: current_user}} = conn,
        _opts
      ) do
    (Enum.member?(current_user.roles, "ftvstudio") and conn) || error(conn, :forbidden, 403)
  end

  def right_technician_or_ftvstudio_check(%Plug.Conn{assigns: %{current_user: nil}} = conn, _opts) do
    error(conn, :unauthorized, 401)
  end

  def right_technician_or_ftvstudio_check(
        %Plug.Conn{assigns: %{current_user: current_user}} = conn,
        _opts
      ) do
    (Enum.member?(current_user.roles, "technician") and conn) ||
      (Enum.member?(current_user.roles, "ftvstudio") and conn) ||
      error(conn, :forbidden, 403)
  end

  def error(conn, status, code) do
    put_status(conn, status)
    |> put_view(ExBackendWeb.AuthView)
    |> render("#{code}.json", [])
    |> halt
  end
end

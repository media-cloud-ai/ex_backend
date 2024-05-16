defmodule ExBackendWeb.PasswordResetControllerTest do
  use ExBackendWeb.ConnCase

  import ExBackendWeb.AuthCase

  @update_attrs %{email: "gladys@example.com", password: "^hEsdg*F899"}

  setup %{conn: conn} do
    user = add_reset_user("Gladys", "Doe", "gladys@example.com")
    {:ok, %{conn: conn, user: user}}
  end

  test "user can create a password reset request", %{conn: conn} do
    valid_attrs = %{email: "gladys@example.com"}
    conn = post(conn, password_reset_path(conn, :create), password_reset: valid_attrs)
    assert json_response(conn, 201)["detail"]
  end

  test "create function fails for no user", %{conn: conn} do
    invalid_attrs = %{email: "prettylady@example.com"}
    conn = post(conn, password_reset_path(conn, :create), password_reset: invalid_attrs)
    assert json_response(conn, 404)["errors"] != %{}
  end

  test "reset password succeeds for correct key", %{conn: conn, user: user} do
    # generate a token
    token =
      conn
      |> add_token_conn(user)
      |> get_token()

    valid_attrs = Map.put(@update_attrs, :key, token)

    # reset connection
    conn = Phoenix.ConnTest.build_conn()

    reset_conn = put(conn, password_reset_path(conn, :update), password_reset: valid_attrs)
    assert json_response(reset_conn, 200)["detail"] =~ "password has been reset"
    conn = post(conn, session_path(conn, :create), session: @update_attrs)
    assert json_response(conn, 200)["access_token"]
  end

  test "reset password fails for incorrect key", %{conn: conn} do
    invalid_attrs = %{email: "gladys@example.com", password: "^hEsdg*F899", key: "garbage"}
    conn = put(conn, password_reset_path(conn, :update), password_reset: invalid_attrs)
    assert json_response(conn, 422)["errors"] != %{}
  end
end

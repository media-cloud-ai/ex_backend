defmodule ExBackendWeb.ConfirmControllerTest do
  use ExBackendWeb.ConnCase

  import ExBackendWeb.AuthCase

  setup %{conn: conn} do
    user = add_user("Arthur", "Simmons", "arthur@example.com")
    conn = add_token_conn(conn, user)
    token = get_token(conn)
    {:ok, %{conn: conn, token: token}}
  end

  test "confirmation succeeds for correct key", %{conn: conn, token: token} do
    conn =
      get(
        conn,
        confirm_path(conn, :index,
          password: "reallyHard2gue$$",
          key: token
        )
      )

    assert json_response(conn, 200)["info"]["detail"]
  end

  test "confirmation fails for incorrect key", %{conn: conn} do
    conn = get(conn, confirm_path(conn, :index, key: "garbage"))
    assert json_response(conn, 401)["errors"]["detail"]
  end

  test "confirmation fails for without password", %{conn: conn, token: token} do
    conn = get(conn, confirm_path(conn, :index, key: token))
    assert json_response(conn, 422)["errors"]["password"] == ["can't be blank"]
  end

  test "confirmation fails for missing password email", %{conn: conn, token: token} do
    conn =
      get(conn, confirm_path(conn, :index, password: nil, key: token))

    assert json_response(conn, 422)["errors"]["password"] == ["can't be blank"]
  end

  test "confirmation fails for too short password email", %{conn: conn, token: token} do
    conn =
      get(conn, confirm_path(conn, :index, password: "short", key: token))

    assert json_response(conn, 422)["errors"]["password"] == ["The password is too short"]
  end
end

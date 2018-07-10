defmodule ExBackendWeb.ConfirmControllerTest do
  use ExBackendWeb.ConnCase

  import ExBackendWeb.AuthCase

  setup %{conn: conn} do
    add_user("arthur@example.com")
    {:ok, %{conn: conn}}
  end

  test "confirmation succeeds for correct key", %{conn: conn} do
    conn = get(conn, confirm_path(conn, :index, password: "reallyHard2gue$$", key: gen_key("arthur@example.com")))
    assert json_response(conn, 200)["info"]["detail"]
  end

  test "confirmation fails for incorrect key", %{conn: conn} do
    conn = get(conn, confirm_path(conn, :index, key: "garbage"))
    assert json_response(conn, 401)["errors"]["detail"]
  end

  test "confirmation fails for incorrect email", %{conn: conn} do
    conn = get(conn, confirm_path(conn, :index, key: gen_key("gerald@example.com")))
    assert json_response(conn, 401)["errors"]["detail"]
  end

  test "confirmation fails for missing password email", %{conn: conn} do
    conn = get(conn, confirm_path(conn, :index, password: nil, key: gen_key("arthur@example.com")))
    assert json_response(conn, 422)["errors"]["password"] == ["can't be blank"]
  end

  test "confirmation fails for too short password email", %{conn: conn} do
    conn = get(conn, confirm_path(conn, :index, password: "short", key: gen_key("arthur@example.com")))
    assert json_response(conn, 422)["errors"]["password"] == ["The password is too short"]
  end
end

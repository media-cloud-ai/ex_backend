defmodule ExSubtilBackendWeb.JobControllerTest do
  use ExSubtilBackendWeb.ConnCase

  def fixture(:job) do
    ExSubtilBackend.JobsTest.job_fixture()
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all jobs", %{conn: conn} do
      conn = get conn, job_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end
end

defmodule ExSubtilBackendWeb.SessionView do
  use ExSubtilBackendWeb, :view

  def render("info.json", %{info: token}) do
    %{access_token: token}
  end
end

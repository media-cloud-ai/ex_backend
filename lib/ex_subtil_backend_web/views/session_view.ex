defmodule ExSubtilBackendWeb.SessionView do
  use ExSubtilBackendWeb, :view

  def render("info.json", %{info: token, user: user}) do
    %{
      access_token: token,
      user: %{
        id: user.id,
        email: user.email,
        rights: user.rights
      }
    }
  end
end

defmodule ExSubtilBackendWeb.UserView do
  use ExSubtilBackendWeb, :view
  alias ExSubtilBackendWeb.UserView

  def render("index.json", %{users: %{data: users, total: total}}) do
    %{
      data: render_many(users, UserView, "user.json"),
      total: total
    }
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id, email: user.email, rights: user.rights, confirmed_at: user.confirmed_at}
  end
end

defmodule ExBackendWeb.UserView do
  use ExBackendWeb, :view
  alias ExBackendWeb.UserView

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
    %{id: user.id, email: user.email, rights: user.rights, confirmed_at: user.confirmed_at, inserted_at: user.inserted_at}
  end
end

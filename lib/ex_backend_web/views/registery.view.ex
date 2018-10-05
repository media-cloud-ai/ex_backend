defmodule ExBackendWeb.RegisteryView do
  use ExBackendWeb, :view
  alias ExBackendWeb.RegisteryView
  alias ExBackendWeb.UserView
  alias ExBackend.Accounts

  def render("index.json", %{items: %{data: items, total: total}}) do
    %{
      data: render_many(items, RegisteryView, "registery.json"),
      total: total
    }
  end

  def render("show.json", %{item: item}) do
    %{data: render_one(item, RegisteryView, "registery.json")}
  end

  def render("registery.json", %{registery: item}) do
    subtitles = load_user(Map.get(item.params, "subtitles"))
    params = Map.put(item.params, "subtitles", subtitles)

    %{
      id: item.id,
      workflow_id: item.workflow_id,
      name: item.name,
      params: params,
      inserted_at: item.inserted_at,
      updated_at: item.updated_at
    }
  end

  defp load_user(subtitles, result \\ [])
  defp load_user([], result), do: result
  defp load_user([subtitle | subtitles], result) do
    subtitle =
      case Map.get(subtitle, "user_id") do
        nil -> subtitle
        user_id ->
          user =
            Accounts.get(user_id)
            |> render_one(UserView, "user.json")

          Map.put(subtitle, "user", user)
      end

    result = List.insert_at(result, -1, subtitle)
    load_user(subtitles, result)
  end
end

defmodule ExBackend.Migration.MoveSubtitlesItems do
  use Ecto.Migration

  alias ExBackend.Repo

  def change do
    Repo.all(ExBackend.Registeries.Registery)
    |> Enum.map(fn registery ->
      Map.get(registery.params, "subtitles")
      |> Enum.map(fn item ->
        language = Map.get(item, "language")
        path = Map.get(item, "paths") |> List.first()

        user_id =
          Map.get(
            item,
            "user_id",
            ExBackend.Accounts.list_users() |> Map.get(:data) |> List.first() |> Map.get(:id)
          )

        version = Map.get(item, "version", "Generated")

        %{
          language: language,
          path: path,
          user_id: user_id,
          version: version,
          registery_id: registery.id
        }
        |> ExBackend.Subtitles.create_subtitle()
      end)
    end)
  end
end

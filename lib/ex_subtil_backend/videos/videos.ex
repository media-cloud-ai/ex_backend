defmodule ExSubtilBackend.Videos do
  @moduledoc """
  The Videos context.
  """

  require Logger

  import Ecto.Query, warn: false
  alias ExSubtilBackend.Repo
  alias ExSubtilBackend.Workflows.Workflow

  def get_manifest_url(video_id) do
    workflow =
      ExSubtilBackend.Workflows.list_workflows(%{video_id: video_id})
      |> Map.get(:data)
      |> List.first

    case workflow do
      nil -> nil
      workflow ->
        try do
          query =
            from item in Workflow,
            where: item.id == ^workflow.id,
            join: job in assoc(item, :jobs),
            where: job.name == "upload_ftp",
            where: fragment("?->?->>? LIKE ?", job.params, "destination", "path", "%.mpd"),
            select: job,
            order_by: [desc: :inserted_at],
            limit: 1

          Repo.one!(query)
          |> Map.get(:params)
          |> Map.get("destination")
          |> Map.get("path")
          |> String.replace("/421959/prod/innovation/", "http://videos-pmd.francetv.fr/innovation/")
        rescue
          e ->
            Logger.error "unable to retrieve manifest URL for #{workflow.id}: #{inspect e}"
            nil
        end
    end
  end
end

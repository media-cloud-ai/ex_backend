defmodule ExSubtilBackend.Videos do
  @moduledoc """
  The Videos context.
  """

  require Logger

  import Ecto.Query, warn: false
  alias ExSubtilBackend.Repo
  alias ExSubtilBackend.Artifacts.Artifact

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
            from item in Artifact,
              where: item.workflow_id == ^workflow.id,
              order_by: item.inserted_at

          case Repo.all(query) do
            [] -> nil
            artifacts ->
              artifacts
              |> List.first
              |> Map.get(:resources, %{})
              |> Map.get("manifest")
              |> case do
                  nil -> nil
                  manifest -> String.replace(manifest, "/421959/prod/innovation/", "http://videos-pmd.francetv.fr/innovation/")
                end
          end
        rescue
          e ->
            Logger.error "unable to retrieve manifest URL for #{workflow.id}: #{inspect e}"
            nil
        end
    end
  end
end

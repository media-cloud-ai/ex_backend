defmodule ExBackend.Migration.UpdateStepIdOnJob do
  use Ecto.Migration

  alias ExBackend.Repo

  def change do
    Repo.all(ExBackend.Jobs.OldJob)
    |> Repo.preload(:workflow)
    |> Enum.map(fn job ->
      step =
        job
        |> Map.get(:workflow)
        |> Map.get(:flow)
        |> Map.get("steps")
        |> Enum.filter(fn step -> Map.get(step, "name") == job.name end)
        |> List.first()

      if step != nil do
        ExBackend.Jobs.update_job(job, %{step_id: Map.get(step, "id")})
      end
    end)
  end
end

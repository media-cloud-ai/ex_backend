defmodule ExBackend.Migration.MoveParamsToParametersOnJob do
  use Ecto.Migration

  alias ExBackend.Repo

  def change do
    Repo.all(ExBackend.Jobs.Job)
    |> Repo.preload(:workflow)
    |> Enum.map(fn job ->
      params =
        job
        |> Map.get(:params, %{})
        |> Map.get(:list, [])

      ExBackend.Jobs.Job.changeset(job, %{
        "parameters" => params
      })
      |> Repo.update([{:force, true}])
    end)
  end
end

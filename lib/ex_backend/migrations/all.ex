defmodule ExBackend.Migration.All do
  @moduledoc false

  def apply_migrations do
    Ecto.Migrator.up(
      ExBackend.Repo,
      20_171_116_223_034,
      ExBackend.Migration.CreateJobs
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_171_121_233_956,
      ExBackend.Migration.CreateStatus
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_180_213_135_100,
      ExBackend.Migration.CreateWorkflow
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_180_213_171_900,
      ExBackend.Migration.AddLinkBetweenJobAndWorkflow
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_180_319_162_700,
      ExBackend.Migration.CreateArtifacts
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_180_416_110_632,
      ExBackend.Migration.CreateUsers
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_180_416_094_200,
      ExBackend.Migration.AddStatusDescription
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_180_421_112_500,
      ExBackend.Migration.CreatePersons
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_180_421_171_300,
      ExBackend.Migration.AddUserRight
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_180_514_190_000,
      ExBackend.Migration.UpdatePersons
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_180_713_172_000,
      ExBackend.Migration.CreateNodes
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_180_807_182_800,
      ExBackend.Migration.CreateWatchers
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_180_831_161_100,
      ExBackend.Migration.AddCacertFileOnNode
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_180_904_151_104,
      ExBackend.Migration.AddStepIdOnJob
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_180_910_145_830,
      ExBackend.Migration.CreateRegistery
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_181_008_122_930,
      ExBackend.Migration.CreateSubtitles
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_181_113_152_855,
      ExBackend.Migration.CreateCredentials
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_190_226_190_800,
      ExBackend.Migration.AddFieldsOnWorkflow
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_190_708_132_200,
      ExBackend.Migration.UpdateCredentialValueLength
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_190_723_091_304,
      ExBackend.Migration.AddParametersOnWorkflow
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_190_723_153_700,
      ExBackend.Migration.AddParametersOnJob
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_190_723_162_000,
      ExBackend.Migration.RemoveParamsFromJob
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_210_930_160_000,
      ExBackend.Migration.AddUuidAndCredsToUser
    )

    Ecto.Migrator.up(
      ExBackend.Repo,
      20_211_207_110_000,
      ExBackend.Migration.ReplaceUserRightsPerRoles
    )
  end
end

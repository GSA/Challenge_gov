defmodule ChallengeGov.Repo.Migrations.FixChallengeUuidGeneration do
  use Ecto.Migration
  alias ChallengeGov.Repo
  alias ChallengeGov.Challenges.Challenge

  def up do
    alter table(:challenges) do
      remove(:uuid, :uuid)
      add(:uuid, :uuid)
    end

    flush()

    Challenge
    |> Repo.all()
    |> Enum.map(fn challenge ->
      challenge
      |> Ecto.Changeset.change(%{uuid: Ecto.UUID.generate()})
      |> Repo.update()
    end)
  end

  def down do
    alter table(:challenges) do
      remove(:uuid, :uuid)
      add(:uuid, :uuid)
    end
  end
end

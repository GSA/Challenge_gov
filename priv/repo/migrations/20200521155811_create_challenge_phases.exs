defmodule ChallengeGov.Repo.Migrations.CreateChallengePhases do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add(:phases, :map)
    end
  end
end

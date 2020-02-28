defmodule ChallengeGov.Repo.Migrations.AddTypesToChallenge do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add :types, :map
    end
  end
end

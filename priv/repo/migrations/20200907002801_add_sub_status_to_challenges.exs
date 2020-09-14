defmodule ChallengeGov.Repo.Migrations.AddSubStatusToChallenges do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add :sub_status, :string
    end
  end
end

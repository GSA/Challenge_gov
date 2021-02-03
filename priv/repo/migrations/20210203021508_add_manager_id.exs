defmodule ChallengeGov.Repo.Migrations.AddManagerId do
  use Ecto.Migration

  def change do
    alter table(:solutions) do
      add :manager_id, references(:users)
    end
  end
end

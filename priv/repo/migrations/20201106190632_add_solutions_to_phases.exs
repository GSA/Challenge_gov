defmodule ChallengeGov.Repo.Migrations.AddSolutionsToPhases do
  use Ecto.Migration

  def change do
    alter table(:solutions) do
      add(:phase_id, references(:phases), null: false)
    end
  end
end

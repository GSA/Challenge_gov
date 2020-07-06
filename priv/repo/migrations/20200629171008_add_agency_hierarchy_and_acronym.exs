defmodule ChallengeGov.Repo.Migrations.AddAgencyHierarchyAndAcronym do
  use Ecto.Migration

  def change do
    alter table(:agencies) do
      add(:acronym, :string)
      add(:parent_id, references(:agencies))
    end
  end
end

defmodule ChallengeGov.Repo.Migrations.AddSectionToDocuments do
  use Ecto.Migration

  def change do
    alter table(:supporting_documents) do
      add(:section, :string)
    end

    execute "update supporting_documents set section = 'Unknown'",
            "update supporting_documents set section = ''"

    alter table(:supporting_documents) do
      modify(:section, :string, null: false)
    end
  end
end

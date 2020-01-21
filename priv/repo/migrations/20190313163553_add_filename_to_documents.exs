defmodule ChallengeGov.Repo.Migrations.AddFilenameToDocuments do
  use Ecto.Migration

  def change do
    alter table(:supporting_documents) do
      add(:filename, :string, null: false)
    end
  end
end

defmodule ChallengeGov.Repo.Migrations.AddNameToSupportingDocuments do
  use Ecto.Migration

  def change do
    alter table(:supporting_documents) do
      add(:name, :string)
    end
  end
end

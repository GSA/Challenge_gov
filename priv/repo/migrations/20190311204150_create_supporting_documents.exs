defmodule ChallengeGov.Repo.Migrations.CreateSupportingDocuments do
  use Ecto.Migration

  def change do
    create table(:supporting_documents) do
      add(:user_id, references(:users), null: false)
      add(:challenge_id, references(:challenges), null: true)
      add(:key, :uuid, null: false)
      add(:extension, :string, null: false)

      timestamps()
    end
  end
end

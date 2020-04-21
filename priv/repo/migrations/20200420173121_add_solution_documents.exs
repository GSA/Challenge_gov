defmodule ChallengeGov.Repo.Migrations.AddSolutionDocuments do
  use Ecto.Migration

  def change do
    create table(:solution_documents) do
      add(:user_id, references(:users), null: false)
      add(:solution_id, references(:solutions), null: true)
      add(:filename, :string, null: false)
      add(:key, :uuid, null: false)
      add(:extension, :string, null: false)
      add(:name, :string)

      timestamps()
    end
  end
end

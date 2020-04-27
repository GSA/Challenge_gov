defmodule ChallengeGov.Repo.Migrations.CreateSolutions do
  use Ecto.Migration

  def change do
    create table(:solutions) do
      add(:submitter_id, references(:users), null: false)
      add(:challenge_id, references(:challenges), null: false)
      add(:title, :string)
      add(:brief_description, :text)
      add(:description, :text)
      add(:external_url, :string)
      add(:status, :string)
      add(:deleted_at, :utc_datetime)
      timestamps()
    end
  end
end

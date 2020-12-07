defmodule ChallengeGov.Repo.Migrations.CreateSubmissionExports do
  use Ecto.Migration

  def change do
    create table(:submission_exports) do
      add(:challenge_id, references(:challenges), null: false)
      add(:phase_ids, :map)
      add(:judging_status, :string)
      add(:format, :string)
      add(:status, :string)
      add(:key, :uuid, null: false)
      timestamps()
    end
  end
end

defmodule ChallengeGov.Repo.Migrations.CreateSubmissionInvites do
  use Ecto.Migration

  def change do
    create table(:submission_invites) do
      add(:solution_id, references(:solutions), null: false)
      add(:message, :text)
      add(:message_delta, :text)
      add(:status, :string)
      timestamps()
    end
  end
end

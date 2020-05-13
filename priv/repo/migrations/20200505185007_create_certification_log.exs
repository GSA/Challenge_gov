defmodule ChallengeGov.Repo.Migrations.CreateCertificationLog do
  use Ecto.Migration

  def change do
    create table(:certification_log) do
      add(:approver_id, references(:users))
      add(:approver_role, :string)
      add(:approver_identifier, :string)
      add(:approver_remote_ip, :string)
      add(:user_id, references(:users), null: false)
      add(:user_role, :string)
      add(:user_identifier, :string)
      add(:user_remote_ip, :string)
      add(:requested_at, :utc_datetime)
      add(:certified_at, :utc_datetime)
      add(:expires_at, :utc_datetime)
      add(:denied_at, :utc_datetime)

      timestamps()
    end
  end
end

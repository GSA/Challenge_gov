defmodule ChallengeGov.Repo.Migrations.RemoveNullConstraintOnSecurityLog do
  use Ecto.Migration

  def up do
    drop(constraint(:security_log, "security_log_originator_id_fkey"))

    alter table(:security_log) do
      modify :originator_id, references(:users), null: true
      modify :originator_role, :string, null: true
      modify :originator_identifier, :string, null: true
    end
  end

  def down do
    drop(constraint(:security_log, "security_log_originator_id_fkey"))

    alter table(:security_log) do
      modify :originator_id, references(:users), null: false
      modify :originator_role, :string, null: false
      modify :originator_identifier, :string, null: false
    end
  end
end

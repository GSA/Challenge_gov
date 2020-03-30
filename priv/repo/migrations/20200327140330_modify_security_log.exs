defmodule ChallengeGov.Repo.Migrations.ModifySecurityLog do
  use Ecto.Migration

  def change do
    alter table(:security_log) do
      remove(:user_id)
      remove(:type)
      remove(:data)
      remove(:inserted_at)
      remove(:updated_at)
      add(:action, :string, null: false)
      add(:details, :map)
      add(:originator_id, references(:users), null: false)
      add(:originator_role, :string, null: false)
      add(:originator_identifier, :string, null: false)
      add(:target_id, :integer)
      add(:target_type, :string)
      add(:target_identifier, :string)
      add(:logged_at, :naive_datetime, null: false)
    end
  end
end

defmodule ChallengeGov.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table("users") do
      add(:email, :string, null: false)
      add(:password_hash, :string, null: false)
      add(:token, :uuid, null: false)

      add(:first_name, :string, null: false)
      add(:last_name, :string, null: false)
      add(:phone_number, :string, null: true)

      timestamps()
    end

    create index(:users, ["lower(email)"], unique: true)
  end
end

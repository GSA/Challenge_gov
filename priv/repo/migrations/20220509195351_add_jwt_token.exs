defmodule ChallengeGov.Repo.Migrations.AddJwtToken do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:jwt_token, :text)
    end
  end

  def down do
    alter table(:users) do
      remove(:jwt_token)
    end
  end
end

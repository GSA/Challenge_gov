defmodule ChallengeGov.Repo.Migrations.AddActiveSessionToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:active_session, :boolean)
    end
  end
end

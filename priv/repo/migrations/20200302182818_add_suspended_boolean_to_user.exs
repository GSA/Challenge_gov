defmodule ChallengeGov.Repo.Migrations.AddSuspendedBooleanToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :suspended, :boolean, default: false
    end
  end
end

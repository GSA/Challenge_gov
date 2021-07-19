defmodule ChallengeGov.Repo.Migrations.AddStatusToMessages do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      add :status, :string, null: false, default: "sent"
    end
  end
end

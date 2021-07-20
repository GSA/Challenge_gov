defmodule ChallengeGov.Repo.Migrations.AddCachedColumnsToMessageContexts do
  use Ecto.Migration

  def change do
    alter table(:message_contexts) do
      add :last_message_id, references(:messages)
    end
  end
end

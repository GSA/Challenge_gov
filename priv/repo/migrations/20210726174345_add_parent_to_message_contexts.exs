defmodule ChallengeGov.Repo.Migrations.AddParentToMessageContexts do
  use Ecto.Migration

  def change do
    alter table(:message_contexts) do
      add :parent_id, references(:message_contexts)
    end
  end
end

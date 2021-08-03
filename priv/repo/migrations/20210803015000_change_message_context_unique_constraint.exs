defmodule ChallengeGov.Repo.Migrations.ChangeMessageContextUniqueConstraint do
  use Ecto.Migration

  def change do
    drop unique_index(:message_contexts, [:context, :context_id])
    create unique_index(:message_contexts, [:context, :context_id, :audience, :parent_id])
  end
end

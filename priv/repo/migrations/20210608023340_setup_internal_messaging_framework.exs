defmodule ChallengeGov.Repo.Migrations.SetupInternalMessagingFramework do
  use Ecto.Migration

  def change do
    create table(:message_contexts) do
      add(:context, :string, null: false)
      add(:context_id, :integer, null: false)
      timestamps()
    end

    create table(:messages) do
      add(:message_context_id, references(:message_contexts), null: false)
      add(:author_id, references(:users), null: false)
      add(:content, :text)
      add(:content_delta, :text)
      timestamps()
    end

    create table(:message_context_statuses) do
      add(:message_context_id, references(:message_contexts), null: false)
      add(:user_id, references(:users), null: false)
      add(:read, :boolean, default: false)
      add(:starred, :boolean, default: false)
      timestamps()
    end

    create unique_index(:message_contexts, [:context, :context_id])
  end
end

defmodule ChallengeGov.Repo.Migrations.AddArchivedToMessageContextStatus do
  use Ecto.Migration

  def change do
    alter table(:message_context_statuses) do
      add :archived, :boolean, default: false
    end
  end
end

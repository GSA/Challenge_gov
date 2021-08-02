defmodule ChallengeGov.Repo.Migrations.ChangeMessageContextAudienceToString do
  use Ecto.Migration

  def up do
    alter table(:message_contexts) do
      remove :audience
    end

    alter table(:message_contexts) do
      add :audience, :string
    end

    execute "update message_contexts set audience='all';"
  end

  def down do
    alter table(:message_contexts) do
      remove :audience
    end

    alter table(:message_contexts) do
      add :audience, {:array, :string}
    end

    flush()
    execute "update message_contexts set audience=ARRAY['solver'];"

    alter table(:message_contexts) do
      modify :audience, {:array, :string}, null: false
    end
  end
end

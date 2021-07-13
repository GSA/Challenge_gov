defmodule ChallengeGov.Repo.Migrations.AddAudienceToMessageContext do
  use Ecto.Migration

  def change do
    alter table(:message_contexts) do
      add :audience, {:array, :string}, null: false
    end
  end
end

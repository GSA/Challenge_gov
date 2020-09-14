defmodule ChallengeGov.Repo.Migrations.AddActiveTopicToChallenge do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add :gov_delivery_topic, :string
    end
  end
end

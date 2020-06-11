defmodule ChallengeGov.Repo.Migrations.AddChallengeTextDeltas do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add :description_delta, :text
      add :prize_description_delta, :text
      add :faq_delta, :text
    end
  end
end

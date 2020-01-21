defmodule ChallengeGov.Repo.Migrations.UpdateExistingChallengePublishedOn do
  use Ecto.Migration

  def up do
    execute "update challenges set published_on = inserted_at"
  end

  def down do
  end
end

defmodule ChallengeGov.Repo.Migrations.UpdateChallengeTaglineStringToText do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      modify :tagline, :text
    end
  end
end

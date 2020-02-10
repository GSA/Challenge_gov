defmodule ChallengeGov.Repo.Migrations.AddCustomUrlUniqueConstraintToChallenges do
  use Ecto.Migration

  def change do
    create unique_index(:challenges, [:custom_url])
  end
end

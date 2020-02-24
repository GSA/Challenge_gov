defmodule ChallengeGov.Repo.Migrations.AddLastSectionToChallenges do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add :last_section, :string
    end
  end
end

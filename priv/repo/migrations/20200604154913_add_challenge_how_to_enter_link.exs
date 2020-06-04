defmodule ChallengeGov.Repo.Migrations.AddChallengeHowToEnterLink do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add :how_to_enter_link, :string
    end
  end
end

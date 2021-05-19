defmodule ChallengeGov.Repo.Migrations.AddDeltasToSubmissions do
  use Ecto.Migration

  def change do
    alter table(:submissions) do
      add :description_delta, :text
      add :brief_description_delta, :text
    end
  end
end

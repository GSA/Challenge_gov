defmodule ChallengeGov.Repo.Migrations.AdditionalFields do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add(:brief_description, :text)
    end
  end
end

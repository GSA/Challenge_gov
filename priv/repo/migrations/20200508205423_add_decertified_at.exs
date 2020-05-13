defmodule ChallengeGov.Repo.Migrations.AddDecertifiedAt do
  use Ecto.Migration

  def change do
    alter table(:certification_log) do
      add(:decertified_at, :utc_datetime)
    end
  end
end

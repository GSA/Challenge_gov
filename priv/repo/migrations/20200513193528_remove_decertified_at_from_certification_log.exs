defmodule ChallengeGov.Repo.Migrations.RemoveDecertifiedAtFromCertificationLog do
  use Ecto.Migration

  def change do
    alter table(:certification_log) do
      remove(:decertified_at)
    end
  end
end

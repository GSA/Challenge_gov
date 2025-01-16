defmodule ChallengeGov.Repo.Migrations.AddPhasesSubmissionsCount do
  use Ecto.Migration

  def change do
    alter table("phases") do
      add_if_not_exists :submissions_count, :integer, null: false, default: 0
    end
  end
end

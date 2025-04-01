defmodule ChallengeGov.Repo.Migrations.AddIalLevelToUsers do
  use Ecto.Migration

  def change do
    alter table("users") do
      add_if_not_exists :ial_level, :integer, null: false, default: 1
    end
  end
end

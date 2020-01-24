defmodule :"Elixir.ChallengeGov.Repo.Migrations.Multi-phase" do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add(:multi_phase, :boolean)
    end
  end
end

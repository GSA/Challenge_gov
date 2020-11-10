defmodule ChallengeGov.Repo.Migrations.AddJudgingStatusToSolutions do
  use Ecto.Migration

  def change do
    alter table(:solutions) do
      add(:judging_status, :string, default: "not_selected")
    end
  end
end

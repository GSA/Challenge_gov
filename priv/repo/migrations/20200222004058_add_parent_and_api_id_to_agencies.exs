defmodule ChallengeGov.Repo.Migrations.AddParentAndApiIdToAgencies do
  use Ecto.Migration

  def change do
    alter table(:agencies) do
      add(:api_id, :integer)
      add(:parent_id, references(:agencies), column: :api_id)
    end
  end
end

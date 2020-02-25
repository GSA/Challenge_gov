defmodule ChallengeGov.Repo.Migrations.ChangeFiscalYearToString do
  use Ecto.Migration

  def up do
    alter table(:challenges) do
      modify :fiscal_year, :string
    end
  end

  def down do
    alter table(:challenges) do
      modify :fiscal_year, :integer
    end
  end
end

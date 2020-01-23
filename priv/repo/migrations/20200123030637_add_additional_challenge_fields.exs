defmodule ChallengeGov.Repo.Migrations.AddAdditionalChallengeFields do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add(:terms_and_conditions, :text)
      add(:non_monetary_prizes, :text)
      add(:federal_partners, :text)
      add(:non_federal_partners, :text)
    end
  end
end

defmodule ChallengeGov.Repo.Migrations.AddTermsAndAgencyIdToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:terms_of_use, :utc_datetime)
      add(:privacy_guidelines, :utc_datetime)
      add(:agency_id, references(:agencies))
    end
  end
end

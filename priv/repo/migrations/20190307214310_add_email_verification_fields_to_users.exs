defmodule ChallengeGov.Repo.Migrations.AddEmailVerificationFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:email_verification_token, :string)
      add(:email_verified_at, :utc_datetime)
    end
  end
end

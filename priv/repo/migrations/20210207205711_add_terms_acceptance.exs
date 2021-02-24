defmodule ChallengeGov.Repo.Migrations.AddTermsAcceptance do
  use Ecto.Migration

  def change do
    alter table(:solutions) do
      add :terms_accepted, :boolean
      add :review_verified, :boolean
    end
  end
end

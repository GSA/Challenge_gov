defmodule ChallengeGov.Repo.Migrations.AddRenewalRequestToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :renewal_request, :string
    end
  end
end

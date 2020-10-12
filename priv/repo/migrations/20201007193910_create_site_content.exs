defmodule ChallengeGov.Repo.Migrations.CreateSiteContent do
  use Ecto.Migration

  def change do
    create table(:site_content) do
      add :section, :string
      add :content, :text
      add :content_delta, :text
    end

    create index(:site_content, :section, unique: true)
  end
end

defmodule ChallengeGov.Repo.Migrations.InsertChallengeWizardInfoContent do
  use Ecto.Migration

  def up do
    execute "INSERT INTO site_content (section) values ('challenge_wizard_info')"
  end

  def down do
  end
end

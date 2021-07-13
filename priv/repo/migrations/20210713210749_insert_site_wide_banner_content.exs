defmodule ChallengeGov.Repo.Migrations.InsertSiteWideBannerContent do
  use Ecto.Migration

  def up do
    execute "INSERT INTO site_content (section) values ('site_wide_banner')"
  end

  def down do
    execute "DELETE from site_content where section = ('site_wide_banner')"
  end
end

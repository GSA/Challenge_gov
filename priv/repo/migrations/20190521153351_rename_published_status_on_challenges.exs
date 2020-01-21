defmodule ChallengeGov.Repo.Migrations.RenamePublishedStatusOnChallenges do
  use Ecto.Migration

  def up do
    execute "update challenges set status = 'created' where status = 'published';"
  end

  def down do
    execute "update challenges set status = 'published' where status = 'created';"
  end
end

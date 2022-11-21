defmodule ChallengeGov.Repo.Migrations.NumberOfSubmissionsChallenge do
  use Ecto.Migration

  def up do
    execute """
    CREATE OR REPLACE VIEW NumberOfSubmissionsChallenge AS
    select c.id challenge_id, c.title challenge_name, c.inserted_at created_date, 'Full' listing_type,
    (select count(*) from submissions where challenge_id = c.id) submissions,
    CURRENT_TIMESTAMP
    from challenges c
    where (c.how_to_enter_link is null) and (c.external_url is null)
    order by created_date asc
    ;
    """
  end

  def down do
    execute "drop view if exists NumberOfSubmissionsChallenge;"
  end
end

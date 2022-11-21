defmodule ChallengeGov.Repo.Migrations.PublishActiveChallenges do
  use Ecto.Migration

  def up do
    execute """
    CREATE VIEW PublishActiveChallenges AS
    select c.id challenge_id, c.title challenge_Name,
    a.name agency_name, c.agency_id,
    c.prize_total prize_amount,
    c.inserted_at created_date,
    c.published_on published_date,
    c.status,
    case
      when not(c.how_to_enter_link is NULL) and not(c.external_url is NULL) then 'Tile only'
      when not(c.how_to_enter_link is NULL) and c.external_url is null then 'Hybid'
      when (c.how_to_enter_link is NULL) and c.external_url is null then 'Full'
    end as listing_type,
    c.primary_type challenge_type,
    c.gov_delivery_subscribers challenge_suscribers,
    (select count(*) from submissions where challenge_id = c.id) as submissions,
    '2020-01-01' start_date,
    '2020-01-01' end_date,
    CURRENT_TIMESTAMP
    from challenges c
    left join agencies a on c.agency_id = a.id

    ;
    """
  end

  def down do
    execute "DROP VIEW PublishActiveChallenges;"
  end
end

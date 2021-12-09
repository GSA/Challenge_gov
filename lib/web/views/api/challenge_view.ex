defmodule Web.Api.ChallengeView do
  use Web, :view

  alias ChallengeGov.Challenges
  alias ChallengeGov.GovDelivery
  alias Web.Api.PaginationView
  alias Web.ChallengeView

  def render("index.json", assigns = %{challenges: challenges, pagination: _pagination}) do
    %{
      collection: render_many(challenges, __MODULE__, "card.json", assigns),
      pagination: render(PaginationView, "pagination.json", assigns)
    }
  end

  def render("index.json", assigns = %{challenges: challenges}) do
    %{
      collection: render_many(challenges, __MODULE__, "card.json", assigns)
    }
  end

  def render("card.json", %{challenge: challenge}) do
    %{
      id: challenge.id,
      uuid: challenge.uuid,
      title: challenge.title,
      tagline: challenge.tagline,
      custom_url: challenge.custom_url,
      external_url: challenge.external_url,
      agency_name: ChallengeView.agency_name(challenge),
      agency_logo: ChallengeView.agency_logo(challenge),
      logo: ChallengeView.logo_url(challenge),
      logo_alt_text: challenge.logo_alt_text,
      open_until: Challenges.find_end_date(challenge),
      start_date: challenge.start_date,
      end_date: challenge.end_date,
      announcement_datetime: challenge.announcement_datetime,
      is_archived: Challenges.is_archived_new?(challenge),
      is_closed: Challenges.is_closed?(challenge),
      imported: challenge.imported,
      sub_status: challenge.sub_status,
      phases:
        render_many(
          challenge.phases,
          Web.Api.PhaseView,
          "show.json"
        )
    }
  end

  def render("show.json", %{challenge: challenge}) do
    to_json(challenge)
  end

  def render("federal_partner_agencies.json", %{agency: %{agency: agency, sub_agency: nil}}) do
    logo = if agency.avatar_key, do: Web.AgencyView.avatar_url(agency), else: nil

    %{
      id: agency.id,
      name: agency.name,
      logo: logo
    }
  end

  def render("federal_partner_agencies.json", %{agency: %{sub_agency: sub_agency}}) do
    logo = if sub_agency.avatar_key, do: Web.AgencyView.avatar_url(sub_agency), else: nil

    %{
      id: sub_agency.id,
      name: sub_agency.name,
      logo: logo
    }
  end

  def render("non_federal_partners.json", %{partner: partner}) do
    %{
      id: partner.id,
      name: partner.name
    }
  end

  def render("event.json", %{event: event}) do
    %{
      id: event.id,
      title: event.title,
      occurs_on: event.date
    }
  end

  def to_json(challenge) do
    %{
      agency_id: challenge.agency_id,
      agency_name: ChallengeView.agency_name(challenge),
      agency_logo: ChallengeView.agency_logo(challenge),
      announcement: challenge.announcement,
      announcement_datetime: challenge.announcement_datetime,
      brief_description: HtmlSanitizeEx.basic_html(challenge.brief_description),
      custom_url: challenge.custom_url,
      description: HtmlSanitizeEx.basic_html(challenge.description),
      eligibility_requirements: HtmlSanitizeEx.basic_html(challenge.eligibility_requirements),
      end_date: challenge.end_date,
      upload_logo: challenge.upload_logo,
      events:
        render_many(
          challenge.timeline_events,
          __MODULE__,
          "event.json",
          as: :event
        ),
      external_url: challenge.external_url,
      federal_partners:
        render_many(
          challenge.federal_partners,
          __MODULE__,
          "federal_partner_agencies.json",
          as: :agency
        ),
      fiscal_year: challenge.fiscal_year,
      faq: challenge.faq,
      how_to_enter: HtmlSanitizeEx.basic_html(challenge.how_to_enter),
      how_to_enter_link: challenge.how_to_enter_link,
      id: challenge.id,
      is_archived: Challenges.is_archived_new?(challenge),
      is_closed: Challenges.is_closed?(challenge),
      judging_criteria: HtmlSanitizeEx.basic_html(challenge.judging_criteria),
      legal_authority: challenge.legal_authority,
      logo: ChallengeView.logo_url(challenge),
      logo_alt_text: challenge.logo_alt_text,
      imported: challenge.imported,
      multi_phase: challenge.multi_phase,
      non_federal_partners:
        render_many(
          challenge.non_federal_partners,
          __MODULE__,
          "non_federal_partners.json",
          as: :partner
        ),
      non_monetary_prizes: challenge.non_monetary_prizes,
      number_of_phases: challenge.number_of_phases,
      open_until: Challenges.find_end_date(challenge),
      phases:
        render_many(
          challenge.phases,
          Web.Api.PhaseView,
          "show.json"
        ),
      phase_dates: challenge.phase_dates,
      phase_descriptions: challenge.phase_descriptions,
      poc_email: challenge.poc_email,
      prize_description: challenge.prize_description,
      prize_total: challenge.prize_total,
      prize_type: challenge.prize_type,
      rules: challenge.rules,
      start_date: challenge.start_date,
      status: challenge.status,
      sub_status: challenge.sub_status,
      supporting_documents:
        render_many(
          challenge.supporting_documents,
          Web.Api.DocumentView,
          "show.json"
        ),
      tagline: challenge.tagline,
      terms_and_conditions: challenge.terms_and_conditions,
      terms_equal_rules: challenge.terms_equal_rules,
      title: challenge.title,
      types: challenge.types,
      primary_type: challenge.primary_type,
      other_type: challenge.other_type,
      uuid: challenge.uuid,
      winner_information: challenge.winner_information,
      winner_image: ChallengeView.winner_img_url(challenge),
      gov_delivery_topic_subscribe_link: GovDelivery.public_subscribe_link(challenge),
      subscriber_count: Challenges.subscriber_count(challenge),
      short_url: challenge.short_url
    }
  end
end

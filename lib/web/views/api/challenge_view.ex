defmodule Web.Api.ChallengeView do
  use Web, :view

  alias Web.Api.PaginationView
  alias Web.ChallengeView

  def render("index.json", assigns = %{challenges: challenges}) do
    %{
      collection: render_many(challenges, __MODULE__, "card.json", assigns),
      pagination: render(PaginationView, "pagination.json", assigns)
    }
  end

  def render("card.json", %{challenge: challenge}) do
    %{
      id: challenge.id,
      title: challenge.title,
      tagline: challenge.tagline,
      agency_name: ChallengeView.agency_name(challenge),
      agency_logo: ChallengeView.agency_logo(challenge),
      logo: ChallengeView.logo_url(challenge),
      open_until: challenge.end_date
    }
  end

  def render("show.json", %{challenge: challenge}) do
    %{
      agency_id: challenge.agency_id,
      agency_name: ChallengeView.agency_name(challenge),
      agency_logo: ChallengeView.agency_logo(challenge),
      brief_description: challenge.brief_description,
      custom_url: challenge.custom_url,
      description: challenge.description,
      eligibility_requirements: challenge.eligibility_requirements,
      end_date: challenge.end_date,
      events: challenge.non_monetary_prizes,
      external_url: challenge.external_url,
      federal_partners:
        render_many(
          challenge.federal_partner_agencies,
          __MODULE__,
          "federal_partner_agencies.json",
          as: :agency
        ),
      fiscal_year: challenge.fiscal_year,
      faq: challenge.faq,
      how_to_enter: challenge.how_to_enter,
      id: challenge.id,
      judging_criteria: challenge.judging_criteria,
      legal_authority: challenge.legal_authority,
      logo: ChallengeView.logo_url(challenge),
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
      phase_dates: challenge.phase_dates,
      phase_descriptions: challenge.phase_descriptions,
      poc_email: challenge.poc_email,
      prize_description: challenge.prize_description,
      prize_total: challenge.prize_total,
      rules: challenge.rules,
      start_date: challenge.custom_url,
      status: challenge.status,
      supporting_documents:
        render_many(
          challenge.supporting_documents,
          Web.Api.DocumentView,
          "show.json"
        ),
      tagline: challenge.tagline,
      terms_and_conditions: challenge.terms_and_conditions,
      title: challenge.title,
      types: challenge.types,
      winner_information: challenge.winner_information,
      winner_image: ChallengeView.winner_img_url(challenge)
    }
  end

  def render("federal_partner_agencies.json", %{agency: agency}) do
    logo = if agency.avatar_key, do: Web.AgencyView.avatar_url(agency), else: nil

    %{
      id: agency.id,
      name: agency.name,
      logo: logo
    }
  end

  def render("non_federal_partners.json", %{partner: partner}) do
    %{
      id: partner.id,
      name: partner.name
    }
  end
end

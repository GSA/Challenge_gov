defmodule Web.Api.ChallengeView do
  use Web, :view

  alias Web.ChallengeView
  alias Web.Api.PaginationView

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
      logo: ChallengeView.logo_url(challenge),
      open_until: challenge.end_date
    }
  end

  def render("show.json", %{challenge: challenge}) do
    %{
      prize_total: challenge.prize_total,
      winner_information: challenge.winner_information,
      winner_image_key: challenge.winner_image_key,
      poc_email: challenge.poc_email,
      how_to_enter: challenge.how_to_enter,
      number_of_phases: challenge.number_of_phases,
      faq: challenge.faq,
      title: challenge.title,
      logo: challenge.logo,
      logo_key: challenge.logo_key,
      end_date: challenge.end_date,
      eligibility_requirements: challenge.eligibility_requirements,
      fiscal_year: challenge.fiscal_year,
      terms_and_conditions: challenge.terms_and_conditions,
      judging_criteria: challenge.judging_criteria,
      multi_phase: challenge.multi_phase,
      description: challenge.description,
      prize_description: challenge.prize_description,
      upload_logo: challenge.upload_logo,
      id: challenge.id,
      external_url: challenge.external_url,
      legal_authority: challenge.legal_authority,
      phase_descriptions: challenge.phase_descriptions,
      phase_dates: challenge.phase_dates,
      custom_url: challenge.custom_url,
      start_date: challenge.custom_url,
      non_monetary_prizes: challenge.non_monetary_prizes,
      events: challenge.non_monetary_prizes,
      status: challenge.status,
      type: challenge.type,
      logo_extension: challenge.logo_extension,
      supporting_documents: challenge.supporting_documents,
      winner_image_extension: challenge.winner_image_extension,
      brief_description: challenge.brief_description,
      tagline: challenge.tagline,
      agency_name: ChallengeView.agency_name(challenge),
      agency_id: challenge.agency_id,
      rules: challenge.rules,
      federal_partners:
        render_many(
          challenge.federal_partner_agencies,
          __MODULE__,
          "federal_partner_agencies.json",
          as: :agency
        ),
      non_federal_partners:
        render_many(
          challenge.non_federal_partners,
          __MODULE__,
          "non_federal_partners.json",
          as: :partner
        )
    }
  end

  def render("federal_partner_agencies.json", %{agency: agency}) do
    %{
      id: agency.id,
      name: agency.name
    }
  end

  def render("non_federal_partners.json", %{partner: partner}) do
    %{
      id: partner.id,
      name: partner.name
    }
  end
end

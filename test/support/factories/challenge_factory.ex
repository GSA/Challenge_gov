defmodule ChallengeGov.ChallengeFactory do
  @moduledoc """
  Allows us to create a `ChallengeGov.Agencies.Challenge` in tests, seeds or manually in iex.
  """
  # credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
  defmacro __using__(_opts) do
    quote do
      def challenge_factory(attrs) do
        user = attrs[:user] || insert(:user)
        agency = attrs[:agency] || insert(:agency)
        %ChallengeGov.Challenges.Challenge{
          user: user.id,
          agency: agency.id,
          sub_agency: agency.id,
          primary_type: attrs[:primary_type] || "Software and apps",
          types: attrs[:types] || nil,
          other_type: attrs[:other_type] || nil,
          status: attrs[:status] || "draft",
          sub_status: attrs[:substatus] || "open",
          last_section: attrs[:last_section] || "open",
          challenge_manager: attrs[:challenge_manager] || "Jimminy Cricket",
          challenge_manager_email: attrs[:challenge_manager_email] || "jimminy@cricket.com",
          poc_email: attrs[:poc_email] || "mr.jimminy@cricket.com",
          agency_name: attrs[:agency_name] || "Pinocchio",
          title: attrs[:title] || sequence("Da Best"),
          custom_url: attrs[:custom_url] || nil,
          external_url: attrs[:external_url] || "www.google.com",
          tagline: attrs[:tagline] || sequence("Da Best Tagline"),
          type: attrs[:type] || "Scientific",
          description: attrs[:description] || "Da Best Long Description",
          description_delta: attrs[:description_delta] || "I don't know what this is?",
          description_length: attrs[:description_length] || 100,
          brief_description: attrs[:brief_description] || "Da Best Brief Description",
          brief_description_delta:
            attrs[:brief_description_delta] || "I don't know what this is?",
          brief_description_length: attrs[:brief_description_length] || 100,
          how_to_enter: attrs[:how_to_enter] || "Do it",
          fiscal_year: attrs[:fiscal_year] || "FY20",
          start_date: attrs[:start_date] || DateTime.utc_now(),
          end_date: attrs[:end_date] || DateTime.utc_now(),
          archive_date: attrs[:archive_date] || nil,
          multi_phase: attrs[:multi_phase] || false,
          number_of_phases: attrs[:number_of_phases] || "1",
          phase_descriptions: attrs[:phase_descriptions] || "20",
          phase_dates: attrs[:phase_dates] || nil,
          judging_criteria: attrs[:judging_criteria] || "Do it",
          prize_type: attrs[:prize_type] || "Monetary",
          prize_total: attrs[:prize_total] || 20_000,
          non_monetary_prizes: attrs[:non_monetary_prizes] || "Gummy Bears",
          prize_description: attrs[:prize_description] || "Gummiest",
          prize_description_delta:
            attrs[:prize_description_delta] || "I don't know what this is.",
          prize_description_length: attrs[:prize_description_length] || 100,
          eligibility_requirements: attrs[:eligibility_requirements] || "Open the bag.",
          eligibility_requirements_delta: attrs[:eligibility_requirements_delta] || "Delta?",
          rules: attrs[:rules] || "Made to be broken",
          rules_delta: attrs[:rules_delta] || "Delta?",
          terms_and_conditions:
            attrs[:terms_and_conditions] || "Win more betterer than the others do.",
          terms_and_conditions_delta:
            attrs[:terms_and_conditions_delta] || "Again witht he deltas! Oy Vey!",
          legal_authority: attrs[:legal_authority] || "Me",
          faq: attrs[:faq] || "Don't ask any questions",
          faq_delta: attrs[:faq_delta] || "hmmm?",
          faq_length: attrs[:faq_length] || 100,
          winner_information: attrs[:winner_information] || "I'll be the winner",
          captured_on: attrs[:captured_on] || Date.new!(2000, 01, 01),
          auto_publish_date: attrs[:auto_publish_date] || DateTime.utc_now(),
          published_on: attrs[:published_on] || Date.new!(2000, 01, 01),
          rejection_message:
            attrs[:rejection_message] ||
              "It's not you, it's me. I'm just not ready for this level of commitment",
          how_to_enter_link: attrs[:how_to_enter_link] || "www.google.com",
          announcement: attrs[:announcement] || "LOUD NOISES!",
          announcement_datetime: attrs[:announcement_datetime] || DateTime.utc_now(),
          gov_delivery_topic: attrs[:gov_delivery_topic] || "Snickers, all about it",
          gov_delivery_subscribers: attrs[:gov_delivery_subscribers] || 100,
          short_url: attrs[:short_url] || "www.short.com",
          upload_logo: attrs[:upload_logo] || false,
          is_multi_phase: attrs[:is_multi_phase] || false,
          terms_equal_rules: attrs[:terms_equal_rules] || false,
          imported: attrs[:imported] || false,
          deleted_at: attrs[:deleted_at] || nil
        }
      end
    end
  end
end

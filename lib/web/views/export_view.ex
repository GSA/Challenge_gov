NimbleCSV.define(ChallengeGov.Export.CSV, separator: ",", escape: "\"")

defmodule Web.ExportView do
  use Web, :view

  alias ChallengeGov.Export.CSV
  alias Web.Api.ChallengeView

  def format_content(challenge, format) do
    case format do
      "json" ->
        {:ok, challenge_json(challenge)}

      "csv" ->
        {:ok, challenge_csv(challenge)}

      _ ->
        {:error, :invalid_format}
    end
  end

  def challenge_csv(challenge),
    do: CSV.dump_to_iodata([csv_headers(challenge), csv_content(challenge)])

  defp csv_headers(challenge) do
    [
      "ID",
      "UUID",
      "Status",
      "Managers",
      "Challenge manager of record",
      "Challenge manager email",
      "Point of contact email",
      "Lead agency",
      "Federal partners",
      "Non federal partners",
      "Fiscal year",
      "Title",
      "Tagline",
      "Types",
      "Custom url",
      "External url",
      "Brief description",
      "Description",
      # "Supporting documents",
      # "Uploading own logo",
      # "Logo",
      "Auto publish date",
      "Multi phase challenge"
    ]
    |> Enum.concat(phase_headers(challenge))
    |> Enum.concat(timeline_headers(challenge))
    |> Enum.concat([
      "Prize type",
      "Prize total",
      "Non monetary prizes",
      "Prize description",
      "Eligibility requirements",
      "Terms same as rules",
      "Rules",
      "Terms and conditions",
      "Legal authority",
      "Frequently asked questions"
    ])
  end

  defp csv_content(challenge) do
    [
      challenge.id,
      challenge.uuid,
      Web.ChallengeView.status_display_name(challenge),
      Web.ChallengeView.challenge_managers_list(challenge),
      challenge.challenge_manager,
      challenge.challenge_manager_email,
      challenge.poc_email,
      Web.ChallengeView.agency_name(challenge),
      Web.ChallengeView.federal_partners_list(challenge),
      Web.ChallengeView.non_federal_partners_list(challenge),
      challenge.fiscal_year,
      challenge.title,
      challenge.tagline,
      Web.ChallengeView.types(challenge),
      Web.ChallengeView.custom_url(challenge),
      challenge.external_url,
      challenge.brief_description,
      challenge.description,
      challenge.auto_publish_date,
      challenge.is_multi_phase
    ]
    |> Enum.concat(phase_data(challenge))
    |> Enum.concat(timeline_data(challenge))
    |> Enum.concat([
      challenge.prize_type,
      challenge.prize_total,
      challenge.non_monetary_prizes,
      challenge.prize_description,
      challenge.eligibility_requirements,
      challenge.terms_equal_rules,
      challenge.rules,
      challenge.terms_and_conditions,
      challenge.legal_authority,
      challenge.faq
    ])
  end

  defp phase_headers(challenge) do
    phases = challenge.phases

    if length(phases) > 0 do
      Enum.reduce(1..length(phases), [], fn phase_number, headers ->
        Enum.concat(headers, [
          "Phase #{phase_number} title",
          "Phase #{phase_number} start date",
          "Phase #{phase_number} end date",
          "Phase #{phase_number} open to submissions",
          "Phase #{phase_number} judging criteria",
          "Phase #{phase_number} how to enter"
        ])
      end)
    else
      []
    end
  end

  defp phase_data(challenge) do
    phases = challenge.phases

    if length(phases) > 0 do
      Enum.reduce(phases, [], fn phase, headers ->
        Enum.concat(headers, [
          phase.title,
          phase.start_date,
          phase.end_date,
          phase.open_to_submissions,
          phase.judging_criteria,
          phase.how_to_enter
        ])
      end)
    else
      []
    end
  end

  defp timeline_headers(challenge) do
    events = challenge.timeline_events

    if length(events) > 0 do
      Enum.reduce(1..length(events), [], fn event_number, headers ->
        Enum.concat(headers, [
          "Timeline event #{event_number} title",
          "Timeline event #{event_number} date"
        ])
      end)
    else
      []
    end
  end

  defp timeline_data(challenge) do
    events = challenge.timeline_events

    if length(events) > 0 do
      Enum.reduce(events, [], fn event, headers ->
        Enum.concat(headers, [
          event.title,
          event.date
        ])
      end)
    else
      []
    end
  end

  def challenge_json(challenge) do
    {:ok, json} =
      challenge
      |> ChallengeView.to_json()
      |> Jason.encode()

    json
  end
end

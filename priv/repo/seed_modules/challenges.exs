defmodule Seeds.SeedModules.Challenges do
  alias ChallengeGov.Accounts
  alias ChallengeGov.Agencies
  alias ChallengeGov.Challenges

  @remote_ip "127.0.0.1"

  def run() do
    IO.inspect "Seeding Challenges"

    {:ok, challenge_manager} = Accounts.get_by_email("challenge_manager_active@example.gov")

    {:ok, agency} = Agencies.get_by_name("Department of Agriculture")
    {:ok, sub_agency} = Agencies.get_by_name("Agricultural Marketing Service")

    {:ok, fed_partner_agency} = Agencies.get_by_name("Department of Agriculture")
    {:ok, fed_partner_sub_agency} = Agencies.get_by_name("Animal and Plant Health Inspection Service")

    federal_partners = [{fed_partner_agency, fed_partner_sub_agency}]

    [
      generate_challenge(challenge_manager, agency, sub_agency: sub_agency, federal_partners: federal_partners, non_fed_count: 2, timeline_event_count: 3),
      generate_challenge(challenge_manager, agency, sub_agency: sub_agency, federal_partners: federal_partners, non_fed_count: 2, phase_count: 3)
    ]
  end

  defp generate_challenge(user, agency, opts \\ []) do
    user
    |> general_step(agency, opts)
    |> details_step(user, opts)
    |> timeline_step(user, opts)
    |> prizes_step(user, opts)
    |> rules_step(user)
    |> judging_step(user)
    |> how_to_enter_step(user)
    |> resources_step(user)
    |> submit_step(user)
  end

  # Wizard Step Functions
  defp general_step(user, agency, opts) do
    sub_agency = Keyword.get(opts, :sub_agency, %{id: nil})
    federal_partners = Keyword.get(opts, :federal_partners, [])
    non_fed_count = Keyword.get(opts, :non_fed_count, 0)

    {:ok, challenge} = 
      Challenges.create(%{
        "action" => "next",
        "challenge" => %{
          "local_timezone" => "America/New_York",
          "section" => "general",
          "user_id" => user.id,
          "challenge_manager" => "Challenge Manager",
          "challenge_manager_email" => user.email,
          "poc_email" => user.email,
          "agency_id" => agency.id,
          "sub_agency_id" => sub_agency.id,
          "federal_partners" => generate_federal_partners_params(federal_partners),
          "non_federal_partners" => generate_non_federal_partners_params(non_fed_count),
          "fiscal_year" => "FY20"
        }
      }, user, @remote_ip)

    challenge
  end

  defp details_step(challenge, user, opts) do
    primary_type = Keyword.get(opts, :primary_type, "Analytics, visualizations, algorithms")
    types = Keyword.get(opts, :types, ["Software and apps", "Scientific", "Creative (multimedia & design)"])
    other_type = Keyword.get(opts, :other_type, "Oceanic")
    custom_url = Keyword.get(opts, :custom_url, nil)
    external_url = Keyword.get(opts, :custom_url, "https://www.example.com")
    phase_count = Keyword.get(opts, :phase_count, 1)

    {:ok, challenge} = 
      Challenges.update(challenge, %{
        "action" => "next",
        "challenge" => %{
          "local_timezone" => "America/New_York",
          "section" => "details",
          "title" => generate_title(challenge, phase_count),
          "tagline" => "Tagline for challenge #{challenge.id}",
          "primary_type" => primary_type,
          "types" => types,
          "other_type" => other_type,
          "custom_url" => custom_url,
          "external_url" => external_url,
          "brief_description" => "<p>Short description for challenge #{challenge.id}</p>",
          "brief_description_delta" => "{\"ops\":[{\"insert\":\"Short description for challenge #{challenge.id}\\n\"}]}",
          "description" => "<p>Long description for challenge #{challenge.id}</p>",
          "description_delta" => "{\"ops\":[{\"insert\":\"Long description for challenge #{challenge.id}\\n\"}]}",
          "upload_logo" => "false",
          "auto_publish_date" => generate_auto_publish_date(),
          "is_multi_phase" => generate_is_multi_phase(phase_count),
          "phases" => generate_initial_phase_params(phase_count),
        }, 
      }, user, @remote_ip)
    
    challenge
  end

  defp timeline_step(challenge, user, opts) do
    timeline_event_count = Keyword.get(opts, :timeline_event_count, 0)

    {:ok, challenge} = 
      Challenges.update(challenge, %{
        "action" => "next",
        "challenge" => %{
          "local_timezone" => "America/New_York",
          "section" => "timeline",
          "timeline_events" => generate_timeline_event_params(timeline_event_count)
        }
      }, user, @remote_ip)

    challenge
  end

  defp prizes_step(challenge, user, opts) do
    prize_type = Keyword.get(opts, :prize_type, "both")
    prize_total = Keyword.get(opts, :prize_total, "$100,000")
    non_monetary_prizes = Keyword.get(opts, :non_monetary_prizes, "Computers")

    {:ok, challenge} = 
      Challenges.update(challenge, %{
        "action" => "next",
        "challenge" => %{
          "local_timezone" => "America/New_York",
          "section" => "prizes",
          "prize_type" => prize_type,
          "prize_total" => prize_total,
          "non_monetary_prizes" => non_monetary_prizes,
          "prize_description" => "<p>Prize description for challenge #{challenge.id}</p>",
          "prize_description_delta" => "{\"ops\":[{\"insert\":\"Prize description for challenge #{challenge.id}\\n\"}]}"
        }
      }, user, @remote_ip)

    challenge
  end

  defp rules_step(challenge, user) do
    {:ok, challenge} = 
      Challenges.update(challenge, %{
        "action" => "next",
        "challenge" => %{
          "local_timezone" => "America/New_York",
          "section" => "rules",
          "eligibility_requirements" => "<p>Eligibility requirements for challenge #{challenge.id}</p>",
          "eligibility_requirements_delta" => "{\"ops\":[{\"insert\":\"Eligibility requirements for challenge #{challenge.id}\\n\"}]}",
          "rules" => "<p>Rules for challenge #{challenge.id}</p>",
          "rules_delta" => "{\"ops\":[{\"insert\":\"Rules for challenge #{challenge.id}\\n\"}]}",
          "terms_equal_rules" => "true",
          # "terms_and_conditions" => "",
          # "terms_and_conditions_delta" => "",
          "legal_authority" => "Agency Prize Authority - DOT"
        }
      }, user, @remote_ip)

    challenge
  end

  defp judging_step(challenge, user) do
    {:ok, challenge} = 
      Challenges.update(challenge, %{
        "action" => "next",
        "challenge" => %{
          "local_timezone" => "America/New_York",
          "section" => "judging",
          "phases" => generate_phase_params(challenge, "judging")
        }
      }, user, @remote_ip)

    challenge
  end

  defp how_to_enter_step(challenge, user) do
    {:ok, challenge} = 
      Challenges.update(challenge, %{
        "action" => "next",
        "challenge" => %{
          "local_timezone" => "America/New_York",
          "section" => "how_to_enter",
          "phases" => generate_phase_params(challenge, "how_to_enter"),
          "how_to_enter_link" => "www.example.com"
        }
      }, user, @remote_ip)

    challenge
  end

  defp resources_step(challenge, user) do
    {:ok, challenge} = 
      Challenges.update(challenge, %{
        "action" => "next",
        "challenge" => %{
          "local_timezone" => "America/New_York",
          "section" => "resources",
          "faq" => "<p>FAQ for challenge #{challenge.id}</p>",
          "faq_delta" => "{\"ops\":[{\"insert\":\"FAQ for challenge #{challenge.id}\\n\"}]}"
        }
      }, user, @remote_ip)
    
    challenge
  end

  defp submit_step(challenge, user) do
    {:ok, challenge} = Challenges.submit(challenge, user, @remote_ip)

    challenge
  end

  # Generator Functions
  defp generate_federal_partners_params(federal_partners) do
    federal_partners
    |> Enum.with_index
    |> Enum.reduce(%{}, fn {{agency, sub_agency}, index}, acc ->
      Map.put(acc, index, federal_partners_params(agency, sub_agency))
    end)
  end

  defp federal_partners_params(agency, nil), do: %{"agency_id" => agency.id}
  defp federal_partners_params(agency, sub_agency), do: %{"agency_id" => agency.id, "sub_agency_id" => sub_agency.id}

  defp generate_non_federal_partners_params(count) do
    Enum.reduce(1..count, %{}, fn index, acc -> 
      Map.put(acc, index - 1, non_federal_partners_params(index))
    end)
  end

  defp non_federal_partners_params(index), do: %{"name" => "Non federal partner #{index}"}

  defp generate_title(challenge, phase_count) when phase_count == 1, do: "Challenge #{challenge.id} - Single Phase"
  defp generate_title(challenge, phase_count), do: "Challenge #{challenge.id} - Multi Phase"

  defp generate_auto_publish_date() do
    DateTime.utc_now()
    |> DateTime.add(60 * 60 * 24, :second)
    |> DateTime.to_string()
  end

  defp generate_is_multi_phase(count) when count == 1, do: "false"
  defp generate_is_multi_phase(count), do: "true"

  defp generate_initial_phase_params(count) do
    Enum.reduce(1..count, %{}, fn index, acc -> 
      Map.put(acc, index - 1, initial_phase_params(index, count))
    end)
  end

  defp initial_phase_params(index, count) do
    %{
      "title" => initial_phase_title(index, count),
      "start_date" => initial_phase_start_date(index),
      "end_date" => initial_phase_end_date(index),
      "open_to_submissions" => initial_phase_open_to_submissions(index)
    }
  end

  defp initial_phase_title(_index, 1), do: nil
  defp initial_phase_title(index, _count), do: "Phase #{index}"

  defp initial_phase_open_to_submissions(index) when index <= 2, do: "true"
  defp initial_phase_open_to_submissions(_index), do: "false"

  defp initial_phase_start_date(index) do
    DateTime.utc_now()
    |> DateTime.add(60 * 60 * 24 * (index - 1), :second)
    |> DateTime.to_string()
  end

  defp initial_phase_end_date(index) do
    DateTime.utc_now()
    |> DateTime.add(60 * 60 * 23 * index, :second)
    |> DateTime.to_string()
  end

  defp generate_timeline_event_params(count) when count === 0, do: %{}

  defp generate_timeline_event_params(count) do
    Enum.reduce(1..count, %{}, fn index, acc -> 
      Map.put(acc, index - 1, timeline_event_params(index))
    end)
  end

  defp timeline_event_params(index) do
    %{
      "title" => "Timeline event #{index}",
      "date" => timeline_event_date(index)
    }
  end

  defp timeline_event_date(index) do
    DateTime.utc_now()
    |> DateTime.add(60 * 60 * 24 * index, :second)
    |> DateTime.to_string()
  end

  defp generate_phase_params(challenge, section) do
    challenge.phases
    |> Enum.with_index(1)
    |> Enum.reduce(%{}, fn {phase, index}, acc -> 
      Map.put(acc, phase.id, phase_params(phase, index, section))
    end)
  end

  defp phase_params(phase, index, "judging") do
    %{
      "id" => phase.id,
      "judging_criteria" => "<p>Phase #{index} judging</p>",
      "judging_criteria_delta" => "{\"ops\":[{\"insert\":\"Phase #{index} judging\\n\"}]}"
    }
  end

  defp phase_params(phase, index, "how_to_enter") do
    %{
      "id" => phase.id,
      "how_to_enter" => "<p>Phase #{index} how to enter</p>",
      "how_to_enter_delta" => "{\"ops\":[{\"insert\":\"Phase #{index} how to enter\\n\"}]}",
    }
  end
end
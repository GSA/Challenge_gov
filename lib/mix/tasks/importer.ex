defmodule Mix.Tasks.ClosedChallengeImporter do
  @moduledoc """
  Importer for archived challenges
  """
  use Mix.Task
  alias ChallengeGov.Agencies

  def run(_file) do
    Mix.Task.run("app.start")

    case File.read!("lib/mix/tasks/sample_data/feed-closed.json") do
      {:ok, binary} ->
        case Jason.decode(binary) do
          {:ok, challenge} ->
            # create archived challenge
            create_challenge(challenge)

          {:error, error} ->
            # then what?
            IO.inspect error
        end

      {:error, error} ->
        IO.inspect error
    end
  end

  def create_challenge(json) do
    Challenges.create(%{
      "status" => "closed",
      "challenge_manager" => json["challenge-manager,"],
      "challenge_manager_email" => json["challenge-manager-email"],
      "poc_email" => json["point-of-contact"],
      "agency_id" => match_agency(json["agency"], json["agency-logo"]),
      "external_logo" => json["card-image"],
      "federal_partners" => match_federal_partners(json["partner-agencies-federal"]),
      "non_federal_partners" => match_non_federal_partners(json["partners-non-federal"]),
      "title" => json["challenge-title"],
      "external_url" => json["external-url"],
      "tagline" => json["tagline"],
      "description" => json["description"],
      "how_to_enter" => json["how-to-enter"],
      "fiscal_year" => json["fiscal-year"],
      "start_date" => json["submission-start"],
      "end_date" => json["submission-end"],
      "judging_criteria" => json["judging"],
      "prize_total" => json["total-prize-offered-cash"],
      "non_monetary_prizes" => json["prizes"],
      "rules" => json["rules"],
      "legal_authority" => json["legal-authority"],
      "types" => json["type-of-challenge"]
    })
  end

  def match_agency(name, logo \\ nil) do
    case Agencies.get_by_name(name) do
      {:ok, agency} ->
        agency.id

      {:error, :not_found} ->
        fuzzy_match_agency(name, logo)
    end
  end

  def fuzzy_match_agency(name, logo \\ nil) do
    agencies = Agencies.all_for_select

    match = Enum.find(agencies, fn x ->
      String.jaro_distance(x.name, name) >= 0.9
    end)

    if !is_nil(match) do
      match.id

    else
      create_new_agency(name, logo)
    end
  end

  defp create_new_agency(name, logo) when is_nil(logo) do
    Agencies.create(:saved_to_file, %{
      "name" => "#{name}"
      })
  end

  defp create_new_agency(name, logo) do
    filename = List.last(String.split(logo, "/"))
    extension = ".#{List.last(String.split(filename, "."))}"

    with {:ok, :saved_to_file} <- :httpc.request(:get, {"https://www.challenge.gov/assets/netlify-uploads/#{filename}", []}, [], [stream: '/tmp/elixir']) do
      Agencies.create(:saved_to_file, %{
        "avatar" => %Plug.Upload{
          content_type: "image/#{extension}",
          filename: "hhs.png",
          path: "/tmp/elixir/#{filename}"
        },
        "name" => "#{name}"
        }
      )
    end
  end

  def match_federal_partners(partners) do
    partner_list = String.split(partners, ",")
    Enum.map(partner_list, fn x ->
      match_agency(String.trim(x))
    end)
  end

  def match_non_federal_partners(string) do
    # "EPA Region 7 and 8 states, Regional Tribal Operations Committees"
    # "California Governor’s Office of Emergency Services, CAL Fire, Cal Guard, MAXAR/Digital Globe"

    # need challenge_id and id...?
  end
end

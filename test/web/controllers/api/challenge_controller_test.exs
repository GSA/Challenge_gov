defmodule Web.Api.ChallengeControllerTest do
  use Web.ConnCase

  alias ChallengeGov.Challenges

  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.AgencyHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers

  describe "retrieving JSON list of published challenges" do
    test "successfully", %{conn: conn} do
      user = AccountHelpers.create_user()
      agency = AgencyHelpers.create_agency()

      ChallengeHelpers.create_single_phase_challenge(user, %{
        user_id: user.id,
        agency_id: agency.id,
        title: "Test Title 1",
        status: "published"
      })

      ChallengeHelpers.create_single_phase_challenge(user, %{
        user_id: user.id,
        agency_id: agency.id,
        title: "Test Title 2",
        status: "published"
      })

      ChallengeHelpers.create_single_phase_challenge(user, %{
        user_id: user.id,
        agency_id: agency.id,
        title: "Test Title 3",
        status: "archived"
      })

      ChallengeHelpers.create_single_phase_challenge(user, %{
        user_id: user.id,
        agency_id: agency.id,
        title: "Test Title 4",
        status: "draft"
      })

      conn = get(conn, Routes.api_challenge_path(conn, :index))
      assert length(json_response(conn, 200)["collection"]) === 2
    end

    test "no results", %{conn: conn} do
      conn = get(conn, Routes.api_challenge_path(conn, :index))
      assert length(json_response(conn, 200)["collection"]) === 0
    end
  end

  describe "retrieving JSON list of archived challenges" do
    test "successfully", %{conn: conn} do
      user = AccountHelpers.create_user()

      ChallengeHelpers.create_single_phase_challenge(user, %{
        user_id: user.id
      })

      ChallengeHelpers.create_multi_phase_challenge(user, %{user_id: user.id})

      ChallengeHelpers.create_open_multi_phase_challenge(user, %{user_id: user.id})

      ChallengeHelpers.create_closed_multi_phase_challenge(user, %{user_id: user.id})

      ChallengeHelpers.create_archived_multi_phase_challenge(user, %{user_id: user.id})

      conn = get(conn, Routes.api_challenge_path(conn, :index, archived: true))
      assert length(json_response(conn, 200)["collection"]) === 2
    end

    test "no results", %{conn: conn} do
      conn = get(conn, Routes.api_challenge_path(conn, :index), archived: true)
      assert length(json_response(conn, 200)["collection"]) === 0
    end
  end

  describe "retrieving JSON details of a challenge" do
    test "successfully with published challenge", %{conn: conn} do
      user = AccountHelpers.create_user()
      agency = AgencyHelpers.create_agency()

      challenge =
        ChallengeHelpers.create_challenge(%{
          user_id: user.id,
          agency_id: agency.id,
          title: "Test Title 1",
          description: "Test description 1",
          status: "published"
        })

      expected_json = expected_show_json(challenge)

      conn = get(conn, Routes.api_challenge_path(conn, :show, challenge.id))
      assert json_response(conn, 200) === expected_json
    end

    test "successfully with archived challenge", %{conn: conn} do
      user = AccountHelpers.create_user()
      agency = AgencyHelpers.create_agency()

      challenge =
        ChallengeHelpers.create_challenge(%{
          user_id: user.id,
          agency_id: agency.id,
          title: "Test Title 1",
          description: "Test description 1",
          status: "archived"
        })

      expected_json = expected_show_json(challenge)

      conn = get(conn, Routes.api_challenge_path(conn, :show, challenge.id))
      assert json_response(conn, 200) === expected_json
    end

    test "not found because challenge id doesn't exist", %{conn: conn} do
      user = AccountHelpers.create_user()
      agency = AgencyHelpers.create_agency()

      challenge =
        ChallengeHelpers.create_challenge(%{
          user_id: user.id,
          agency_id: agency.id,
          title: "Test Title 1",
          description: "Test description 1",
          status: "created"
        })

      expected_json = %{
        "errors" => "not_found"
      }

      conn = get(conn, Routes.api_challenge_path(conn, :show, challenge.id + 1))
      assert json_response(conn, 404) === expected_json
    end

    test "not found because challenge is still a draft", %{conn: conn} do
      user = AccountHelpers.create_user()
      agency = AgencyHelpers.create_agency()

      challenge =
        ChallengeHelpers.create_challenge(%{
          user_id: user.id,
          agency_id: agency.id,
          title: "Test Title 1",
          description: "Test description 1",
          status: "draft"
        })

      expected_json = %{
        "errors" => "not_found"
      }

      conn = get(conn, Routes.api_challenge_path(conn, :show, challenge.id))
      assert json_response(conn, 404) === expected_json
    end

    test "not found because challenge is still in review", %{conn: conn} do
      user = AccountHelpers.create_user()
      agency = AgencyHelpers.create_agency()

      challenge =
        ChallengeHelpers.create_challenge(%{
          user_id: user.id,
          agency_id: agency.id,
          title: "Test Title 1",
          description: "Test description 1",
          status: "pending"
        })

      expected_json = %{
        "errors" => "not_found"
      }

      conn = get(conn, Routes.api_challenge_path(conn, :show, challenge.id))
      assert json_response(conn, 404) === expected_json
    end
  end

  defp expected_show_json(challenge) do
    %{
      "description" => challenge.description,
      "id" => challenge.id,
      "title" => challenge.title,
      "legal_authority" => "Test legal authority",
      "phase_dates" => nil,
      "agency_id" => challenge.agency_id,
      "fiscal_year" => "FY20",
      "custom_url" => nil,
      "end_date" => nil,
      "prize_description" => "",
      "faq" => "",
      "multi_phase" => nil,
      "judging_criteria" => "",
      "status" => challenge.status,
      "agency_name" => challenge.agency.name,
      "supporting_documents" => [],
      "external_url" => nil,
      "eligibility_requirements" => "Test eligibility",
      "winner_information" => nil,
      "poc_email" => "test_poc@example.com",
      "rules" => "Test rules",
      "types" => [],
      "agency_logo" => "/images/agency-logo-placeholder.svg",
      "logo" => "/images/challenge-logo-2_1.svg",
      "terms_and_conditions" => "Test terms",
      "non_monetary_prizes" => nil,
      "how_to_enter" => "",
      "events" => [],
      "start_date" => nil,
      "non_federal_partners" => [],
      "number_of_phases" => nil,
      "winner_image" => nil,
      "tagline" => challenge.tagline,
      "prize_total" => nil,
      "brief_description" => challenge.brief_description,
      "phase_descriptions" => nil,
      "federal_partners" => [],
      "phases" => [],
      "open_until" => nil,
      "announcement" => nil,
      "announcement_datetime" => nil,
      "is_archived" => Challenges.is_archived_new?(challenge),
      "is_closed" => Challenges.is_closed?(challenge)
    }
  end
end

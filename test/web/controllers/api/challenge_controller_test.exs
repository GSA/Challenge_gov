defmodule Web.Api.ChallengeControllerTest do
  use Web.ConnCase

  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.AgencyHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers

  describe "retrieving JSON list of published challenges" do
    test "successfully", %{conn: conn} do
      user = AccountHelpers.create_user()
      agency = AgencyHelpers.create_agency()

      ChallengeHelpers.create_challenge(%{
        user_id: user.id,
        agency_id: agency.id,
        title: "Test Title 1",
        status: "published"
      })

      ChallengeHelpers.create_challenge(%{
        user_id: user.id,
        agency_id: agency.id,
        title: "Test Title 2",
        status: "published"
      })

      ChallengeHelpers.create_challenge(%{
        user_id: user.id,
        agency_id: agency.id,
        title: "Test Title 3",
        status: "archived"
      })

      ChallengeHelpers.create_challenge(%{
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
      "legal_authority" => nil,
      "phase_dates" => nil,
      "agency_id" => challenge.agency_id,
      "fiscal_year" => nil,
      "custom_url" => nil,
      "end_date" => nil,
      "prize_description" => nil,
      "faq" => nil,
      "multi_phase" => nil,
      "judging_criteria" => nil,
      "status" => challenge.status,
      "agency_name" => challenge.agency.name,
      "supporting_documents" => [],
      "external_url" => nil,
      "eligibility_requirements" => nil,
      "winner_information" => nil,
      "poc_email" => nil,
      "rules" => nil,
      "types" => [],
      "agency_logo" => nil,
      "logo" => nil,
      "terms_and_conditions" => nil,
      "non_monetary_prizes" => nil,
      "how_to_enter" => nil,
      "events" => nil,
      "start_date" => nil,
      "non_federal_partners" => [],
      "number_of_phases" => nil,
      "winner_image" => nil,
      "tagline" => challenge.tagline,
      "prize_total" => nil,
      "brief_description" => challenge.brief_description,
      "phase_descriptions" => nil,
      "federal_partners" => []
    }
  end
end

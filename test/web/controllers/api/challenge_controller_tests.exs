defmodule Web.Api.ChallengeControllerTests do
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
        status: "created"
      })

      ChallengeHelpers.create_challenge(%{
        user_id: user.id,
        agency_id: agency.id,
        title: "Test Title 2",
        status: "created"
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
          status: "created"
        })

      expected_json = %{
        "id" => challenge.id,
        "title" => "Test Title 1",
        "description" => "Test description 1"
      }

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

      expected_json = %{
        "id" => challenge.id,
        "title" => "Test Title 1",
        "description" => "Test description 1"
      }

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
end

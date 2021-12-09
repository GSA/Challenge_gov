defmodule Web.Api.ChallengeControllerTest do
  use Web.ConnCase
  use Web, :view

  alias ChallengeGov.Challenges
  alias ChallengeGov.PhaseWinners
  alias ChallengeGov.Repo
  alias ChallengeGov.TestHelpers.SubmissionHelpers
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

      ChallengeHelpers.create_closed_single_phase_challenge(user, %{
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

      Challenges.set_sub_statuses()

      conn = get(conn, Routes.api_challenge_path(conn, :index))
      assert length(json_response(conn, 200)["collection"]) === 1
    end

    test "no results", %{conn: conn} do
      conn = get(conn, Routes.api_challenge_path(conn, :index))
      assert Enum.empty?(json_response(conn, 200)["collection"])
    end
  end

  describe "retrieving JSON list of archived challenges" do
    test "successfully", %{conn: conn} do
      user = AccountHelpers.create_user()

      now = Timex.now()

      ChallengeHelpers.create_single_phase_challenge(user, %{
        user_id: user.id
      })

      ChallengeHelpers.create_multi_phase_challenge(user, %{user_id: user.id})

      ChallengeHelpers.create_open_multi_phase_challenge(user, %{user_id: user.id})

      ChallengeHelpers.create_closed_multi_phase_challenge(user, %{user_id: user.id})

      ChallengeHelpers.create_archived_multi_phase_challenge(user, %{user_id: user.id})

      ChallengeHelpers.create_challenge(%{
        user_id: user.id,
        status: "draft",
        start_date: Timex.set(now, day: 1, month: 1, year: 2018),
        end_date: Timex.set(now, day: 1, month: 3, year: 2018),
        archive_date: Timex.set(now, day: 1, month: 5, year: 2018)
      })

      conn = get(conn, Routes.api_challenge_path(conn, :index, archived: true))
      assert length(json_response(conn, 200)["collection"]) === 2
    end

    test "success: filter by year", %{conn: conn} do
      user = AccountHelpers.create_user()

      now = Timex.now()

      ChallengeHelpers.create_challenge(%{
        user_id: user.id,
        start_date: Timex.set(now, day: 1, month: 1, year: 2018),
        end_date: Timex.set(now, day: 1, month: 3, year: 2018),
        archive_date: Timex.set(now, day: 1, month: 5, year: 2018)
      })

      ChallengeHelpers.create_challenge(%{
        user_id: user.id,
        start_date: Timex.set(now, day: 1, month: 1, year: 2019),
        end_date: Timex.set(now, day: 1, month: 3, year: 2019),
        archive_date: Timex.set(now, day: 1, month: 5, year: 2019)
      })

      ChallengeHelpers.create_challenge(%{
        user_id: user.id,
        start_date: Timex.shift(now, hours: 1),
        end_date: Timex.shift(now, hours: 2),
        archive_date: Timex.shift(now, hours: 2)
      })

      conn =
        get(conn, Routes.api_challenge_path(conn, :index, archived: true, filter: %{year: 2019}))

      assert length(json_response(conn, 200)["collection"]) === 1
    end

    test "no results", %{conn: conn} do
      conn = get(conn, Routes.api_challenge_path(conn, :index), archived: true)
      assert Enum.empty?(json_response(conn, 200)["collection"])
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

    test "successfully for published challenge with winners", %{conn: conn} do
      user = AccountHelpers.create_user()
      agency = AgencyHelpers.create_agency()

      challenge =
        ChallengeHelpers.create_single_phase_challenge(
          user,
          %{
            user_id: user.id,
            agency_id: agency.id,
            title: "Test Title 1",
            description: "Test description 1",
            status: "published"
          }
        )

      challenge = Repo.preload(challenge, [:phases])

      submission = SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      submission = Repo.preload(submission, phase: [:winners])

      {:ok, phase_winner} = PhaseWinners.create(submission.phase)

      PhaseWinners.update(
        phase_winner,
        %{
          "phase_winner" => %{
            "overview" => "",
            "overview_delta" => "",
            "overview_image_path" => "",
            "winners" => %{
              "0" => %{
                "id" => "",
                "image_path" => "",
                "name" => "Jane Doe",
                "place_title" => "1st",
                "remove" => "false"
              }
            }
          }
        }
      )

      Repo.preload(submission, [phase: [winners: [:winners]]], force: true)

      conn = get(conn, Routes.api_challenge_path(conn, :show, challenge.id))
      phase = List.first(json_response(conn, 200)["phases"])

      assert Enum.count(phase["phase_winner"]["winners"]) === 1
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

    test "with a gov delivery topic", %{conn: conn} do
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

      {:ok, challenge} = Challenges.store_gov_delivery_topic(challenge, "CHAL_TEST-1")

      expected_json = expected_show_json(challenge)

      expected_json =
        Map.put(
          expected_json,
          "gov_delivery_topic_subscribe_link",
          "https://stage-public.govdelivery.com/accounts/USGSATTS/subscriber/new?topic_id=CHAL_TEST-1"
        )

      conn = get(conn, Routes.api_challenge_path(conn, :show, challenge.id))
      assert json_response(conn, 200) === expected_json
    end

    test "successfully with custom url", %{conn: conn} do
      user = AccountHelpers.create_user()
      agency = AgencyHelpers.create_agency()

      challenge =
        ChallengeHelpers.create_challenge(%{
          user_id: user.id,
          agency_id: agency.id,
          title: "Test Title 1",
          description: "Test description 1",
          custom_url: "test-url",
          status: "published"
        })

      expected_json = Map.merge(expected_show_json(challenge), %{"custom_url" => "test-url"})

      conn = get(conn, Routes.api_challenge_path(conn, :show, challenge.custom_url))
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
      "uuid" => challenge.uuid,
      "title" => challenge.title,
      "legal_authority" => "Test legal authority",
      "phase_dates" => nil,
      "agency_id" => challenge.agency_id,
      "fiscal_year" => "FY20",
      "custom_url" => nil,
      "end_date" => nil,
      "prize_description" => nil,
      "faq" => nil,
      "other_type" => nil,
      "terms_equal_rules" => false,
      "prize_type" => "both",
      "primary_type" => "Software and apps",
      "upload_logo" => nil,
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
      "agency_logo" => Routes.static_url(Web.Endpoint, "/images/agency-logo-placeholder.svg"),
      "logo" => Routes.static_url(Web.Endpoint, "/images/challenge-logo-2_1.svg"),
      "logo_alt_text" => nil,
      "terms_and_conditions" => "Test terms",
      "non_monetary_prizes" => nil,
      "how_to_enter" => "",
      "how_to_enter_link" => nil,
      "events" => [],
      "start_date" => nil,
      "non_federal_partners" => [],
      "number_of_phases" => nil,
      "winner_image" => nil,
      "tagline" => challenge.tagline,
      "prize_total" => 0,
      "brief_description" => challenge.brief_description,
      "phase_descriptions" => nil,
      "federal_partners" => [],
      "phases" => [],
      "open_until" => nil,
      "announcement" => nil,
      "announcement_datetime" => nil,
      "gov_delivery_topic_subscribe_link" => nil,
      "subscriber_count" => 0,
      "is_archived" => Challenges.is_archived_new?(challenge),
      "is_closed" => Challenges.is_closed?(challenge),
      "short_url" => nil,
      "imported" => false,
      "sub_status" => nil
    }
  end
end

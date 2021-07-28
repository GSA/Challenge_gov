defmodule Web.Api.WinnerControllerTest do
  use Web.ConnCase
  use Web, :view

  alias ChallengeGov.Repo
  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers
  alias ChallengeGov.TestHelpers.SubmissionHelpers
  alias ChallengeGov.PhaseWinners
  alias ChallengeGov.TestHelpers
  alias ChallengeGov.Winners
  alias Stein.Storage

  describe "retrieving JSON list of winners" do
    test "successfully with winners", %{conn: conn} do
      user = AccountHelpers.create_user()

      challenge =
        ChallengeHelpers.create_single_phase_challenge(user, %{
          user_id: user.id,
          title: "Test Title 1",
          status: "published"
        })

      submission = SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      submission = Repo.preload(submission, phase: [:winners])

      {:ok, phase_winner} = PhaseWinners.create(submission.phase)

      PhaseWinners.update(
        phase_winner,
        %{
          "phase_winner" => %{
            "overview" => "",
            "overview_delta" => "",
            "overview_image_key" => "",
            "overview_image_extension" => "",
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

      submission = Repo.preload(submission, [phase: [winners: [:winners]]], force: true)

      expected_json =
        expected_phase_winners_json(submission.phase.winners, submission.phase.title)

      conn = get(conn, Routes.api_winner_path(conn, :phase_winners, submission.phase_id))
      assert json_response(conn, 200) === expected_json
    end

    test "successfully with no winners", %{conn: conn} do
      user = AccountHelpers.create_user()

      challenge =
        ChallengeHelpers.create_single_phase_challenge(user, %{
          user_id: user.id,
          title: "Test Title 1",
          status: "published"
        })

      submission = SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      conn = get(conn, Routes.api_winner_path(conn, :phase_winners, submission.phase_id))
      assert json_response(conn, 200) === %{}
    end
  end

  describe "retrieving winner images" do
    test "successfully add overview images", %{conn: conn} do
      user = AccountHelpers.create_user()

      challenge =
        ChallengeHelpers.create_single_phase_challenge(user, %{
          user_id: user.id,
          title: "Test Title 1",
          status: "published"
        })

      submission = SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      submission = Repo.preload(submission, phase: [:winners])

      {:ok, phase_winner} = PhaseWinners.create(submission.phase)

      {:ok, key, extension} =
        PhaseWinners.upload_overview_image(phase_winner, %{
          path: "test/fixtures/test.png",
          filename: "overview.png"
        })

      {:ok, phase_winner} =
        PhaseWinners.update(
          phase_winner,
          %{
            "phase_winner" => %{
              "overview" => "",
              "overview_delta" => "",
              "overview_image_key" => key,
              "overview_image_extension" => extension,
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

      phase_winner = Repo.preload(phase_winner, [:winners], force: true)
      expected_json = expected_phase_winners_json(phase_winner, nil)
      conn = get(conn, Routes.api_winner_path(conn, :phase_winners, submission.phase_id))

      assert phase_winner.overview_image_key === key
      assert phase_winner.overview_image_extension === extension
      assert json_response(conn, 200)["phase_id"] === expected_json["phase_id"]

      assert json_response(conn, 200)["overview_image_path"] ===
               expected_json["overview_image_path"]
    end

    test "successfully add individual winner images", %{conn: conn} do
      user = AccountHelpers.create_user()

      challenge =
        ChallengeHelpers.create_single_phase_challenge(user, %{
          user_id: user.id,
          title: "Test Title 1",
          status: "published"
        })

      submission = SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      submission = Repo.preload(submission, phase: [:winners])

      {:ok, phase_winner} = PhaseWinners.create(submission.phase)

      {:ok, phase_winner} =
        PhaseWinners.update(
          phase_winner,
          %{
            "phase_winner" => %{
              "overview" => "",
              "overview_delta" => "",
              "overview_image" => "",
              "winners" => %{
                "0" => %{
                  "id" => "",
                  "image" => %{path: "test/fixtures/test.png", filename: "test.png"},
                  "name" => "Jane Doe",
                  "place_title" => "1st",
                  "remove" => "false"
                }
              }
            }
          }
        )

      phase_winner = Repo.preload(phase_winner, [:winners], force: true)
      expected_json = expected_winners_json(phase_winner)

      conn = get(conn, Routes.api_winner_path(conn, :phase_winners, submission.phase_id))
      winner = List.first(json_response(conn, 200)["winners"])

      assert winner === expected_json
    end
  end

  defp expected_phase_winners_json(phase_winner, phase_title) do
    overview_image_path =
      if PhaseWinners.overview_image_path(phase_winner),
        do: Storage.url(PhaseWinners.overview_image_path(phase_winner)),
        else: nil

    %{
      "id" => phase_winner.id,
      "inserted_at" => TestHelpers.convert_date_format(phase_winner.inserted_at),
      "overview" => phase_winner.overview,
      "overview_delta" => phase_winner.overview_delta,
      "overview_image_path" => overview_image_path,
      "phase_title" => phase_title,
      "phase_id" => phase_winner.phase_id,
      "status" => phase_winner.status,
      "updated_at" => TestHelpers.convert_date_format(phase_winner.updated_at),
      "uuid" => phase_winner.uuid,
      "winners" =>
        TestHelpers.convert_atoms_to_strings(
          render_many(phase_winner.winners, Web.Api.WinnerView, "winners.json")
        )
    }
  end

  defp expected_winners_json(phase_winner) do
    winner = List.first(phase_winner.winners)

    image_path =
      if Winners.image_path(winner),
        do: Storage.url(Winners.image_path(winner)),
        else: nil

    %{
      "id" => winner.id,
      "image_path" => image_path,
      "inserted_at" => TestHelpers.convert_date_format(winner.inserted_at),
      "name" => winner.name,
      "place_title" => winner.place_title,
      "updated_at" => TestHelpers.convert_date_format(winner.updated_at)
    }
  end
end

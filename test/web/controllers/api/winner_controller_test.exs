defmodule Web.Api.WinnerControllerTest do
  use Web.ConnCase
  use Web, :view

  alias ChallengeGov.Repo
  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers
  alias ChallengeGov.TestHelpers.SubmissionHelpers
  alias ChallengeGov.PhaseWinners
  alias ChallengeGov.TestHelpers

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

      submission = Repo.preload(submission, [phase: [winners: [:winners]]], force: true)

      expected_json = expected_show_json(submission.phase.winners, submission.phase.title)

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

  defp expected_show_json(phase_winner, phase_title) do
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
end

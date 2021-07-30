defmodule ChallengeGov.SubmissionTest do
  use Web.FeatureCase, async: true

  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers

  feature "create a submission as a solver", %{session: session} do
    challenge = create_challenge()
    create_and_sign_in_solver(session)

    session
    |> visit("/public")
    |> click(link("#{challenge.title}"))
    |> click(link("Apply for this challenge"))
    |> fill_in(text_field("Title"), with: "Test Submission")
    |> execute_script("document.getElementsByClassName('ql-editor')[0].innerHTML = 'okay'")
    |> execute_script("document.getElementsByClassName('ql-editor')[1].innerHTML = 'here. now. please.'")
    |> click(checkbox("submission[terms_accepted]"))
    |> click(button("Review and submit"))
    |> click(link("Submit"))
    |> assert_text("Submission saved")

    submission_id = current_url(session) |> String.slice(-2..-1)

    session
    |> click(link("< Back to submissions"))
    |> assert_text("#{submission_id}")
  end

  defp create_challenge() do
    user = AccountHelpers.create_user(%{email: "challenge_owner_active@example.com", role: "challenge_owner"})
    challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id, custom_url: "test-challenge"})
    challenge
  end

  defp create_and_sign_in_solver(session) do
    AccountHelpers.create_user(%{email: "solver_active@example.com", role: "solver"})

    session
    |> visit("/dev_accounts")
    |> click(button("Solver Active"))
  end
end

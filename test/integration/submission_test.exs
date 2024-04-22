defmodule ChallengeGov.SubmissionIntegrationTest do
  use Web.FeatureCase, async: true

  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers

  @tag :skip
  feature "create a submission as a solver", %{session: session} do
    challenge = create_challenge()
    create_and_sign_in_solver(session)

    session
    |> visit("/public")
    |> click(link("#{challenge.title}"))
    |> click(link("Apply for this challenge"))
    |> fill_in(text_field("Title"), with: "Test Submission")
    |> execute_script(
      "document.getElementsByClassName('ql-editor')[0].innerHTML = 'Brief desciption here.'"
    )
    |> execute_script(
      "document.getElementsByClassName('ql-editor')[1].innerHTML = 'Full description here.'"
    )
    |> click(checkbox("submission[terms_accepted]"))
    |> click(button("Review and submit"))
    |> click(link("Submit"))
    |> assert_text("Submission saved")

    session
    |> click(link("< Back to submissions"))
    |> assert_text("#{challenge.title}")
  end

  feature "create a submission as an admin", %{session: session} do
    AccountHelpers.create_user(%{email: "solver_active@example.com", role: "solver"})
    create_challenge()
    create_and_sign_in_admin(session)

    session
    |> click(link("Challenge management"))
    |> click(link("View"))
    |> click(link("View submissions"))
    |> click(link("Add solver submission ->"))
    |> click(link("New solver submission"))
    |> fill_in(text_field("Title"), with: "Test Submission")
    |> execute_script(
      "document.getElementsByClassName('ql-editor')[0].innerHTML = 'Brief desciption here.'"
    )
    |> execute_script(
      "document.getElementsByClassName('ql-editor')[1].innerHTML = 'Full description here.'"
    )
    |> touch_scroll(button("Review and submit"), 0, 1)
    |> click(button("Review and submit"))
    |> touch_scroll(link("Submit"), 0, 1)
    |> click(link("Submit"))
    |> assert_text("Submission saved")

    # Submission is not found in table to be judged
    submission_id = get_submission_id(session)

    session
    |> touch_scroll(link("< Back to submissions"), 0, 1)
    |> click(link("< Back to submissions"))

    !has_text?(session, submission_id)

    # Admin submission table shows the "no" in review verified column
    session
    |> click(link("Add solver submission ->"))
    |> assert_text("Test Submission")
    |> assert_text(submission_id)
    |> find(css("#review-verified"))
    |> has_value?("no")

    # Admin created submission is found in Solver submissions
    # Commented out pending Login.Gov approving the change to
    # our `logout` redirect url .

    # session
    # |> click(link("admin_active@example.com"))
    # |> click(link("Logout"))
    # |> visit("/dev_accounts")
    # |> click(button("Solver Active"))
    # |> assert_text("New submission to review")
  end

  defp create_challenge() do
    user =
      AccountHelpers.create_user(%{
        email: "challenge_manager_active@example.com",
        role: "challenge_manager"
      })

    challenge =
      ChallengeHelpers.create_single_phase_challenge(user, %{
        user_id: user.id,
        custom_url: "test-challenge"
      })

    challenge
  end

  defp create_and_sign_in_admin(session) do
    AccountHelpers.create_user(%{email: "admin_active@example.com", role: "admin"})

    session
    |> visit("/dev_accounts")
    |> click(button("Admin Active"))
  end

  defp create_and_sign_in_solver(session) do
    AccountHelpers.create_user(%{email: "solver_active@example.com", role: "solver"})

    session
    |> visit("/dev_accounts")
    |> click(button("Solver Active"))
  end

  defp get_submission_id(session) do
    session
    |> current_url()
    |> String.split("/")
    |> List.last()
  end
end

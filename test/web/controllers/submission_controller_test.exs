defmodule Web.SubmissionControllerTest do
  use Web.ConnCase

  alias ChallengeGov.Submissions
  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers
  alias ChallengeGov.TestHelpers.SubmissionHelpers

  describe "index under challenge" do
    test "successfully retrieve all submissions for current solver user", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user1} = conn.assigns

      user2 = AccountHelpers.create_user(%{email: "solver@example.com", role: "solver"})

      challenge = ChallengeHelpers.create_single_phase_challenge(user1, %{user_id: user1.id})
      challenge_2 = ChallengeHelpers.create_single_phase_challenge(user1, %{user_id: user1.id})

      SubmissionHelpers.create_submitted_submission(%{}, user1, challenge)
      SubmissionHelpers.create_submitted_submission(%{}, user1, challenge_2)
      SubmissionHelpers.create_submitted_submission(%{}, user2, challenge_2)

      conn = get(conn, Routes.submission_path(conn, :index))

      %{submissions: submissions, pagination: _pagination} = conn.assigns

      assert length(submissions) === 2
    end

    test "successfully retrieve filtered submissions for challenge", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})
      challenge_2 = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      SubmissionHelpers.create_submitted_submission(
        %{
          "title" => "Filtered title"
        },
        user,
        challenge
      )

      SubmissionHelpers.create_submitted_submission(%{}, user, challenge_2)

      SubmissionHelpers.create_submitted_submission(
        %{
          "title" => "Filtered title"
        },
        user,
        challenge_2
      )

      conn = get(conn, Routes.submission_path(conn, :index), filter: %{title: "Filtered"})

      %{submissions: submissions, pagination: _pagination, filter: filter} = conn.assigns

      assert length(submissions) === 2
      assert filter["title"] === "Filtered"
    end

    test "redirect to sign in when signed out", %{conn: conn} do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})
      conn = get(conn, Routes.challenge_submission_path(conn, :index, challenge.id))

      assert conn.status === 302
      assert conn.halted
    end
  end

  describe "show action" do
    test "successfully viewing a submission", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      submission =
        SubmissionHelpers.create_submitted_submission(
          %{
            "title" => "Filtered title"
          },
          user,
          challenge
        )

      conn = get(conn, Routes.submission_path(conn, :show, submission.id))
      %{submission: fetched_submission} = conn.assigns

      assert fetched_submission.id === submission.id
    end

    test "success: viewing a submission of single phase challenge as challenge_owner", %{
      conn: conn
    } do
      conn = prep_conn_challenge_owner(conn)
      %{current_user: challenge_owner} = conn.assigns

      submission_owner =
        AccountHelpers.create_user(%{email: "submission_owner@example.com", role: "solver"})

      challenge =
        ChallengeHelpers.create_single_phase_challenge(challenge_owner, %{
          user_id: challenge_owner.id
        })

      submission =
        SubmissionHelpers.create_submitted_submission(
          %{},
          submission_owner,
          challenge
        )

      conn = get(conn, Routes.submission_path(conn, :show, submission.id))
      %{submission: fetched_submission} = conn.assigns

      assert fetched_submission.id === submission.id
      assert html_response(conn, 200) =~ "Back to submissions"
      assert html_response(conn, 200) =~ "Submission ID:"

      assert html_response(conn, 200) =~
               "Challenge <i>#{challenge.title}</i> submission #{submission.id} details"
    end

    test "success: viewing a submission of multi phase challenge as challenge_owner", %{
      conn: conn
    } do
      conn = prep_conn_challenge_owner(conn)
      %{current_user: challenge_owner} = conn.assigns

      submission_owner =
        AccountHelpers.create_user(%{email: "submission_owner@example.com", role: "solver"})

      challenge =
        ChallengeHelpers.create_multi_phase_challenge(challenge_owner, %{
          user_id: challenge_owner.id
        })

      phase = Enum.at(challenge.phases, 0)

      submission =
        SubmissionHelpers.create_submitted_submission(
          %{},
          submission_owner,
          challenge
        )

      conn = get(conn, Routes.submission_path(conn, :show, submission.id))
      %{submission: fetched_submission} = conn.assigns

      assert fetched_submission.id === submission.id
      assert html_response(conn, 200) =~ "Back to submissions"
      assert html_response(conn, 200) =~ "Submission ID:"

      assert html_response(conn, 200) =~
               "Phase <i>#{phase.title}</i> for challenge <i>#{challenge.title}</i> submission #{
                 submission.id
               } details"
    end

    test "success: viewing a submission of single phase challenge as admin", %{conn: conn} do
      conn = prep_conn_challenge_owner(conn)
      %{current_user: admin} = conn.assigns

      submission_owner =
        AccountHelpers.create_user(%{email: "submission_owner@example.com", role: "solver"})

      challenge = ChallengeHelpers.create_single_phase_challenge(admin, %{user_id: admin.id})

      submission =
        SubmissionHelpers.create_submitted_submission(
          %{},
          submission_owner,
          challenge
        )

      conn = get(conn, Routes.submission_path(conn, :show, submission.id))
      %{submission: fetched_submission} = conn.assigns

      assert fetched_submission.id === submission.id
      assert html_response(conn, 200) =~ "Back to submissions"
      assert html_response(conn, 200) =~ "Submission ID:"

      assert html_response(conn, 200) =~
               "Challenge <i>#{challenge.title}</i> submission #{submission.id} details"
    end

    test "success: viewing a submission of multi phase challenge as admin", %{conn: conn} do
      conn = prep_conn_challenge_owner(conn)
      %{current_user: admin} = conn.assigns

      submission_owner =
        AccountHelpers.create_user(%{email: "submission_owner@example.com", role: "solver"})

      challenge = ChallengeHelpers.create_multi_phase_challenge(admin, %{user_id: admin.id})
      phase = Enum.at(challenge.phases, 0)

      submission =
        SubmissionHelpers.create_submitted_submission(
          %{},
          submission_owner,
          challenge
        )

      conn = get(conn, Routes.submission_path(conn, :show, submission.id))
      %{submission: fetched_submission} = conn.assigns

      assert fetched_submission.id === submission.id
      assert html_response(conn, 200) =~ "Back to submissions"
      assert html_response(conn, 200) =~ "Submission ID:"

      assert html_response(conn, 200) =~
               "Phase <i>#{phase.title}</i> for challenge <i>#{challenge.title}</i> submission #{
                 submission.id
               } details"
    end

    test "not found viewing a deleted submission", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      submission = SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      Submissions.delete(submission)

      conn = get(conn, Routes.submission_path(conn, :show, submission.id))

      assert conn.status === 404
    end
  end

  describe "new action" do
    test "viewing the new submission form from phases as an admin", %{conn: conn} do
      conn = prep_conn_admin(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})
      phase = challenge.phases |> Enum.at(0)

      params = %{
        "challenge_id" => challenge.id,
        "phase_id" => phase.id
      }

      conn = get(conn, Routes.challenge_submission_path(conn, :new, challenge.id), params)

      %{changeset: changeset} = conn.assigns

      assert changeset
    end

    test "viewing the new submission form without phase id", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})
      _phase = challenge.phases |> Enum.at(0)

      params = %{
        "challenge_id" => challenge.id
      }

      conn = get(conn, Routes.challenge_submission_path(conn, :new, challenge.id), params)

      %{changeset: changeset} = conn.assigns

      assert changeset
    end
  end

  describe "create action" do
    test "saving as a draft", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})
      phase = challenge.phases |> Enum.at(0)

      params = %{
        "action" => "draft",
        "submission" => %{
          "title" => "Test title"
        },
        "challenge_id" => challenge.id,
        "phase_id" => "#{phase.id}"
      }

      conn = post(conn, Routes.challenge_submission_path(conn, :create, challenge.id), params)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) === Routes.submission_path(conn, :edit, id)
    end

    test "creating a submission and review", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})
      phase = challenge.phases |> Enum.at(0)

      params = %{
        "action" => "review",
        "submission" => %{
          "title" => "Test title",
          "brief_description" => "Test brief description",
          "description" => "Test description",
          "external_url" => "Test external url"
        },
        "challenge_id" => challenge.id,
        "phase_id" => "#{phase.id}"
      }

      conn = post(conn, Routes.challenge_submission_path(conn, :create, challenge.id), params)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) === Routes.submission_path(conn, :show, id)
    end

    test "creating a submission and review with missing params", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})
      phase = challenge.phases |> Enum.at(0)

      params = %{
        "action" => "review",
        "submission" => %{},
        "challenge_id" => challenge.id,
        "phase_id" => "#{phase.id}"
      }

      conn = post(conn, Routes.challenge_submission_path(conn, :create, challenge.id), params)

      %{changeset: changeset} = conn.assigns

      assert conn.status === 422
      assert changeset.errors[:title]
      assert changeset.errors[:brief_description]
      assert changeset.errors[:description]
    end
  end

  describe "edit action" do
    test "viewing the edit submission form for a draft", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      submission = SubmissionHelpers.create_draft_submission(%{}, user, challenge)

      conn = get(conn, Routes.submission_path(conn, :edit, submission.id))

      %{submission: submission, changeset: changeset} = conn.assigns

      assert changeset
      assert submission.status === "draft"
    end

    test "viewing the edit submission form for a submitted submission", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      submission = SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      conn = get(conn, Routes.submission_path(conn, :edit, submission.id))

      %{submission: submission, changeset: changeset} = conn.assigns

      assert changeset
      assert submission.status === "submitted"
    end

    test "viewing the edit submission form for a submission you don't own", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: solver_user} = conn.assigns
      solver_user_2 = AccountHelpers.create_user(%{email: "user_2@example.com"})

      challenge =
        ChallengeHelpers.create_single_phase_challenge(solver_user, %{user_id: solver_user.id})

      submission = SubmissionHelpers.create_submitted_submission(%{}, solver_user_2, challenge)

      conn = get(conn, Routes.submission_path(conn, :edit, submission.id))

      assert get_flash(conn, :error) === "Submission cannot be edited"
      assert redirected_to(conn) === Routes.submission_path(conn, :index)
    end
  end

  describe "update action" do
    test "updating a draft submission and saving as draft", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: solver_user} = conn.assigns
      admin_user = AccountHelpers.create_user(%{email: "admin_user_2@example.com", role: "admin"})

      challenge =
        ChallengeHelpers.create_single_phase_challenge(admin_user, %{user_id: admin_user.id})

      submission =
        SubmissionHelpers.create_draft_submission(
          %{"manager_id" => admin_user.id},
          solver_user,
          challenge
        )

      params = %{
        "action" => "draft",
        "submission" => %{
          "title" => "New test title",
          "brief_description" => "Test brief description",
          "description" => "Test description",
          "external_url" => nil
        }
      }

      conn = put(conn, Routes.submission_path(conn, :update, submission.id), params)

      {:ok, submission} = Submissions.get(submission.id)

      assert submission.status === "draft"
      assert get_flash(conn, :info) === "Submission saved as draft"
      assert redirected_to(conn) === Routes.submission_path(conn, :edit, submission.id)
    end

    test "updating a submitted submission and saving as draft", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      submission = SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      params = %{
        "action" => "draft",
        "submission" => %{
          "title" => "New test title",
          "brief_description" => "Test brief description",
          "description" => "Test description",
          "external_url" => nil
        }
      }

      conn = put(conn, Routes.submission_path(conn, :update, submission.id), params)

      {:ok, submission} = Submissions.get(submission.id)

      assert submission.status === "draft"
      assert get_flash(conn, :info) === "Submission saved as draft"
      assert redirected_to(conn) === Routes.submission_path(conn, :edit, submission.id)
    end

    test "updating a submission and sending to review with errors", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      submission = SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      params = %{
        "action" => "review",
        "submission" => %{
          "title" => "New test title",
          "brief_description" => "Test brief description",
          "description" => nil,
          "external_url" => nil
        }
      }

      conn = put(conn, Routes.submission_path(conn, :update, submission.id), params)

      %{changeset: changeset} = conn.assigns

      assert changeset.errors[:description]
    end

    test "updating a submission and sending to review", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      submission = SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      params = %{
        "action" => "review",
        "submission" => %{
          "title" => "New test title",
          "brief_description" => "New test brief description",
          "description" => "New test description",
          "external_url" => "www.test_example.com"
        }
      }

      conn = put(conn, Routes.submission_path(conn, :update, submission.id), params)

      {:ok, submission} = Submissions.get(submission.id)

      assert submission.status === "draft"
      assert redirected_to(conn) === Routes.submission_path(conn, :show, submission.id)
    end

    test "attempting to update a submission that you don't own", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns
      user_2 = AccountHelpers.create_user(%{email: "user_2@example.com"})

      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      submission = SubmissionHelpers.create_submitted_submission(%{}, user_2, challenge)

      params = %{
        "action" => "review",
        "submission" => %{
          "title" => "New test title",
          "brief_description" => "New test brief description",
          "description" => "New test description",
          "external_url" => "www.test_example.com"
        }
      }

      conn = put(conn, Routes.submission_path(conn, :update, submission.id), params)

      assert get_flash(conn, :error) === "You are not allowed to edit this submission"
      assert redirected_to(conn) === Routes.submission_path(conn, :index)
    end

    test "updating a submission to submitted", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      submission = SubmissionHelpers.create_draft_submission(%{}, user, challenge)

      conn = put(conn, Routes.submission_path(conn, :submit, submission.id))

      {:ok, submission} = Submissions.get(submission.id)

      assert submission.status === "submitted"
      assert redirected_to(conn) === Routes.submission_path(conn, :show, submission.id)
    end

    test "attempting to update a submission that was deleted", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      submission = SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      {:ok, submission} = Submissions.delete(submission)

      params = %{
        "action" => "review",
        "submission" => %{
          "title" => "New test title",
          "brief_description" => "New test brief description",
          "description" => "New test description",
          "external_url" => "www.test_example.com"
        }
      }

      conn = put(conn, Routes.submission_path(conn, :update, submission.id), params)

      assert get_flash(conn, :error) === "This submission does not exist"
      assert redirected_to(conn) === Routes.submission_path(conn, :index)
    end

    test "attempting to update a submission that doesn't exist", %{conn: conn} do
      conn = prep_conn(conn)

      params = %{
        "action" => "review",
        "submission" => %{
          "title" => "New test title",
          "brief_description" => "New test brief description",
          "description" => "New test description",
          "external_url" => "www.test_example.com"
        }
      }

      conn = put(conn, Routes.submission_path(conn, :update, 1), params)

      assert get_flash(conn, :error) === "This submission does not exist"
      assert redirected_to(conn) === Routes.submission_path(conn, :index)
    end
  end

  describe "updating judging status" do
    test "success: selecting for judging", %{conn: conn} do
      conn = prep_conn_admin(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})
      phase = Enum.at(challenge.phases, 0)

      referer = Routes.challenge_phase_path(conn, :show, challenge.id, phase.id)
      conn = Plug.Conn.update_req_header(conn, "referer", referer, &(&1 <> "; charset=utf-8"))

      submission = SubmissionHelpers.create_submitted_submission(%{}, user, challenge)
      assert submission.judging_status === "not_selected"

      conn =
        put(
          conn,
          Routes.api_submission_path(
            conn,
            :update_judging_status,
            submission.id,
            "selected"
          )
        )

      {:ok, updated_submission} = Submissions.get(submission.id)
      assert updated_submission.judging_status === "selected"

      assert response(conn, 200) ===
               Jason.encode!(
                 Web.PhaseView.get_judging_status_button_values(
                   conn,
                   challenge,
                   phase,
                   updated_submission,
                   submission.judging_status,
                   %{}
                 )
               )
    end

    test "success: unselecting for judging", %{conn: conn} do
      conn = prep_conn_admin(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})
      phase = Enum.at(challenge.phases, 0)

      referer = Routes.challenge_phase_path(conn, :show, challenge.id, phase.id)
      conn = Plug.Conn.update_req_header(conn, "referer", referer, &(&1 <> "; charset=utf-8"))

      submission = SubmissionHelpers.create_submitted_submission(%{}, user, challenge)
      {:ok, submission} = Submissions.update_judging_status(submission, "selected")
      assert submission.judging_status === "selected"

      conn =
        put(
          conn,
          Routes.api_submission_path(
            conn,
            :update_judging_status,
            submission.id,
            "not_selected"
          )
        )

      {:ok, updated_submission} = Submissions.get(submission.id)
      assert updated_submission.judging_status === "not_selected"

      assert response(conn, 200) ===
               Jason.encode!(
                 Web.PhaseView.get_judging_status_button_values(
                   conn,
                   challenge,
                   phase,
                   updated_submission,
                   submission.judging_status,
                   %{}
                 )
               )
    end

    test "failure: invalid status", %{conn: conn} do
      conn = prep_conn_admin(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})
      phase = Enum.at(challenge.phases, 0)

      referer = Routes.challenge_phase_path(conn, :show, challenge.id, phase.id)
      conn = Plug.Conn.update_req_header(conn, "referer", referer, &(&1 <> "; charset=utf-8"))

      submission = SubmissionHelpers.create_submitted_submission(%{}, user, challenge)
      assert submission.judging_status === "not_selected"

      conn =
        put(
          conn,
          Routes.api_submission_path(
            conn,
            :update_judging_status,
            submission.id,
            "invalid"
          )
        )

      assert response(conn, 400) === ""

      {:ok, updated_submission} = Submissions.get(submission.id)
      assert updated_submission.judging_status === "not_selected"
    end

    test "failure: solver not authorized", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})
      phase = Enum.at(challenge.phases, 0)

      referer = Routes.challenge_phase_path(conn, :show, challenge.id, phase.id)
      conn = Plug.Conn.update_req_header(conn, "referer", referer, &(&1 <> "; charset=utf-8"))

      submission = SubmissionHelpers.create_submitted_submission(%{}, user, challenge)
      assert submission.judging_status === "not_selected"

      conn =
        put(
          conn,
          Routes.api_submission_path(
            conn,
            :update_judging_status,
            submission.id,
            "selected"
          )
        )

      assert get_flash(conn, :error) === "You are not authorized"
      assert redirected_to(conn) === Routes.dashboard_path(conn, :index)

      {:ok, updated_submission} = Submissions.get(submission.id)
      assert updated_submission.judging_status === "not_selected"
    end

    test "failure: challenge owner not authorized", %{conn: conn} do
      conn = prep_conn_challenge_owner(conn)
      %{current_user: user} = conn.assigns

      different_challenge_owner =
        AccountHelpers.create_user(%{
          email: "challenge_owner@example.com",
          role: "challenge_owner"
        })

      challenge =
        ChallengeHelpers.create_single_phase_challenge(different_challenge_owner, %{
          user_id: user.id
        })

      phase = Enum.at(challenge.phases, 0)

      referer = Routes.challenge_phase_path(conn, :show, challenge.id, phase.id)
      conn = Plug.Conn.update_req_header(conn, "referer", referer, &(&1 <> "; charset=utf-8"))

      submission = SubmissionHelpers.create_submitted_submission(%{}, user, challenge)
      assert submission.judging_status === "not_selected"

      conn =
        put(
          conn,
          Routes.api_submission_path(
            conn,
            :update_judging_status,
            submission.id,
            "selected"
          )
        )

      assert response(conn, 403) === ""

      {:ok, updated_submission} = Submissions.get(submission.id)
      assert updated_submission.judging_status === "not_selected"
    end
  end

  describe "delete action" do
    test "deleting a draft submission you own", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      submission = SubmissionHelpers.create_draft_submission(%{}, user, challenge)

      conn = delete(conn, Routes.submission_path(conn, :delete, submission.id))

      assert {:error, :not_found} === Submissions.get(submission.id)
      assert get_flash(conn, :info) === "Submission deleted"
      assert redirected_to(conn) === Routes.submission_path(conn, :index)
    end

    test "deleting a submitted submission you own", %{conn: conn} do
      conn = prep_conn(conn)
      %{current_user: user} = conn.assigns

      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      submission = SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      conn = delete(conn, Routes.submission_path(conn, :delete, submission.id))

      assert {:error, :not_found} === Submissions.get(submission.id)
      assert get_flash(conn, :info) === "Submission deleted"
      assert redirected_to(conn) === Routes.submission_path(conn, :index)
    end

    test "deleting a draft submission as an admin", %{conn: conn} do
      conn = prep_conn_admin(conn)
      %{current_user: admin_user} = conn.assigns
      solver_user = AccountHelpers.create_user(%{email: "solver@example.com", role: "solver"})

      challenge =
        ChallengeHelpers.create_single_phase_challenge(admin_user, %{user_id: admin_user.id})

      submission =
        SubmissionHelpers.create_draft_submission(
          %{"manager_id" => admin_user.id},
          solver_user,
          challenge
        )

      conn = delete(conn, Routes.submission_path(conn, :delete, submission))

      assert {:error, :not_found} === Submissions.get(submission.id)
      assert get_flash(conn, :info) === "Submission deleted"

      assert redirected_to(conn) ===
               Routes.challenge_phase_managed_submission_path(
                 conn,
                 :managed_submissions,
                 submission.challenge_id,
                 submission.phase_id
               )
    end

    test "deleting a submitted submission as an admin", %{conn: conn} do
      conn = prep_conn_admin(conn)
      %{current_user: admin_user} = conn.assigns
      solver_user = AccountHelpers.create_user(%{email: "solver@example.com", role: "solver"})

      challenge =
        ChallengeHelpers.create_single_phase_challenge(admin_user, %{user_id: admin_user.id})

      submission =
        SubmissionHelpers.create_submitted_submission(
          %{"manager_id" => admin_user.id},
          solver_user,
          challenge
        )

      conn = delete(conn, Routes.submission_path(conn, :delete, submission))

      assert {:error, :not_found} === Submissions.get(submission.id)
      assert get_flash(conn, :info) === "Submission deleted"

      assert redirected_to(conn) ===
               Routes.challenge_phase_managed_submission_path(
                 conn,
                 :managed_submissions,
                 submission.challenge_id,
                 submission.phase_id
               )
    end
  end

  defp prep_conn(conn) do
    user = AccountHelpers.create_user()
    assign(conn, :current_user, user)
  end

  defp prep_conn_admin(conn) do
    user = AccountHelpers.create_user(%{email: "admin@example.com", role: "admin"})
    assign(conn, :current_user, user)
  end

  defp prep_conn_challenge_owner(conn) do
    user = AccountHelpers.create_user(%{email: "admin@example.com", role: "challenge_owner"})
    assign(conn, :current_user, user)
  end
end

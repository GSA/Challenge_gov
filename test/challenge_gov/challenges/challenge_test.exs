defmodule ChallengeGov.ChallengeTest do
  use ChallengeGov.DataCase
  use Bamboo.Test

  alias ChallengeGov.Challenges
  alias ChallengeGov.Emails
  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers
  alias ChallengeGov.TestHelpers.SubmissionHelpers

  describe "submit challenge" do
    test "successfully" do
      user = AccountHelpers.create_user()

      challenge =
        ChallengeHelpers.create_single_phase_challenge(user, %{
          user_id: user.id,
          status: "draft",
          challenge_managers: [user.id]
        })

      params = %{"action" => "submit", "challenge" => %{"section" => "review"}}

      {:ok, challenge} = Challenges.update(challenge, params, user)

      assert challenge.status === "gsa_review"
      assert_delivered_email(Emails.challenge_submission(user, challenge))
    end
  end

  describe "find start date" do
    test "successfully from single phase" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      start_date = Challenges.find_start_date(challenge)
      first_date = Timex.now()

      assert length(challenge.phases) === 1
      assert Timex.equal?(start_date, first_date, :minute)
    end

    test "successfully from multi phase" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_multi_phase_challenge(user, %{user_id: user.id})

      start_date = Challenges.find_start_date(challenge)
      first_date = Timex.shift(Timex.now(), hours: 1)

      assert length(challenge.phases) === 3
      assert Timex.equal?(start_date, first_date, :minute)
    end
  end

  describe "find end date" do
    test "successfully from single phase" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      end_date = Challenges.find_end_date(challenge)
      last_date = Timex.shift(Timex.now(), hours: 1)

      assert length(challenge.phases) === 1
      assert Timex.equal?(end_date, last_date, :minute)
    end

    test "successfully from multi phase" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_multi_phase_challenge(user, %{user_id: user.id})

      end_date = Challenges.find_end_date(challenge)
      last_date = Timex.shift(Timex.now(), hours: 4)

      assert length(challenge.phases) === 3
      assert Timex.equal?(end_date, last_date, :minute)
    end
  end

  describe "find current phase" do
    test "success: single phase challenge" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      {:ok, phase} = Challenges.current_phase(challenge)

      assert phase
    end

    test "success: multi phase challenge" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_open_multi_phase_challenge(user, %{user_id: user.id})

      {:ok, phase} = Challenges.current_phase(challenge)

      assert phase
    end

    test "failure: no current phase in single phase" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_closed_single_phase_challenge(user, %{user_id: user.id})

      assert {:error, :no_current_phase} === Challenges.current_phase(challenge)
    end

    test "failure: no current phase in multi phase" do
      user = AccountHelpers.create_user()

      challenge =
        ChallengeHelpers.create_archived_multi_phase_challenge(user, %{user_id: user.id})

      assert {:error, :no_current_phase} === Challenges.current_phase(challenge)
    end

    test "failure: no phases" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id}, user)

      assert {:error, :no_current_phase} === Challenges.current_phase(challenge)
    end
  end

  describe "find next phase" do
    test "success: multi phase challenge" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_open_multi_phase_challenge(user, %{user_id: user.id})
      phase = Enum.at(challenge.phases, 0)
      next_phase = Enum.at(challenge.phases, 1)

      {:ok, ^next_phase} = Challenges.next_phase(challenge, phase)
    end

    test "failure: single phase challenge" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})
      phase = Enum.at(challenge.phases, 0)

      {:error, :not_found} = Challenges.next_phase(challenge, phase)
    end
  end

  describe "create announcement" do
    test "successfully" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      {:ok, challenge} = Challenges.create_announcement(challenge, "Test announcement")

      assert challenge.announcement === "Test announcement"
      assert challenge.announcement_datetime === DateTime.truncate(DateTime.utc_now(), :second)
    end
  end

  describe "set published sub statuses" do
    test "successfully" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      multi_phase_challenge =
        ChallengeHelpers.create_multi_phase_challenge(user, %{user_id: user.id})

      open_multi_phase_challenge =
        ChallengeHelpers.create_open_multi_phase_challenge(user, %{user_id: user.id})

      closed_multi_phase_challenge =
        ChallengeHelpers.create_closed_multi_phase_challenge(user, %{user_id: user.id})

      archived_multi_phase_challenge =
        ChallengeHelpers.create_archived_multi_phase_challenge(user, %{user_id: user.id})

      assert challenge.sub_status === nil
      assert multi_phase_challenge.sub_status === nil
      assert open_multi_phase_challenge.sub_status === nil
      assert closed_multi_phase_challenge.sub_status === nil
      assert archived_multi_phase_challenge.sub_status === nil

      Challenges.set_sub_statuses()

      {:ok, challenge} = Challenges.get(challenge.id)
      {:ok, multi_phase_challenge} = Challenges.get(multi_phase_challenge.id)
      {:ok, open_multi_phase_challenge} = Challenges.get(open_multi_phase_challenge.id)
      {:ok, closed_multi_phase_challenge} = Challenges.get(closed_multi_phase_challenge.id)
      {:ok, archived_multi_phase_challenge} = Challenges.get(archived_multi_phase_challenge.id)

      assert challenge.sub_status === "open"
      assert multi_phase_challenge.sub_status === nil
      assert open_multi_phase_challenge.sub_status === "open"
      assert closed_multi_phase_challenge.sub_status === "closed"
      assert archived_multi_phase_challenge.sub_status === "archived"
    end
  end

  describe "check user relations to challenge" do
    test "success: is challenge manager for challenge" do
      user = AccountHelpers.create_user(%{role: "challenge_manager"})
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      assert Challenges.is_challenge_manager?(user, challenge)
    end

    test "failure: is not challenge manager for challenge" do
      user = AccountHelpers.create_user(%{role: "challenge_manager"})
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})

      other_user =
        AccountHelpers.create_user(%{role: "challenge_manager", email: "other@example.com"})

      refute Challenges.is_challenge_manager?(other_user, challenge)
    end

    test "success: is solver on challenge" do
      user = AccountHelpers.create_user(%{role: "solver"})
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})
      _submission = SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      assert Challenges.is_solver?(user, challenge)
    end

    test "success: is not solver on challenge" do
      user = AccountHelpers.create_user(%{role: "solver"})
      challenge = ChallengeHelpers.create_single_phase_challenge(user, %{user_id: user.id})
      _submission = SubmissionHelpers.create_submitted_submission(%{}, user, challenge)

      other_user = AccountHelpers.create_user(%{role: "solver", email: "other@example.com"})

      refute Challenges.is_solver?(other_user, challenge)
    end
  end
end

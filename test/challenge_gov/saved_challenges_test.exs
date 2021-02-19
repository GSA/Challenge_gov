defmodule ChallengeGov.SavedChallengesTest do
  use ChallengeGov.DataCase

  alias ChallengeGov.Challenges
  alias ChallengeGov.SavedChallenges
  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers

  describe "saving challenges" do
    test "successfully" do
      user = AccountHelpers.create_user()
      user_2 = AccountHelpers.create_user(%{email: "user_2@example.com"})

      challenge = ChallengeHelpers.create_challenge(%{user_id: user_2.id, status: "published"})
      _challenge_2 = ChallengeHelpers.create_challenge(%{user_id: user_2.id})

      {:ok, _saved_challenge} = SavedChallenges.create(user, challenge)

      saved_challenges = SavedChallenges.all(user)

      assert length(saved_challenges) === 1
    end

    test "successfully saving multiple" do
      user = AccountHelpers.create_user()
      user_2 = AccountHelpers.create_user(%{email: "user_2@example.com"})

      challenge = ChallengeHelpers.create_challenge(%{user_id: user_2.id, status: "published"})
      challenge_2 = ChallengeHelpers.create_challenge(%{user_id: user_2.id, status: "archived"})

      {:ok, _saved_challenge} = SavedChallenges.create(user, challenge)
      {:ok, _saved_challenge} = SavedChallenges.create(user, challenge_2)

      saved_challenges = SavedChallenges.all(user)

      assert length(saved_challenges) === 2
    end

    test "failure saving same challenge twice" do
      user = AccountHelpers.create_user()
      user_2 = AccountHelpers.create_user(%{email: "user_2@example.com"})

      challenge = ChallengeHelpers.create_challenge(%{user_id: user_2.id, status: "published"})

      {:ok, _saved_challenge} = SavedChallenges.create(user, challenge)
      {:error, changeset} = SavedChallenges.create(user, challenge)

      saved_challenges = SavedChallenges.all(user)

      assert length(saved_challenges) === 1
      assert changeset.errors[:unique_user_challenge]
    end

    test "failure saving non public challenges" do
      user = AccountHelpers.create_user()
      user_2 = AccountHelpers.create_user(%{email: "user_2@example.com"})

      challenge = ChallengeHelpers.create_challenge(%{user_id: user_2.id, status: "draft"})
      {:error, :not_saved} = SavedChallenges.create(user, challenge)

      challenge = ChallengeHelpers.create_challenge(%{user_id: user_2.id, status: "gsa_review"})
      {:error, :not_saved} = SavedChallenges.create(user, challenge)

      challenge =
        ChallengeHelpers.create_challenge(%{user_id: user_2.id, status: "edits_requested"})

      {:error, :not_saved} = SavedChallenges.create(user, challenge)

      challenge = ChallengeHelpers.create_challenge(%{user_id: user_2.id, status: "unpublished"})
      {:error, :not_saved} = SavedChallenges.create(user, challenge)

      saved_challenges = SavedChallenges.all(user)

      assert Enum.empty?(saved_challenges)
    end

    test "success saving public challenges" do
      user = AccountHelpers.create_user()
      user_2 = AccountHelpers.create_user(%{email: "user_2@example.com"})

      challenge = ChallengeHelpers.create_challenge(%{user_id: user_2.id, status: "archived"})
      {:ok, _saved_challenge} = SavedChallenges.create(user, challenge)

      challenge = ChallengeHelpers.create_challenge(%{user_id: user_2.id, status: "published"})
      {:ok, _saved_challenge} = SavedChallenges.create(user, challenge)

      saved_challenges = SavedChallenges.all(user)

      assert length(saved_challenges) === 2
    end

    test "failure saving deleted challenges" do
      user = AccountHelpers.create_user()
      user_2 = AccountHelpers.create_user(%{email: "user_2@example.com", role: "super_admin"})

      challenge = ChallengeHelpers.create_challenge(%{user_id: user_2.id})
      {:ok, deleted_challenge} = Challenges.delete(challenge, user_2, "")
      {:error, :not_saved} = SavedChallenges.create(user, deleted_challenge)

      saved_challenges = SavedChallenges.all(user)

      assert Enum.empty?(saved_challenges)
    end

    @tag :pending
    test "remove saved challenges when challenge is no longer published" do
      assert true
    end
  end

  describe "fetching saved challenges" do
    test "all saved challenges for user" do
      user = AccountHelpers.create_user()
      user_2 = AccountHelpers.create_user(%{email: "user_2@example.com"})

      challenge = ChallengeHelpers.create_challenge(%{user_id: user_2.id, status: "published"})
      {:ok, _saved_challenge} = SavedChallenges.create(user, challenge)
      challenge = ChallengeHelpers.create_challenge(%{user_id: user_2.id, status: "published"})
      {:ok, _saved_challenge} = SavedChallenges.create(user, challenge)

      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id, status: "published"})
      {:ok, _saved_challenge} = SavedChallenges.create(user_2, challenge)

      saved_challenges = SavedChallenges.all(user)
      saved_challenges_2 = SavedChallenges.all(user_2)

      assert length(saved_challenges) === 2
      assert length(saved_challenges_2) === 1
    end
  end

  describe "fetching a saved challenge" do
    test "successfully" do
      user = AccountHelpers.create_user()
      user_2 = AccountHelpers.create_user(%{email: "user_2@example.com"})

      challenge = ChallengeHelpers.create_challenge(%{user_id: user_2.id, status: "published"})
      challenge_2 = ChallengeHelpers.create_challenge(%{user_id: user.id, status: "published"})

      {:ok, saved_challenge} = SavedChallenges.create(user, challenge)
      {:ok, saved_challenge_2} = SavedChallenges.create(user_2, challenge_2)

      {:ok, fetched_saved_challenge} = SavedChallenges.get(saved_challenge.id)
      {:ok, fetched_saved_challenge_2} = SavedChallenges.get(saved_challenge_2.id)

      assert fetched_saved_challenge.user_id === user.id
      assert fetched_saved_challenge.challenge_id === challenge.id

      assert fetched_saved_challenge_2.user_id === user_2.id
      assert fetched_saved_challenge_2.challenge_id === challenge_2.id
    end

    test "not found" do
      assert SavedChallenges.get(1) === {:error, :not_found}
    end
  end

  describe "deleting a saved challenge" do
    test "successfully" do
      user = AccountHelpers.create_user()
      user_2 = AccountHelpers.create_user(%{email: "user_2@example.com"})

      challenge = ChallengeHelpers.create_challenge(%{user_id: user_2.id, status: "published"})
      challenge_2 = ChallengeHelpers.create_challenge(%{user_id: user.id, status: "published"})

      {:ok, saved_challenge} = SavedChallenges.create(user, challenge)
      {:ok, _saved_challenge_2} = SavedChallenges.create(user_2, challenge_2)
      {:ok, deleted_saved_challenge} = SavedChallenges.delete(user, saved_challenge)

      saved_challenges = SavedChallenges.all(user)
      saved_challenges_2 = SavedChallenges.all(user_2)

      assert deleted_saved_challenge.user_id === user.id
      assert deleted_saved_challenge.challenge_id === challenge.id
      assert Enum.empty?(saved_challenges)
      assert length(saved_challenges_2) === 1
    end

    test "failure not your saved challenge" do
      user = AccountHelpers.create_user()
      user_2 = AccountHelpers.create_user(%{email: "user_2@example.com"})

      challenge = ChallengeHelpers.create_challenge(%{user_id: user_2.id, status: "published"})
      challenge_2 = ChallengeHelpers.create_challenge(%{user_id: user.id, status: "published"})

      {:ok, saved_challenge} = SavedChallenges.create(user, challenge)
      {:ok, saved_challenge_2} = SavedChallenges.create(user_2, challenge_2)

      {:error, :not_allowed} = SavedChallenges.delete(user, saved_challenge_2)
      {:error, :not_allowed} = SavedChallenges.delete(user_2, saved_challenge)

      saved_challenges = SavedChallenges.all(user)
      saved_challenges_2 = SavedChallenges.all(user_2)

      assert length(saved_challenges) === 1
      assert length(saved_challenges_2) === 1
    end
  end
end

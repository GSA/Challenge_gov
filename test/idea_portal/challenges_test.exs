defmodule ChallengeGov.ChallengesTest do
  use ChallengeGov.DataCase
  use Bamboo.Test

  alias ChallengeGov.Challenges
  alias ChallengeGov.Challenges.Challenge
  alias ChallengeGov.Emails

  doctest Challenges

  describe "submitting a new challenge" do
    test "successfully" do
      user = TestHelpers.create_user()

      {:ok, challenge} =
        Challenges.submit(user, %{
          focus_area: "Transportation",
          name: "Bike lanes",
          description: "We need more bike lanes",
          why: "To bike around",
          fixed_looks_like: "More bike lanes",
          technology_example: "Using computers"
        })

      assert challenge.user_id
    end

    test "with errors" do
      user = TestHelpers.create_user()

      {:error, changeset} =
        Challenges.submit(user, %{
          name: "Bike lanes",
          description: "We need more bike lanes",
          why: "To bike around"
        })

      assert changeset.errors[:focus_area]
    end

    test "sends an email" do
      user = TestHelpers.create_verified_user()
      challenge = TestHelpers.create_challenge(user)

      assert_delivered_email(Emails.new_challenge(challenge))
    end

    test "attaching supporting documents" do
      user = TestHelpers.create_user()
      document = TestHelpers.upload_document(user, "test/fixtures/test.pdf")

      {:ok, challenge} =
        Challenges.submit(user, %{
          focus_area: "Transportation",
          name: "Bike lanes",
          description: "We need more bike lanes",
          why: "To bike around",
          fixed_looks_like: "More bike lanes",
          technology_example: "Using computers",
          document_ids: [document.id]
        })

      challenge = Repo.preload(challenge, [:supporting_documents])
      assert length(challenge.supporting_documents) == 1
    end

    test "failure attaching a supporting document" do
      user = TestHelpers.create_user(%{email: "user1@example.com"})
      document = TestHelpers.upload_document(user, "test/fixtures/test.pdf")

      user = TestHelpers.create_user(%{email: "user2@example.com"})

      {:error, _changeset} =
        Challenges.submit(user, %{
          focus_area: "Transportation",
          name: "Bike lanes",
          description: "We need more bike lanes",
          why: "To bike around",
          fixed_looks_like: "More bike lanes",
          technology_example: "Using computers",
          document_ids: [document.id]
        })
    end
  end

  describe "updating a challenge" do
    test "successfully" do
      user = TestHelpers.create_user()
      challenge = TestHelpers.create_challenge(user)

      {:ok, challenge} =
        Challenges.update(challenge, %{
          name: "Bike lanes"
        })

      assert challenge.name == "Bike lanes"
    end

    test "with errors" do
      user = TestHelpers.create_user()
      challenge = TestHelpers.create_challenge(user)

      {:error, changeset} =
        Challenges.update(challenge, %{
          focus_area: nil
        })

      assert changeset.errors[:focus_area]
    end
  end

  describe "publishing a challenge" do
    test "successfully" do
      user = TestHelpers.create_user()
      challenge = TestHelpers.create_challenge(user)

      {:ok, challenge} = Challenges.publish(challenge)

      assert challenge.status == "created"
    end

    test "creates a timeline event" do
      user = TestHelpers.create_user()
      challenge = TestHelpers.create_challenge(user)

      {:ok, challenge} = Challenges.publish(challenge)

      challenge = Repo.preload(challenge, :events, force: true)
      assert length(challenge.events) == 1
    end
  end

  describe "archiving a challenge" do
    test "successfully" do
      user = TestHelpers.create_user()
      challenge = TestHelpers.create_challenge(user)

      {:ok, challenge} = Challenges.archive(challenge)

      assert challenge.status == "archived"
    end
  end

  describe "getting challenge counts" do
    test "successfully" do
      user = TestHelpers.create_user()
      _pending_challenge = TestHelpers.create_challenge(user)
      created_challenge = TestHelpers.create_challenge(user)
      archived_challenge = TestHelpers.create_challenge(user)

      Challenges.publish(created_challenge)
      Challenges.archive(archived_challenge)

      counts = Challenges.admin_counts()

      assert counts.pending === 1
      assert counts.created === 1
      assert counts.archived === 1
    end
  end
end

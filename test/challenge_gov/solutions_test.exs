defmodule ChallengeGov.SolutionsTest do
  use ChallengeGov.DataCase
  use Bamboo.Test

  alias ChallengeGov.Emails
  alias ChallengeGov.Solutions
  alias ChallengeGov.SecurityLogs
  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers
  alias ChallengeGov.TestHelpers.SolutionHelpers

  describe "creating a solution" do
    test "saving as draft with no data" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      {:ok, solution} =
        Solutions.create_draft(
          %{
            "action" => "draft",
            "solution" => %{}
          },
          user,
          challenge
        )

      assert solution.submitter_id === user.id
      assert solution.challenge_id === challenge.id
      assert is_nil(solution.title)
      assert solution.status === "draft"
    end

    test "saving as draft with data" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      {:ok, solution} =
        Solutions.create_draft(
          %{
            "title" => "Test Title",
            "brief_description" => "Test Brief Description",
            "description" => "Test Description",
            "external_url" => "www.example.com"
          },
          user,
          challenge
        )

      assert solution.submitter_id === user.id
      assert solution.challenge_id === challenge.id
      assert solution.title === "Test Title"
      assert solution.brief_description === "Test Brief Description"
      assert solution.description === "Test Description"
      assert solution.external_url === "www.example.com"
      assert solution.status === "draft"
    end

    test "submitting with no data" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      {:error, changeset} =
        Solutions.create_review(
          %{
            "action" => "review",
            "solution" => %{}
          },
          user,
          challenge
        )

      assert changeset.errors[:title]
      assert changeset.errors[:brief_description]
      assert changeset.errors[:description]
    end

    test "submitting with data" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      {:ok, solution} =
        Solutions.create_review(
          %{
            "title" => "Test Title",
            "brief_description" => "Test Brief Description",
            "description" => "Test Description",
            "external_url" => "www.example.com"
          },
          user,
          challenge
        )

      {:ok, solution} = Solutions.submit(solution)

      assert solution.submitter_id === user.id
      assert solution.challenge_id === challenge.id
      assert solution.title === "Test Title"
      assert solution.brief_description === "Test Brief Description"
      assert solution.description === "Test Description"
      assert solution.external_url === "www.example.com"
      assert solution.status === "submitted"
    end
  end

  describe "updating a solution" do
    test "update draft removing data" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      solution = SolutionHelpers.create_draft_solution(%{}, user, challenge)

      {:ok, updated_solution} =
        Solutions.update_draft(
          solution,
          %{"title" => nil}
        )

      assert updated_solution.submitter_id === user.id
      assert updated_solution.challenge_id === challenge.id
      assert is_nil(updated_solution.title)
      assert updated_solution.brief_description === "Test Brief Description"
      assert updated_solution.description === "Test Description"
      assert updated_solution.external_url === "www.example.com"
      assert updated_solution.status === "draft"
    end

    test "update draft changing data" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      solution = SolutionHelpers.create_draft_solution(%{}, user, challenge)

      {:ok, updated_solution} =
        Solutions.update_draft(
          solution,
          %{
            "title" => "New Test Title"
          }
        )

      assert updated_solution.submitter_id === user.id
      assert updated_solution.challenge_id === challenge.id
      assert updated_solution.title !== solution.title
      assert updated_solution.brief_description === solution.brief_description
      assert updated_solution.description === solution.description
      assert updated_solution.external_url === solution.external_url
      assert updated_solution.status === "draft"
    end

    test "update draft to submitted no other changes" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      solution = SolutionHelpers.create_draft_solution(%{}, user, challenge)

      {:ok, updated_solution} = Solutions.submit(solution)

      assert updated_solution.submitter_id === user.id
      assert updated_solution.challenge_id === challenge.id
      assert updated_solution.title === solution.title
      assert updated_solution.brief_description === solution.brief_description
      assert updated_solution.description === solution.description
      assert updated_solution.external_url === solution.external_url
      assert updated_solution.status === "submitted"
    end

    test "update draft to submitted with invalid change" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      solution = SolutionHelpers.create_draft_solution(%{}, user, challenge)

      {:error, changeset} =
        Solutions.update_review(
          solution,
          %{"title" => nil}
        )

      assert changeset.errors[:title]
    end

    test "update submitted" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      solution = SolutionHelpers.create_submitted_solution(%{}, user, challenge)

      {:ok, updated_solution} =
        Solutions.update_review(
          solution,
          %{"title" => "New Test Title"}
        )

      {:ok, updated_solution} = Solutions.submit(updated_solution)

      assert updated_solution.submitter_id === user.id
      assert updated_solution.challenge_id === challenge.id
      assert updated_solution.title !== solution.title
      assert updated_solution.brief_description === solution.brief_description
      assert updated_solution.description === solution.description
      assert updated_solution.external_url === solution.external_url
      assert updated_solution.status === "submitted"
      assert_delivered_email(Emails.solution_confirmation(updated_solution))
    end

    test "update submitted with invalid value" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      solution = SolutionHelpers.create_submitted_solution(%{}, user, challenge)

      {:error, changeset} =
        Solutions.update_review(
          solution,
          %{"title" => nil}
        )

      assert changeset.errors[:title]
    end
  end

  describe "deleting a solution" do
    test "successfully" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      solution = SolutionHelpers.create_submitted_solution(%{}, user, challenge)

      {:ok, solution} = Solutions.delete(solution, user)

      assert !is_nil(solution.deleted_at)
    end
  end

  describe "fetching multiple solutions" do
    test "all solutions" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      SolutionHelpers.create_submitted_solution(%{}, user, challenge)

      SolutionHelpers.create_submitted_solution(%{}, user, challenge)

      SolutionHelpers.create_submitted_solution(%{}, user, challenge)

      deleted_solution = SolutionHelpers.create_submitted_solution(%{}, user, challenge)

      Solutions.delete(deleted_solution, user)

      solutions = Solutions.all()

      assert length(solutions) === 3
    end

    test "all solutions paginated" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      SolutionHelpers.create_submitted_solution(%{}, user, challenge)

      SolutionHelpers.create_submitted_solution(%{}, user, challenge)

      SolutionHelpers.create_submitted_solution(%{}, user, challenge)

      deleted_solution = SolutionHelpers.create_submitted_solution(%{}, user, challenge)

      Solutions.delete(deleted_solution, user)

      %{page: solutions, pagination: _pagination} = Solutions.all(page: 1, per: 1)

      assert length(solutions) === 1
    end

    test "filter by submitter id" do
      user = AccountHelpers.create_user()
      user_2 = AccountHelpers.create_user(%{email: "user_2@example.com"})
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      SolutionHelpers.create_submitted_solution(%{}, user_2, challenge)

      SolutionHelpers.create_submitted_solution(%{}, user, challenge)

      SolutionHelpers.create_submitted_solution(%{}, user, challenge)

      deleted_solution = SolutionHelpers.create_submitted_solution(%{}, user_2, challenge)

      Solutions.delete(deleted_solution, user)

      solutions = Solutions.all(filter: %{"submitter_id" => user_2.id})

      assert length(solutions) === 1
    end

    test "filter by challenge id" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})
      challenge_2 = ChallengeHelpers.create_challenge(%{user_id: user.id})

      SolutionHelpers.create_submitted_solution(%{}, user, challenge_2)

      SolutionHelpers.create_submitted_solution(%{}, user, challenge)

      SolutionHelpers.create_submitted_solution(%{}, user, challenge)

      deleted_solution = SolutionHelpers.create_submitted_solution(%{}, user, challenge_2)

      Solutions.delete(deleted_solution, user)

      solutions = Solutions.all(filter: %{"challenge_id" => challenge_2.id})

      assert length(solutions) === 1
    end

    test "filter by search param" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      SolutionHelpers.create_submitted_solution(%{}, user, challenge)

      SolutionHelpers.create_submitted_solution(
        %{
          title: "Filtered Title"
        },
        user,
        challenge
      )

      SolutionHelpers.create_submitted_solution(
        %{
          brief_description: "Filtered Brief Description"
        },
        user,
        challenge
      )

      SolutionHelpers.create_submitted_solution(
        %{
          description: "Filtered Description"
        },
        user,
        challenge
      )

      SolutionHelpers.create_submitted_solution(
        %{
          external_url: "www.example_filtered.com"
        },
        user,
        challenge
      )

      deleted_solution = SolutionHelpers.create_submitted_solution(%{}, user, challenge)

      Solutions.delete(deleted_solution, user)

      deleted_solution =
        SolutionHelpers.create_submitted_solution(
          %{
            title: "Filtered Title"
          },
          user,
          challenge
        )

      Solutions.delete(deleted_solution, user)

      deleted_solution =
        SolutionHelpers.create_submitted_solution(
          %{
            brief_description: "Filtered Brief Description"
          },
          user,
          challenge
        )

      Solutions.delete(deleted_solution, user)

      deleted_solution =
        SolutionHelpers.create_submitted_solution(
          %{
            description: "Filtered Description"
          },
          user,
          challenge
        )

      Solutions.delete(deleted_solution, user)

      deleted_solution =
        SolutionHelpers.create_submitted_solution(
          %{
            external_url: "www.example_filtered.com"
          },
          user,
          challenge
        )

      Solutions.delete(deleted_solution, user)

      solutions = Solutions.all(filter: %{"search" => "Filtered"})

      assert length(solutions) === 4
    end

    test "filter by title" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      SolutionHelpers.create_submitted_solution(
        %{
          title: "Filtered Title"
        },
        user,
        challenge
      )

      SolutionHelpers.create_submitted_solution(%{}, user, challenge)

      SolutionHelpers.create_submitted_solution(%{}, user, challenge)

      deleted_solution =
        SolutionHelpers.create_submitted_solution(
          %{
            title: "Filtered Title"
          },
          user,
          challenge
        )

      Solutions.delete(deleted_solution, user)

      solutions = Solutions.all(filter: %{"title" => "Filtered Title"})

      assert length(solutions) === 1
    end

    test "filter by brief description" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      SolutionHelpers.create_submitted_solution(
        %{
          brief_description: "Filtered Brief Description"
        },
        user,
        challenge
      )

      SolutionHelpers.create_submitted_solution(%{}, user, challenge)

      SolutionHelpers.create_submitted_solution(%{}, user, challenge)

      deleted_solution =
        SolutionHelpers.create_submitted_solution(
          %{
            brief_description: "Filtered Brief Description"
          },
          user,
          challenge
        )

      Solutions.delete(deleted_solution, user)

      solutions = Solutions.all(filter: %{"brief_description" => "Filtered Brief Description"})

      assert length(solutions) === 1
    end

    test "filter by description" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      SolutionHelpers.create_submitted_solution(
        %{
          description: "Filtered Description"
        },
        user,
        challenge
      )

      SolutionHelpers.create_submitted_solution(%{}, user, challenge)

      SolutionHelpers.create_submitted_solution(%{}, user, challenge)

      deleted_solution =
        SolutionHelpers.create_submitted_solution(
          %{
            description: "Filtered Description"
          },
          user,
          challenge
        )

      Solutions.delete(deleted_solution, user)

      solutions = Solutions.all(filter: %{"description" => "Filtered Description"})

      assert length(solutions) === 1
    end

    test "filter by external url" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      SolutionHelpers.create_submitted_solution(
        %{
          external_url: "www.example_filtered.com"
        },
        user,
        challenge
      )

      SolutionHelpers.create_submitted_solution(%{}, user, challenge)

      SolutionHelpers.create_submitted_solution(%{}, user, challenge)

      deleted_solution =
        SolutionHelpers.create_submitted_solution(
          %{
            external_url: "www.example_filtered.com"
          },
          user,
          challenge
        )

      Solutions.delete(deleted_solution, user)

      solutions = Solutions.all(filter: %{"external_url" => "www.example_filtered.com"})

      assert length(solutions) === 1
    end
  end

  describe "fetching a solution" do
    test "successfully by id" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      solution = SolutionHelpers.create_submitted_solution(%{}, user, challenge)

      {:ok, fetched_solution} = Solutions.get(solution.id)

      assert solution.id === fetched_solution.id
    end

    test "not found because of deletion" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      solution = SolutionHelpers.create_submitted_solution(%{}, user, challenge)

      {:ok, deleted_solution} = Solutions.delete(solution, user)

      assert Solutions.get(deleted_solution.id) === {:error, :not_found}
    end

    test "not found" do
      assert Solutions.get(1) === {:error, :not_found}
    end
  end

  describe "security log" do
    test "tracks an event when a solution is submitted" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})
      solution = SolutionHelpers.create_submitted_solution(%{}, user, challenge)

      log_event = List.first(SecurityLogs.all())

      assert log_event.action === "submit"
      assert log_event.originator_id === user.id
      assert log_event.originator_identifier === user.email
      assert log_event.target_id === solution.id
      assert log_event.target_identifier === solution.title
      assert log_event.target_type === "solution"
    end
  end
end

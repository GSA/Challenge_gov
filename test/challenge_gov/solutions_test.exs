defmodule ChallengeGov.SolutionsTest do
  use ChallengeGov.DataCase

  alias ChallengeGov.Solutions
  alias ChallengeGov.TestHelpers.AccountHelpers
  alias ChallengeGov.TestHelpers.ChallengeHelpers
  alias ChallengeGov.TestHelpers.SolutionHelpers

  describe "creating a solution" do
    test "saving as draft with no data" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      {:ok, solution} = Solutions.create(%{
        "action" => "draft",
        "solution" => %{
          submitter_id: user.id,
          challenge_id: challenge.id,
        }
      }, user)

      assert solution.submitter_id === user.id
      assert solution.challenge_id === challenge.id
      assert is_nil(solution.title)
      assert solution.status === "draft"
    end

    test "saving as draft with data" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      {:ok, solution} = Solutions.create(%{
        "action" => "draft",
        "solution" => %{
          submitter_id: user.id,
          challenge_id: challenge.id,
          title: "Test Title",
          brief_description: "Test Brief Description",
          description: "Test Description",
          external_url: "www.example.com"
        }
      }, user)

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

      {:error, changeset} = Solutions.create(%{
        "action" => "submit",
        "solution" => %{
          submitter_id: user.id,
          challenge_id: challenge.id,
        }
      }, user)

      assert changeset.errors[:title]
      assert changeset.errors[:brief_description]
      assert changeset.errors[:description]
      assert changeset.errors[:external_url]
    end    
    
    test "submitting with data" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})

      {:ok, solution} = Solutions.create(%{
        "action" => "submit",
        "solution" => %{
          submitter_id: user.id,
          challenge_id: challenge.id,
          title: "Test Title",
          brief_description: "Test Brief Description",
          description: "Test Description",
          external_url: "www.example.com"
        }
      }, user)

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
      solution = SolutionHelpers.create_draft_solution(%{submitter_id: user.id, challenge_id: challenge.id})

      {:ok, updated_solution} = Solutions.update(solution, %{
        "action" => "draft",
        "solution" => %{
          title: nil
        }
      }, user)

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
      solution = SolutionHelpers.create_draft_solution(%{submitter_id: user.id, challenge_id: challenge.id})

      {:ok, updated_solution} = Solutions.update(solution, %{
        "action" => "draft",
        "solution" => %{
          title: "New Test Title"
        }
      }, user)

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
      solution = SolutionHelpers.create_draft_solution(%{submitter_id: user.id, challenge_id: challenge.id})

      {:ok, updated_solution} = Solutions.update(solution, %{
        "action" => "submit",
        "solution" => %{}
      }, user)

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
      solution = SolutionHelpers.create_draft_solution(%{submitter_id: user.id, challenge_id: challenge.id})

      {:error, changeset} = Solutions.update(solution, %{
        "action" => "submit",
        "solution" => %{title: nil}
      }, user)

      assert changeset.errors[:title]
    end    
    
    test "update submitted" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})
      solution = SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id})

      {:ok, updated_solution} = Solutions.update(solution, %{
        "action" => "submit",
        "solution" => %{title: "New Test Title"}
      }, user)

      assert updated_solution.submitter_id === user.id
      assert updated_solution.challenge_id === challenge.id
      assert updated_solution.title !== solution.title
      assert updated_solution.brief_description === solution.brief_description
      assert updated_solution.description === solution.description
      assert updated_solution.external_url === solution.external_url
      assert updated_solution.status === "submitted"
    end    
    
    test "update submitted with invalid value" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})
      solution = SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id})

      {:error, changeset} = Solutions.update(solution, %{
        "action" => "submit",
        "solution" => %{title: nil}
      }, user)

      assert changeset.errors[:title]
    end
  end

  describe "deleting a solution" do
    test "successfully" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})
      solution = SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id})

      {:ok, solution} = Solutions.delete(solution, user)

      assert !is_nil(solution.deleted_at)
    end
  end

  describe "fetching multiple solutions" do
    test "all solutions" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})
      SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id})
      SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id})
      SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id})
      deleted_solution = SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id})
      Solutions.delete(deleted_solution, user)

      solutions = Solutions.all()

      assert length(solutions) === 3
    end

    test "all solutions paginated" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})
      SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id})
      SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id})
      SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id})
      deleted_solution = SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id})
      Solutions.delete(deleted_solution, user)

      %{page: solutions, pagination: _pagination}= Solutions.all(page: 1, per: 1)

      assert length(solutions) === 1
    end

    test "filter by submitter id" do
      user = AccountHelpers.create_user()
      user_2 = AccountHelpers.create_user(%{email: "user_2@example.com"})
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})
      SolutionHelpers.create_submitted_solution(%{submitter_id: user_2.id, challenge_id: challenge.id})
      SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id})
      SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id})
      deleted_solution = SolutionHelpers.create_submitted_solution(%{submitter_id: user_2.id, challenge_id: challenge.id})
      Solutions.delete(deleted_solution, user)

      solutions = Solutions.all(filter: %{"submitter_id" => user_2.id})

      assert length(solutions) === 1
    end

    test "filter by challenge id" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})
      challenge_2 = ChallengeHelpers.create_challenge(%{user_id: user.id})
      SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge_2.id})
      SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id})
      SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id})
      deleted_solution = SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge_2.id})
      Solutions.delete(deleted_solution, user)

      solutions = Solutions.all(filter: %{"challenge_id" => challenge_2.id})

      assert length(solutions) === 1
    end    
    
    test "filter by search param" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})
      SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id})
      SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id, title: "Filtered Title"})
      SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id, brief_description: "Filtered Brief Description"})
      SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id, description: "Filtered Description"})
      SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id, external_url: "www.example_filtered.com"})

      deleted_solution = SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id})
      Solutions.delete(deleted_solution, user)
      deleted_solution = SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id, title: "Filtered Title"})
      Solutions.delete(deleted_solution, user)
      deleted_solution = SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id, brief_description: "Filtered Brief Description"})
      Solutions.delete(deleted_solution, user)
      deleted_solution = SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id, description: "Filtered Description"})
      Solutions.delete(deleted_solution, user)
      deleted_solution = SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id, external_url: "www.example_filtered.com"})
      Solutions.delete(deleted_solution, user)

      solutions = Solutions.all(filter: %{"search" => "Filtered"})

      assert length(solutions) === 4
    end

    test "filter by title" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})
      SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id, title: "Filtered Title"})
      SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id})
      SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id})
      deleted_solution = SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id, title: "Filtered Title"})
      Solutions.delete(deleted_solution, user)

      solutions = Solutions.all(filter: %{"title" => "Filtered Title"})

      assert length(solutions) === 1
    end

    test "filter by brief description" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})
      SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id, brief_description: "Filtered Brief Description"})
      SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id})
      SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id})
      deleted_solution = SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id, brief_description: "Filtered Brief Description"})
      Solutions.delete(deleted_solution, user)

      solutions = Solutions.all(filter: %{"brief_description" => "Filtered Brief Description"})

      assert length(solutions) === 1
    end

    test "filter by description" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})
      SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id, description: "Filtered Description"})
      SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id})
      SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id})
      deleted_solution = SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id, description: "Filtered Description"})
      Solutions.delete(deleted_solution, user)

      solutions = Solutions.all(filter: %{"description" => "Filtered Description"})

      assert length(solutions) === 1
    end    
    
    test "filter by external url" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})
      SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id, external_url: "www.example_filtered.com"})
      SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id})
      SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id})
      deleted_solution = SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id, external_url: "www.example_filtered.com"})
      Solutions.delete(deleted_solution, user)

      solutions = Solutions.all(filter: %{"external_url" => "www.example_filtered.com"})

      assert length(solutions) === 1
    end
  end

  describe "fetching a solution" do
    test "successfully by id" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})
      solution = SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id})

      {:ok, fetched_solution} = Solutions.get(solution.id)

      assert solution.id === fetched_solution.id
    end

    test "not found because of deletion" do
      user = AccountHelpers.create_user()
      challenge = ChallengeHelpers.create_challenge(%{user_id: user.id})
      solution = SolutionHelpers.create_submitted_solution(%{submitter_id: user.id, challenge_id: challenge.id})
      {:ok, deleted_solution} = Solutions.delete(solution, user)

      assert Solutions.get(deleted_solution.id) === {:error, :not_found}
    end

    test "not found" do
      assert Solutions.get(1) === {:error, :not_found}
    end
  end
end
defmodule ChallengeGov.TestHelpers do
  @moduledoc """
  Helper factory functions
  """

  alias ChallengeGov.Accounts
  alias ChallengeGov.Challenges
  alias ChallengeGov.Repo
  alias ChallengeGov.SupportingDocuments
  alias ChallengeGov.Agencies
  alias ChallengeGov.Timeline

  defp user_attributes(attributes) do
    Map.merge(
      %{
        email: "user@example.com",
        first_name: "John",
        last_name: "Smith",
        phone_number: "123-123-1234",
        password: "password",
        password_confirmation: "password"
      },
      attributes
    )
  end

  def create_user(attributes \\ %{}) do
    attributes = user_attributes(attributes)
    {:ok, user} = Accounts.register(attributes)
    user
  end

  def create_verified_user(attributes \\ %{}) do
    attributes
    |> create_user()
    |> verify_email()
  end

  def create_invited_user(email \\ "invited@example.com") do
    {:ok, user} =
      %Accounts.User{}
      |> Accounts.User.invite_changeset(%{email: email})
      |> Repo.insert()

    user
  end

  @doc """
  Generate a struct with user data
  """
  def user_struct(attributes \\ %{}) do
    attributes = user_attributes(attributes)
    struct(Accounts.User, attributes)
  end

  def verify_email(user) do
    {:ok, user} = Accounts.verify_email(user.email_verification_token)
    user
  end

  defp challenge_attributes(attributes) do
    Map.merge(
      %{
        focus_area: "Transportation",
        name: "Bike lanes",
        description: "We need more bike lanes",
        why: "To bike around",
        fixed_looks_like: "We have more bike lanes",
        technology_example: "We need computers"
      },
      attributes
    )
  end

  # def create_challenge(user, attributes \\ %{}) do
  # attributes = challenge_attributes(attributes)
  # {:ok, challenge} = Challenges.submit(user, attributes)
  # challenge
  # end

  @doc """
  Generate a struct with challenge data
  """
  def challenge_struct(attributes \\ %{}) do
    attributes = challenge_attributes(attributes)
    struct(Challenges.Challenge, attributes)
  end

  def upload_document(user, file_path) do
    {:ok, document} =
      SupportingDocuments.upload(user, %{
        "file" => %{path: file_path}
      })

    document
  end

  def create_event(challenge, attributes \\ %{}) do
    attributes =
      Map.merge(
        %{
          title: "New event",
          body: "The body",
          occurs_on: "2019-05-01"
        },
        attributes
      )

    {:ok, event} = Timeline.create_event(challenge, attributes)
    event
  end

  def create_team(user, attributes \\ %{}) do
    attributes = Map.merge(%{name: "New event"}, attributes)
    {:ok, team} = Agencies.create(user, attributes)
    team
  end
end

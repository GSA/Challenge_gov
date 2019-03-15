defmodule IdeaPortal.TestHelpers do
  @moduledoc """
  Helper factory functions
  """

  alias IdeaPortal.Accounts
  alias IdeaPortal.Challenges
  alias IdeaPortal.SupportingDocuments

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
        why: "To bike around"
      },
      attributes
    )
  end

  def create_challenge(user, attributes \\ %{}) do
    attributes = challenge_attributes(attributes)
    {:ok, challenge} = Challenges.submit(user, attributes)
    challenge
  end

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
end

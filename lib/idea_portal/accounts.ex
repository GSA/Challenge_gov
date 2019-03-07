defmodule IdeaPortal.Accounts do
  @moduledoc """
  Context for user accounts
  """

  alias IdeaPortal.Accounts.User
  alias IdeaPortal.Repo

  @doc """
  Changeset for sign in and registration
  """
  def new() do
    User.create_changeset(%User{}, %{})
  end

  @doc """
  Register an account
  """
  def register(params) do
    %User{}
    |> User.create_changeset(params)
    |> Repo.insert()
  end

  @doc """
  Validate a user's login information
  """
  def validate_login(email, password) do
    Stein.Accounts.validate_login(Repo, User, email, password)
  end

  @doc """
  Find a user by a token
  """
  def get_by_token(token) do
    case Ecto.UUID.cast(token) do
      {:ok, token} ->
        case Repo.get_by(User, token: token) do
          nil ->
            {:error, :not_found}

          user ->
            {:ok, user}
        end

      :error ->
        {:error, :not_found}
    end
  end
end

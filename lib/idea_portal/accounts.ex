defmodule IdeaPortal.Accounts do
  @moduledoc """
  Context for user accounts
  """

  alias IdeaPortal.Accounts.User
  alias IdeaPortal.Emails
  alias IdeaPortal.Mailer
  alias IdeaPortal.Recaptcha
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
    recaptcha_token = Map.get(params, "recaptcha_token")

    case Recaptcha.valid_token?(recaptcha_token) do
      true ->
        %User{}
        |> User.create_changeset(params)
        |> Repo.insert()
        |> maybe_send_email_verification()

      false ->
        %User{}
        |> User.create_changeset(params)
        |> Ecto.Changeset.add_error(:recaptcha_token, "is invalid")
        |> Ecto.Changeset.apply_action(:insert)
    end
  end

  @doc """
  Changeset for account editing
  """
  def edit(user), do: User.update_changeset(user, %{})

  @doc """
  Update an account
  """
  def update(user, params) do
    changeset = User.update_changeset(user, params)

    case Repo.update(changeset) do
      {:ok, user} ->
        maybe_send_email_verification(user, changeset)
        {:ok, user}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  defp maybe_send_email_verification({:ok, user}) do
    user
    |> Emails.verification_email()
    |> Mailer.deliver_later()

    {:ok, user}
  end

  defp maybe_send_email_verification(result), do: result

  defp maybe_send_email_verification(user, changeset) do
    if Map.has_key?(changeset.changes, :email) do
      user
      |> Emails.verification_email()
      |> Mailer.deliver_later()
    end

    user
  end

  @doc """
  Update an account's password
  """
  def update_password(user, params) do
    user
    |> User.password_changeset(params)
    |> Repo.update()
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

  @doc """
  Find and verify a user by their verification token
  """
  def verify_email(token) do
    Stein.Accounts.verify_email(Repo, User, token)
  end

  @doc """
  Check if a user is an admin

      iex> Accounts.is_admin?(%User{role: "admin"})
      true

      iex> Accounts.is_admin?(%User{role: "user"})
      false
  """
  def is_admin?(user)

  def is_admin?(%{role: "admin"}), do: true

  def is_admin?(_), do: false
end

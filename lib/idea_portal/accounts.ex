defmodule IdeaPortal.Accounts do
  @moduledoc """
  Context for user accounts
  """

  alias IdeaPortal.Accounts.Avatar
  alias IdeaPortal.Accounts.User
  alias IdeaPortal.Emails
  alias IdeaPortal.Mailer
  alias IdeaPortal.Recaptcha
  alias IdeaPortal.Repo
  alias Stein.Filter
  alias Stein.Pagination

  import Ecto.Query

  @behaviour Stein.Filter

  @doc """
  Get all accounts
  """
  def all(opts \\ []) do
    opts = Enum.into(opts, %{})

    query = Filter.filter(User, opts[:filter], __MODULE__)

    Pagination.paginate(Repo, query, %{page: opts[:page], per: opts[:per]})
  end

  @doc """
  Get all public accounts
  """
  def public(opts \\ []) do
    opts = Enum.into(opts, %{})

    query =
      User
      |> where([u], u.finalized == true)
      |> where([u], u.display == true)
      |> Filter.filter(opts[:filter], __MODULE__)

    Pagination.paginate(Repo, query, %{page: opts[:page], per: opts[:per]})
  end

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
        register_user(params)

      false ->
        %User{}
        |> User.create_changeset(params)
        |> Ecto.Changeset.add_error(:recaptcha_token, "is invalid")
        |> Ecto.Changeset.apply_action(:insert)
    end
  end

  defp register_user(params) do
    changeset = User.create_changeset(%User{}, params)

    result =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:user, changeset)
      |> Ecto.Multi.run(:avatar, fn _repo, %{user: user} ->
        Avatar.maybe_upload_avatar(user, params)
      end)
      |> Repo.transaction()

    case result do
      {:ok, %{avatar: user}} ->
        send_email_verification(user)

      {:error, _type, changeset, _changes} ->
        {:error, changeset}
    end
  end

  defp send_email_verification(user) do
    user
    |> Emails.verification_email()
    |> Mailer.deliver_later()

    {:ok, user}
  end

  @doc """
  Invite a user to the portal
  """
  def invite(inviter_user, params) do
    recaptcha_token = Map.get(params, "recaptcha_token")

    case Recaptcha.valid_token?(recaptcha_token) do
      true ->
        %User{}
        |> User.invite_changeset(params)
        |> Repo.insert()
        |> maybe_send_invite_email(inviter_user)

      false ->
        %User{}
        |> User.create_changeset(params)
        |> Ecto.Changeset.add_error(:recaptcha_token, "is invalid")
        |> Ecto.Changeset.apply_action(:insert)
    end
  end

  defp maybe_send_invite_email({:ok, invitee_user}, inviter_user) do
    invitee_user
    |> Emails.invitation_email(inviter_user)
    |> Mailer.deliver_later()

    {:ok, invitee_user}
  end

  defp maybe_send_invite_email(result, _inviter_user), do: result

  @doc """
  Finalize an invitation to the portal
  """
  def finalize_invitation(token, params) do
    with {:ok, user} <- get_by_email_token(token) do
      changeset = User.finalize_invite_changeset(user, params)

      result =
        Ecto.Multi.new()
        |> Ecto.Multi.update(:user, changeset)
        |> Ecto.Multi.run(:avatar, fn _repo, %{user: user} ->
          Avatar.maybe_upload_avatar(user, params)
        end)
        |> Repo.transaction()

      case result do
        {:ok, %{avatar: user}} ->
          {:ok, user}

        {:error, _type, changeset, _changes} ->
          {:error, changeset}
      end
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

    result =
      Ecto.Multi.new()
      |> Ecto.Multi.update(:user, changeset)
      |> Ecto.Multi.run(:avatar, fn _repo, %{user: user} ->
        Avatar.maybe_upload_avatar(user, params)
      end)
      |> Repo.transaction()

    case result do
      {:ok, %{avatar: user}} ->
        maybe_send_email_verification(user, changeset)
        {:ok, user}

      {:error, _type, changeset, _changes} ->
        {:error, changeset}
    end
  end

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
  Get a user by an ID
  """
  def get(id) do
    case Repo.get(User, id) do
      nil ->
        {:error, :not_found}

      user ->
        {:ok, user}
    end
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
  Find a user by an email verification token
  """
  def get_by_email_token(token) do
    case Ecto.UUID.cast(token) do
      {:ok, token} ->
        case Repo.get_by(User, email_verification_token: token) do
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
  Check if a user's email was verified
  """
  def email_verified?(user) do
    Stein.Accounts.email_verified?(user)
  end

  @doc """
  Start password reset
  """
  @spec start_password_reset(String.t()) :: :ok
  def start_password_reset(email) do
    case Repo.get_by(User, email: email, finalized: true) do
      nil ->
        :ok

      _user ->
        Stein.Accounts.start_password_reset(Repo, User, email, fn user ->
          user
          |> Emails.password_reset()
          |> Mailer.deliver_later()
        end)
    end
  end

  @doc """
  Reset a password
  """
  @spec reset_password(String.t(), map()) :: {:ok, User.t()} | :error
  def reset_password(token, params) do
    Stein.Accounts.reset_password(Repo, User, token, params)
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

  @impl true
  def filter_on_attribute({"search", value}, query) do
    value = "%" <> value <> "%"

    where(
      query,
      [a],
      ilike(a.first_name, ^value) or ilike(a.last_name, ^value) or ilike(a.email, ^value)
    )
  end

  @doc """
  Toggle display status of a user
  """
  def toggle_display(user) do
    user
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_change(:display, !user.display)
    |> Repo.update()
  end
end

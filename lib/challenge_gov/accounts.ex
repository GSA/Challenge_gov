defmodule ChallengeGov.Accounts do
  @moduledoc """
  Context for user accounts
  """

  alias ChallengeGov.Accounts.Avatar
  alias ChallengeGov.Accounts.User
  alias ChallengeGov.CertificationLogs
  alias ChallengeGov.Challenges.Challenge
  alias ChallengeGov.Challenges.ChallengeOwner
  alias ChallengeGov.Recaptcha
  alias ChallengeGov.Repo
  alias ChallengeGov.Security
  alias ChallengeGov.SecurityLogs
  alias ChallengeGov.Emails
  alias ChallengeGov.Mailer
  alias Stein.Filter
  alias Stein.Pagination

  import Ecto.Query

  @behaviour Stein.Filter

  @doc false
  def roles(user) do
    case user.role do
      "super_admin" ->
        User.roles()

      "admin" ->
        Enum.slice(User.roles(), 2..2)
    end
  end

  def get_role_rank(role) do
    Enum.find(User.roles(), fn r -> r.id === role end).rank
  end

  def statuses(), do: User.statuses()

  @doc """
  Get all accounts
  """
  def all(opts \\ []) do
    opts = Enum.into(opts, %{})

    query = Filter.filter(User, opts[:filter], __MODULE__)

    Pagination.paginate(Repo, query, %{page: opts[:page], per: opts[:per]})
  end

  @doc """
  Get all accounts
  """
  def all_for_select() do
    Repo.all(User)
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
  Find accounts that are OK to invite to this team

  They don't already belong
  """
  def for_inviting_to(opts \\ []) do
    opts = Enum.into(opts, %{})

    User
    |> where([u], u.finalized == true)
    |> where([u], u.display == true)
    |> where(
      [u],
      fragment(
        "(select count(*) from team_members where user_id = ? and status = 'accepted') = 0",
        u.id
      )
    )
    |> filter_invite_users(opts)
    |> limit(9)
    |> Repo.all()
  end

  def filter_invite_users(query, %{search: search}) when search != nil and search != "" do
    names = String.split(search, " ")

    conditions =
      Enum.reduce(names, false, fn name, query ->
        name = "%#{name}%"
        dynamic([u], ilike(u.first_name, ^name) or ilike(u.last_name, ^name) or ^query)
      end)

    where(query, ^conditions)
  end

  def filter_invite_users(query, _opts), do: query

  @doc """
  Changeset for sign in and registration
  """
  def new() do
    User.create_changeset(%User{}, %{})
  end

  @doc """
  Create an account via admin panel
  """
  def create(params, originator, remote_ip) do
    changeset =
      %User{}
      |> User.create_changeset(params)

    result =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:user, changeset)
      |> Ecto.Multi.run(:log, fn _repo, %{user: user} ->
        SecurityLogs.track(%{
          originator_id: originator.id,
          originator_role: originator.role,
          originator_identifier: originator.email,
          originator_remote_ip: remote_ip,
          target_id: user.id,
          target_type: user.role,
          target_identifier: user.email,
          action: "status_change",
          details: %{status: "created"}
        })
      end)
      |> Repo.transaction()

    case result do
      {:ok, %{user: user}} ->
        {:ok, user}

      {:error, _type, changeset, _changes} ->
        {:error, changeset}
    end
  end

  @doc """
  Create an account
  """
  def create(remote_ip, params) do
    changeset =
      %User{}
      |> User.create_changeset(params)

    result =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:user, changeset)
      |> Ecto.Multi.run(:log, fn _repo, %{user: user} ->
        SecurityLogs.track(%{
          originator_id: user.id,
          originator_role: user.role,
          originator_identifier: user.email,
          originator_remote_ip: remote_ip,
          action: "status_change",
          details: %{status: "created"}
        })
      end)
      |> Repo.transaction()

    case result do
      {:ok, %{user: user}} ->
        {:ok, user}

      {:error, _type, changeset, _changes} ->
        {:error, changeset}
    end
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
        {:ok, user}

      {:error, _type, changeset, _changes} ->
        {:error, changeset}
    end
  end

  @doc """
  Changeset for account editing
  """
  def edit(user), do: User.update_changeset(user, %{})

  @doc """
  Update last active timestamp
  """
  def update_last_active(user) do
    user
    |> User.last_active_changeset()
    |> Repo.update()
  end

  @doc """
  Update active session
  """
  def update_active_session(user, param) do
    user
    |> User.active_session_changeset(param)
    |> Repo.update()
  end

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
        {:ok, user}

      {:error, _type, changeset, _changes} ->
        {:error, changeset}
    end
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
  Update an account's terms
  """
  def update_terms(user, params) do
    user
    |> User.terms_changeset(params)
    |> Repo.update()
  end

  @doc """
  Validate a user's login information
  """
  def validate_login(email, password) do
    Stein.Accounts.validate_login(Repo, User, email, password)
  end

  @doc """
  Parse login.gov data into our system
  """
  def map_from_login(userinfo, remote_ip) do
    # look for user based on token
    case get_by_token(userinfo["sub"]) do
      {:error, :not_found} ->
        # look for users created by admin which have emails, but no token
        case get_by_email(userinfo["email"]) do
          {:error, :not_found} ->
            %{"email" => email} = userinfo

            create(remote_ip, %{
              email: email,
              role: default_role_for_email(email),
              token: userinfo["sub"],
              terms_of_use: nil,
              privacy_guidelines: nil,
              status: "pending"
            })

          {:ok, user} ->
            update_admin_added_user(user, userinfo, remote_ip)
        end

      {:ok, account_user} ->
        update_active_session(account_user, true)

        SecurityLogs.track(%{
          originator_id: account_user.id,
          originator_role: account_user.role,
          originator_identifier: account_user.email,
          originator_remote_ip: remote_ip,
          action: "accessed_site"
        })

        {:ok, account_user}
    end
  end

  defp default_role_for_email(email) do
    case Security.default_challenge_owner?(email) do
      true ->
        "challenge_owner"

      false ->
        "solver"
    end
  end

  @doc """
  Update user added by admin
  """
  def update_admin_added_user(user, userinfo, remote_ip) do
    result =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:user, fn _repo, _changes ->
        __MODULE__.update(user, %{token: userinfo["sub"]})
      end)
      |> Ecto.Multi.run(:security_tracking, fn _repo, _changes ->
        SecurityLogs.track(%{
          originator_id: user.id,
          originator_role: user.role,
          originator_identifier: user.email,
          originator_remote_ip: remote_ip,
          action: "accessed_site"
        })
      end)
      |> Ecto.Multi.run(:certification_tracking, fn _repo, _changes ->
        CertificationLogs.track(%{
          user_id: user.id,
          user_role: user.role,
          user_identifier: user.email,
          user_remote_ip: remote_ip,
          certified_at: Timex.now(),
          expires_at: CertificationLogs.calulate_expiry()
        })
      end)
      |> Repo.transaction()

    case result do
      {:ok, %{user: user}} ->
        {:ok, user}

      {:error, _type, changeset, _changes} ->
        {:error, changeset}
    end
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
  Get a user by an ID, public view
  """
  def public_get(id) do
    case Repo.get_by(User, id: id, display: true) do
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
  Find a user by an email
  """
  def get_by_email(email) do
    case Repo.get_by(User, email: email) do
      nil ->
        {:error, :not_found}

      user ->
        {:ok, user}
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

  def has_admin_access?(user) do
    is_super_admin?(user) or is_admin?(user)
  end

  @doc """
  Check if a user is an super_admin

      iex> Accounts.is_super_admin?(%User{role: "super_admin"})
      true

      iex> Accounts.is_super_admin?(%User{role: "user"})
      false
  """
  def is_super_admin?(user)

  def is_super_admin?(%{role: "super_admin"}), do: true

  def is_super_admin?(_), do: false

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

  @doc """
  Check if a user is a challenge owner

      iex> Accounts.is_challenge_owner?(%User{role: "challenge_owner"})
      true

      iex> Accounts.is_challenge_owner?(%User{role: "challenge_owner"})
      false
  """
  def is_challenge_owner?(user)

  def is_challenge_owner?(%{role: "challenge_owner"}), do: true

  def is_challenge_owner?(_), do: false

  @doc """
  Check if a user is a solver

      iex> Accounts.is_solver?(%User{role: "solver"})
      true

      iex> Accounts.is_solver?(%User{role: "challenge_owner"})
      false
  """
  def is_solver?(user)

  def is_solver?(%{role: "solver"}), do: true

  def is_solver?(_), do: false

  @doc """
  Checks if a user's role is at or above the specified role
  """
  def role_at_or_above(user, role) do
    get_role_rank(user.role) <= get_role_rank(role)
  end

  @doc """
  Checks if a user's role is at or below the specified role
  """
  def role_at_or_below(user, role) do
    get_role_rank(user.role) >= get_role_rank(role)
  end

  @doc """
  Check if a user has accepted all terms
  """
  def has_accepted_terms?(user)

  def has_accepted_terms?(%{terms_of_use: nil}), do: false

  def has_accepted_terms?(%{privacy_guidelines: nil}), do: false

  def has_accepted_terms?(%{terms_of_use: _timestamp}), do: true

  def has_accepted_terms?(%{privacy_guidelines: _timestamp}), do: true

  @impl true
  def filter_on_attribute({"search", value}, query) do
    value = "%" <> value <> "%"

    where(
      query,
      [a],
      ilike(a.first_name, ^value) or ilike(a.last_name, ^value) or ilike(a.email, ^value)
    )
  end

  # Status checks
  def is_pending?(%{status: "pending"}), do: true
  def is_pending?(_user), do: false

  def is_active?(%{status: "active"}), do: true
  def is_active?(_user), do: false

  def is_suspended?(%{status: "suspended"}), do: true
  def is_suspended?(_user), do: false

  def is_revoked?(%{status: "revoked"}), do: true
  def is_revoked?(_user), do: false

  def is_deactivated?(%{status: "deactivated"}), do: true
  def is_deactivated?(_user), do: false

  def is_decertified?(%{status: "decertified"}), do: true
  def is_decertified?(_user), do: false

  @doc """
  Activate pending user. Check certification, change status, allow login if certified
  """
  def activate(user = %{status: "pending"}, approver, approver_remote_ip) do
    # pending users get certified on activation unless they are solvers
    if user.role != "solver" do
      CertificationLogs.certify_user_with_approver(user, approver, approver_remote_ip)
      activate(user, user.status, approver, approver_remote_ip)
    else
      activate(user, user.status, approver, approver_remote_ip)
    end
  end

  @doc """
  Activate a suspended user. Check certification, change status
  """
  def activate(user = %{status: "suspended"}, originator, remote_ip) do
    case CertificationLogs.get_current_certification(user) do
      {:ok, certification} ->
        # could return empty map for a solver
        if certification != %{} and
             Timex.to_unix(certification.expires_at) < Timex.to_unix(Timex.now()) do
          {:ok, decertified_user} = decertify(user)
          {:error, :certification_required, decertified_user}
        else
          activate(user, user.status, originator, remote_ip)
        end

      {:error, :no_log_found} ->
        activate(user, user.status, originator, remote_ip)
    end
  end

  @doc """
  Activate a revoked user. Renew certification, change status, allow login
  """
  def activate(user = %{status: "revoked"}, originator, remote_ip) do
    if user.role != "solver",
      do: manually_recertify_user(user, originator, remote_ip),
      else: activate(user, user.status, originator, remote_ip)
  end

  @doc """
  Activate a user. Change status, allows login
  """
  def activate(user, originator, remote_ip) do
    previous_status = user.status

    changeset =
      user
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_change(:status, "active")
      |> maybe_update_request_renewal(user)

    result =
      Ecto.Multi.new()
      |> Ecto.Multi.update(:user, changeset)
      |> Ecto.Multi.run(:log, fn _repo, _changes ->
        SecurityLogs.track(%{
          originator_id: originator.id,
          originator_role: originator.role,
          originator_identifier: originator.email,
          originator_remote_ip: remote_ip,
          target_id: user.id,
          target_type: user.role,
          target_identifier: user.email,
          action: "status_change",
          details: %{previous_status: previous_status, new_status: "active"}
        })
      end)
      |> Repo.transaction()

    case result do
      {:ok, %{user: user}} ->
        {:ok, user}

      {:error, _type, changeset, _changes} ->
        {:error, changeset}
    end
  end

  @doc """
  Activate users who previously needed extra actions. Change status, allows login
  """
  def activate(user, previous_status, originator, remote_ip) do
    changeset =
      user
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_change(:status, "active")
      |> maybe_update_request_renewal(user)

    result =
      Ecto.Multi.new()
      |> Ecto.Multi.update(:user, changeset)
      |> Ecto.Multi.run(:log, fn _repo, _changes ->
        SecurityLogs.track(%{
          originator_id: originator.id,
          originator_role: originator.role,
          originator_identifier: originator.email,
          originator_remote_ip: remote_ip,
          target_id: user.id,
          target_type: user.role,
          target_identifier: user.email,
          action: "status_change",
          details: %{previous_status: previous_status, new_status: "active"}
        })
      end)
      |> Repo.transaction()

    case result do
      {:ok, %{user: user}} ->
        {:ok, user}

      {:error, _type, changeset, _changes} ->
        {:error, changeset}
    end
  end

  defp maybe_update_request_renewal(struct, user) do
    if user.renewal_request == "activation" do
      Ecto.Changeset.put_change(struct, :renewal_request, nil)
    else
      struct
    end
  end

  @doc """
  Suspend a user. User can no longer login. Still has data access after
  """
  def suspend(user, originator, remote_ip) do
    previous_status = user.status

    changeset =
      user
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_change(:status, "suspended")

    result =
      Ecto.Multi.new()
      |> Ecto.Multi.update(:user, changeset)
      |> Ecto.Multi.run(:log, fn _repo, _changes ->
        SecurityLogs.track(%{
          originator_id: originator.id,
          originator_role: originator.role,
          originator_identifier: originator.email,
          originator_remote_ip: remote_ip,
          target_id: user.id,
          target_type: user.role,
          target_identifier: user.email,
          action: "status_change",
          details: %{previous_status: previous_status, new_status: "suspended"}
        })
      end)
      |> Repo.transaction()

    case result do
      {:ok, %{user: user}} ->
        {:ok, user}

      {:error, _type, changeset, _changes} ->
        {:error, changeset}
    end
  end

  @doc """
  Revoke a user. User can no longer login. Removes access to their challenges
  """
  def revoke(user, originator, remote_ip) do
    previous_status = user.status

    changeset =
      user
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_change(:status, "revoked")

    result =
      Ecto.Multi.new()
      |> Ecto.Multi.update(:user, changeset)
      |> Ecto.Multi.run(:log, fn _repo, _changes ->
        SecurityLogs.track(%{
          originator_id: originator.id,
          originator_role: originator.role,
          originator_identifier: originator.email,
          originator_remote_ip: remote_ip,
          target_id: user.id,
          target_type: user.role,
          target_identifier: user.email,
          action: "status_change",
          details: %{previous_status: previous_status, new_status: "revoked"}
        })
      end)
      |> Repo.transaction()

    case result do
      {:ok, %{user: user}} ->
        revoke_challenge_ownership(user)
        {:ok, user}

      {:error, _type, changeset, _changes} ->
        {:error, changeset}
    end
  end

  @doc """
  Deactivate a user. User can no longer login. Still has access after
  """

  def deactivate(user) do
    previous_status = user.status

    changeset =
      user
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_change(:status, "deactivated")

    result =
      Ecto.Multi.new()
      |> Ecto.Multi.update(:user, changeset)
      |> Ecto.Multi.run(:log, fn _repo, _changes ->
        SecurityLogs.track(%{
          target_id: user.id,
          target_type: user.role,
          target_identifier: user.email,
          action: "status_change",
          details: %{previous_status: previous_status, new_status: "deactivated"}
        })
      end)
      |> Repo.transaction()

    case result do
      {:ok, %{user: user}} ->
        {:ok, user}

      {:error, _type, changeset, _changes} ->
        {:error, changeset}
    end
  end

  @doc """
  Decertify a user. User can no longer login. Removes access to their challenges
  """
  def decertify(user) do
    previous_status = user.status

    changeset =
      user
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_change(:status, "decertified")
      |> Ecto.Changeset.put_change(:terms_of_use, nil)
      |> Ecto.Changeset.put_change(:privacy_guidelines, nil)

    result =
      Ecto.Multi.new()
      |> Ecto.Multi.update(:user, changeset)
      |> Ecto.Multi.run(:log, fn _repo, _changes ->
        SecurityLogs.track(%{
          target_id: user.id,
          target_type: user.role,
          target_identifier: user.role,
          action: "status_change",
          details: %{previous_status: previous_status, new_status: "decertified"}
        })
      end)
      |> Repo.transaction()

    case result do
      {:ok, %{user: user}} ->
        revoke_challenge_ownership(user)
        {:ok, user}

      {:error, _type, _changeset, _changes} ->
        {:error, :not_decertified}
    end
  end

  def manually_recertify_user(user, approver, approver_remote_ip) do
    result =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:user, fn _repo, _changes ->
        activate(user, user.status, approver, approver_remote_ip)
      end)
      |> Ecto.Multi.run(:renew_terms, fn _repo, _changes ->
        __MODULE__.update(user, get_recertify_update_params(user))
      end)
      |> Ecto.Multi.run(:certification_record, fn _repo, _changes ->
        CertificationLogs.certify_user_with_approver(user, approver, approver_remote_ip)
      end)
      |> Repo.transaction()

    case result do
      {:ok, %{user: user}} ->
        {:ok, user}

      {:error, _type, _changeset, _changes} ->
        {:error, :not_recertified}
    end
  end

  defp get_recertify_update_params(user) do
    case user.renewal_request == "certification" do
      true ->
        %{
          "terms_of_use" => nil,
          "privacy_guidelines" => nil,
          "renewal_request" => nil
        }

      false ->
        %{"terms_of_use" => nil, "privacy_guidelines" => nil}
    end
  end

  @doc """
  Removes a user's access to their challenges while preserving they previously had access
  """
  def revoke_challenge_ownership(user) do
    ChallengeOwner
    |> where([co], co.user_id == ^user.id)
    |> Repo.update_all(set: [revoked_at: Timex.now()])
  end

  def revoked_challenges(user) do
    Challenge
    |> where([c], is_nil(c.deleted_at))
    |> join(:inner, [c], co in assoc(c, :challenge_owners))
    |> where([c, co], co.user_id == ^user.id and not is_nil(co.revoked_at))
    |> Repo.all()
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

  @doc """
  Toggle admin status of a user
  """
  def toggle_admin(user = %{role: "admin"}) do
    user
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_change(:role, "user")
    |> Repo.update()
  end

  def toggle_admin(user = %{role: "user"}) do
    user
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_change(:role, "admin")
    |> Repo.update()
  end

  @doc """
  check for activity in last 90 days
  """
  def check_all_last_actives() do
    Enum.map(all_for_select(), fn user ->
      user
      |> maybe_send_deactivation_notice(
        Security.deactivate_days(),
        Security.deactivate_warning_one_days(),
        Security.deactivate_warning_two_days()
      )
      |> check_last_active
    end)
  end

  def check_last_active(user) do
    will_timeout_on =
      user.last_active
      |> Timex.to_date()
      |> Timex.shift(days: Security.deactivate_days())

    case Timex.compare(Timex.today(), will_timeout_on, :days) === 0 do
      true ->
        deactivate(user)

      _ ->
        nil
    end
  end

  @doc """
  Sends deactivation emails to people approaching their 90 days of inactivity
  """
  def maybe_send_deactivation_notice(user, timeout, warning_one_days, warning_two_days) do
    will_timeout_on = Timex.shift(Timex.to_date(user.last_active), days: timeout)
    warning_one = Timex.shift(will_timeout_on, days: -1 * warning_one_days)
    warning_two = Timex.shift(will_timeout_on, days: -1 * warning_two_days)
    one_day_warning = Timex.shift(will_timeout_on, days: -1)
    now = Timex.today()

    cond do
      Timex.compare(now, warning_one, :days) === 0 ->
        user
        |> Emails.days_deactivation_warning(warning_one_days)
        |> Mailer.deliver_later()

      Timex.compare(now, warning_two, :days) === 0 ->
        user
        |> Emails.days_deactivation_warning(warning_two_days)
        |> Mailer.deliver_later()

      Timex.compare(now, one_day_warning, :days) === 0 ->
        user
        |> Emails.one_day_deactivation_warning()
        |> Mailer.deliver_later()

      true ->
        nil
    end

    user
  end
end

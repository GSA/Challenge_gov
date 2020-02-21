defmodule ChallengeGov.Challenges do
  @moduledoc """
  Context for Challenges

  Statuses for challenges:
  - pending: Awaiting review by an admin, hidden to the public
  - created: Published by an admin, viewable to the public
  - archived: Archived by an admin, hidden to the public
  """

  alias ChallengeGov.Accounts
  alias ChallengeGov.Challenges.Challenge
  alias ChallengeGov.Challenges.FederalPartner
  alias ChallengeGov.Challenges.Logo
  alias ChallengeGov.Challenges.WinnerImage
  alias ChallengeGov.Repo
  alias ChallengeGov.SupportingDocuments
  alias ChallengeGov.Timeline
  alias ChallengeGov.Timeline.Event
  alias Stein.Filter
  alias Stein.Pagination

  import Ecto.Query

  @behaviour Stein.Filter

  @doc false
  def challenge_types(), do: Challenge.challenge_types()

  @doc false
  def legal_authority(), do: Challenge.legal_authority()

  @doc """
  New changeset for a challenge
  """
  def new(user) do
    %Challenge{}
    |> Repo.preload([:federal_partners, :non_federal_partners, :user])
    |> Challenge.create_changeset(%{}, user)
  end

  # @doc """
  # Changeset for adding a challenge (as an admin)
  # """
  # def admin_new(user) do
  #   %Challenge{}
  #   |> Repo.preload(:non_federal_partners)
  #   |> Map.put(:federal_partners, [])
  #   |> Map.put(:non_federal_partners, [])
  #   |> Challenge.admin_changeset(%{}, user)
  # end

  @doc """
  Changeset for editing a challenge (as an admin)
  """
  def edit(challenge) do
    challenge
    |> Repo.preload([:non_federal_partners, :events, :user])
    |> Challenge.update_changeset(%{})
  end

  @doc """
  Get all challenges
  """
  def all(opts \\ []) do
    query =
      Challenge
      |> preload([:agency, :user])
      |> where([c], c.status == "created")
      |> order_by([c], desc: c.published_on, asc: c.id)
      |> Filter.filter(opts[:filter], __MODULE__)

    Pagination.paginate(Repo, query, %{page: opts[:page], per: opts[:per]})
  end

  @doc """
  Get all challenges
  """
  def admin_all(opts \\ []) do
    query =
      Challenge
      |> preload([:agency, :user])
      |> order_by([c], desc: c.status, desc: c.id)
      |> Filter.filter(opts[:filter], __MODULE__)

    Pagination.paginate(Repo, query, %{page: opts[:page], per: opts[:per]})
  end

  @doc """
  Get all challenges for a user
  """
  def all_for_user(user, opts \\ []) do
    query =
      Challenge
      |> preload([:agency])
      |> order_by([c], desc: c.status, desc: c.id)
      |> Filter.filter(opts[:filter], __MODULE__)

    query =
      if user.role == "challenge_owner" do
        where(query, [c], c.user_id == ^user.id)
      else
        query
      end

    Pagination.paginate(Repo, query, %{page: opts[:page], per: opts[:per]})
  end

  @doc """
  Get all challenges
  """
  def admin_counts() do
    challenges =
      Challenge
      |> Repo.all()

    pending = Enum.count(challenges, &(&1.status === "pending"))
    created = Enum.count(challenges, &(&1.status === "created"))
    archived = Enum.count(challenges, &(&1.status === "archived"))

    %{pending: pending, created: created, archived: archived}
  end

  @doc """
  Get a challenge
  """
  def get(id) do
    case Repo.get(Challenge, id) do
      nil ->
        {:error, :not_found}

      challenge ->
        challenge =
          Repo.preload(challenge, [
            :supporting_documents,
            :user,
            :federal_partner_agencies,
            :non_federal_partners,
            :agency
          ])

        challenge = Repo.preload(challenge, events: from(e in Event, order_by: e.occurs_on))
        {:ok, challenge}
    end
  end

  @doc """
  Filter a challenge for created state

  Returns `{:error, :not_found}` if the challenge is not created, to hit the same
  fallback as if the challenge was a bad ID.

      iex> Challenges.filter_for_created(%Challenge{status: "created"})
      {:ok, %Challenge{status: "created"}}

      iex> Challenges.filter_for_created(%Challenge{status: "pending"})
      {:error, :not_found}
  """
  def filter_for_created(challenge) do
    case created?(challenge) do
      true ->
        {:ok, challenge}

      false ->
        {:error, :not_found}
    end
  end

  @doc """
  Submit a new challenge for a user
  """
  def submit(user, params) do
    result =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:challenge, submit_challenge(user, params))
      |> attach_documents(params)
      |> Ecto.Multi.run(:logo, fn _repo, %{challenge: challenge} ->
        Logo.maybe_upload_logo(challenge, params)
      end)
      |> Ecto.Multi.run(:winner_image, fn _repo, %{challenge: challenge} ->
        WinnerImage.maybe_upload_winner_image(challenge, params)
      end)
      |> Repo.transaction()

    case result do
      {:ok, %{challenge: challenge}} ->
        {:ok, challenge}

      {:error, :challenge, changeset, _} ->
        {:error, changeset}

      {:error, {:document, _}, _, _} ->
        user
        |> Ecto.build_assoc(:challenges)
        |> Challenge.create_changeset(params, user)
        |> Ecto.Changeset.add_error(:document_ids, "are invalid")
        |> Ecto.Changeset.apply_action(:insert)
    end
  end

  defp submit_challenge(user, params) do
    user
    |> Ecto.build_assoc(:challenges)
    |> Challenge.create_changeset(params, user)
  end

  @doc """
  Submit a new challenge for a user
  """
  def create(user, params) do
    result =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:challenge, create_challenge(user, params))
      |> attach_federal_partners(params)
      |> attach_documents(params)
      |> Ecto.Multi.run(:logo, fn _repo, %{challenge: challenge} ->
        Logo.maybe_upload_logo(challenge, params)
      end)
      |> Ecto.Multi.run(:winner_image, fn _repo, %{challenge: challenge} ->
        WinnerImage.maybe_upload_winner_image(challenge, params)
      end)
      |> Repo.transaction()

    case result do
      {:ok, %{challenge: challenge}} ->
        {:ok, challenge}

      {:error, :challenge, changeset, _} ->
        {:error, changeset}

      {:error, {:document, _}, _, _} ->
        user
        |> Ecto.build_assoc(:challenges)
        |> Challenge.admin_changeset(params, user)
        |> Ecto.Changeset.add_error(:document_ids, "are invalid")
        |> Ecto.Changeset.apply_action(:insert)
    end
  end

  defp create_challenge(user, params) do
    user
    |> Ecto.build_assoc(:challenges)
    |> Map.put(:federal_partners, [])
    |> Challenge.admin_changeset(params, user)
  end

  defp attach_federal_partners(multi, %{federal_partners: ids}) do
    attach_federal_partners(multi, %{"federal_partners" => ids})
  end

  defp attach_federal_partners(multi, %{"federal_partners" => ids}) do
    multi =
      Ecto.Multi.run(multi, :delete_agencies, fn _repo, changes ->
        {:ok,
         Repo.delete_all(
           from(fp in FederalPartner, where: fp.challenge_id == ^changes.challenge.id)
         )}
      end)

    Enum.reduce(ids, multi, fn agency_id, multi ->
      Ecto.Multi.run(multi, {:agency, agency_id}, fn _repo, changes ->
        %FederalPartner{}
        |> FederalPartner.changeset(%{
          agency_id: agency_id,
          challenge_id: changes.challenge.id
        })
        |> Repo.insert()
      end)
    end)
  end

  defp attach_federal_partners(multi, _params), do: multi

  defp attach_documents(multi, %{document_ids: ids}) do
    attach_documents(multi, %{"document_ids" => ids})
  end

  defp attach_documents(multi, %{"document_ids" => ids}) do
    Enum.reduce(ids, multi, fn document_id, multi ->
      Ecto.Multi.run(multi, {:document, document_id}, fn _repo, changes ->
        document_id
        |> SupportingDocuments.get()
        |> attach_document(changes.challenge)
      end)
    end)
  end

  defp attach_documents(multi, _params), do: multi

  defp attach_document({:ok, document}, challenge) do
    SupportingDocuments.attach_to_challenge(document, challenge, "resources")
  end

  defp attach_document(result, _challenge), do: result

  @doc """
  Update a challenge
  """
  def update(challenge, params) do
    challenge = Repo.preload(challenge, [:non_federal_partners, :events])

    params =
      params
      |> Map.put_new("non_federal_partners", [])
      |> Map.put_new("events", [])

    changeset =
      challenge
      |> Challenge.update_changeset(params)

    result =
      Ecto.Multi.new()
      |> Ecto.Multi.update(:challenge, changeset)
      |> attach_federal_partners(params)
      |> Ecto.Multi.run(:event, fn _repo, %{challenge: challenge} ->
        maybe_create_event(challenge, changeset)
      end)
      |> Ecto.Multi.run(:logo, fn _repo, %{challenge: challenge} ->
        Logo.maybe_upload_logo(challenge, params)
      end)
      |> Ecto.Multi.run(:winner_image, fn _repo, %{challenge: challenge} ->
        WinnerImage.maybe_upload_winner_image(challenge, params)
      end)
      |> Repo.transaction()

    case result do
      {:ok, %{challenge: challenge}} ->
        {:ok, challenge}

      {:error, _type, changeset, _changes} ->
        {:error, changeset}
    end
  end

  @doc """
  Checks if a user is allowed to edit a challenge
  """
  def allowed_to_edit(user, challenge) do
    if user.id == challenge.user_id or
         Accounts.is_admin?(user) or Accounts.is_super_admin?(user) do
      {:ok, challenge}
    else
      {:error, :not_permitted}
    end
  end

  defp maybe_create_event(challenge, changeset) do
    case is_nil(Ecto.Changeset.get_change(changeset, :status)) do
      true ->
        {:ok, challenge}

      false ->
        create_status_event(challenge)
        {:ok, challenge}
    end
  end

  @doc """
  Create a new status event when the status changes
  """
  def create_status_event(challenge = %{status: "created"}) do
    Timeline.create_event(challenge, %{
      title: "Created",
      occurs_on: Timeline.today()
    })
  end

  def create_status_event(challenge = %{status: "champion assigned"}) do
    Timeline.create_event(challenge, %{
      title: "Champion Assigned",
      occurs_on: Timeline.today()
    })
  end

  def create_status_event(challenge = %{status: "design"}) do
    Timeline.create_event(challenge, %{
      title: "Design",
      occurs_on: Timeline.today()
    })
  end

  def create_status_event(challenge = %{status: "vetted"}) do
    Timeline.create_event(challenge, %{
      title: "Vetted",
      occurs_on: Timeline.today()
    })
  end

  def create_status_event(_), do: :ok

  @doc """
  Check if a challenge is created

      iex> Challenges.created?(%Challenge{status: "pending"})
      false

      iex> Challenges.created?(%Challenge{status: "created"})
      true

      iex> Challenges.created?(%Challenge{status: "archived"})
      false
  """
  def created?(challenge) do
    challenge.status == "created"
  end

  @doc """
  Check if a challenge is publishable

      iex> Challenges.publishable?(%Challenge{status: "pending"})
      true

      iex> Challenges.publishable?(%Challenge{status: "created"})
      false

      iex> Challenges.publishable?(%Challenge{status: "archived"})
      true
  """
  def publishable?(challenge) do
    challenge.status != "created"
  end

  @doc """
  Publish a challenge

  Sets status to "created"
  """
  def publish(challenge) do
    changeset = Challenge.publish_changeset(challenge)

    result =
      Ecto.Multi.new()
      |> Ecto.Multi.update(:challenge, changeset)
      |> Ecto.Multi.run(:event, fn _repo, %{challenge: challenge} ->
        maybe_create_event(challenge, changeset)
      end)
      |> Repo.transaction()

    case result do
      {:ok, %{challenge: challenge}} ->
        {:ok, challenge}

      {:error, _type, changeset, _changes} ->
        {:error, changeset}
    end
  end

  @doc """
  Reject a challenge

  Sets status to "rejected"
  """
  def reject(challenge) do
    changeset = Challenge.reject_changeset(challenge)

    result =
      Ecto.Multi.new()
      |> Ecto.Multi.update(:challenge, changeset)
      |> Repo.transaction()

    case result do
      {:ok, %{challenge: challenge}} ->
        {:ok, challenge}

      {:error, _type, changeset, _changes} ->
        {:error, changeset}
    end
  end

  @doc """
  Check if a challenge is rejectable
  """
  def rejectable?(challenge) do
    challenge.status != "rejected" &&
      challenge.status != "created"
  end

  @doc """
  Check if a challenge is archivable

      iex> Challenges.archivable?(%Challenge{status: "pending"})
      true

      iex> Challenges.archivable?(%Challenge{status: "created"})
      true

      iex> Challenges.archivable?(%Challenge{status: "archived"})
      false
  """
  def archivable?(challenge) do
    challenge.status != "archived"
  end

  @doc """
  Archive a challenge

  Sets status to "archived"
  """
  def archive(challenge) do
    challenge
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_change(:status, "archived")
    |> Repo.update()
  end

  def remove_logo(challenge) do
    challenge
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_change(:logo_key, nil)
    |> Ecto.Changeset.put_change(:logo_extension, nil)
    |> Repo.update()
  end

  def remove_winner_image(challenge) do
    challenge
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_change(:winner_image_key, nil)
    |> Ecto.Changeset.put_change(:winner_image_extension, nil)
    |> Repo.update()
  end

  @impl true
  def filter_on_attribute({"search", value}, query) do
    value = "%" <> value <> "%"
    where(query, [c], ilike(c.title, ^value) or ilike(c.description, ^value))
  end

  def filter_on_attribute({"type", value}, query) do
    where(query, [c], c.type in ^value)
  end

  def filter_on_attribute({"agency_id", value}, query) do
    where(query, [c], c.agency_id == ^value)
  end

  def filter_on_attribute({"user_id", value}, query) do
    where(query, [c], c.user_id == ^value)
  end

  def filter_on_attribute(_, query), do: query
end

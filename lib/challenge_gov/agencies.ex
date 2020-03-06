defmodule ChallengeGov.Agencies do
  @moduledoc """
  Agencies context
  """

  alias ChallengeGov.Repo
  alias ChallengeGov.Agencies.Avatar
  alias ChallengeGov.Agencies.Member
  alias ChallengeGov.Agencies.Agency
  alias Stein.Filter
  alias Stein.Pagination

  import Ecto.Query

  @behaviour Stein.Filter

  @doc """
  New agency changeset
  """
  def new(), do: Agency.create_changeset(%Agency{}, %{})

  @doc """
  Edit agency changeset
  """
  def edit(agency), do: Agency.create_changeset(agency, %{})

  @doc """
  Get all accounts
  """
  def all(opts \\ []) do
    opts = Enum.into(opts, %{})

    query =
      Agency
      |> where([t], is_nil(t.deleted_at))
      |> Filter.filter(opts[:filter], __MODULE__)
      |> preload(members: ^member_query())

    Pagination.paginate(Repo, query, opts)
  end

  def all_for_select() do
    Agency
    |> where([a], is_nil(a.deleted_at))
    |> order_by(:name)
    |> Repo.all()
  end

  @doc """
  Get an individual agency
  """
  def get(id) do
    agency =
      Agency
      |> where([t], t.id == ^id and is_nil(t.deleted_at))
      |> preload([:federal_partner_challenges, :challenges, members: ^member_query()])
      |> Repo.one()

    case agency do
      nil ->
        {:error, :not_found}

      agency ->
        agency = Repo.preload(agency, members: :user)
        {:ok, agency}
    end
  end

  def get_by_name(name) do
    case Repo.get_by(Agency, name: name) do
      nil ->
        {:error, :not_found}

      agency ->
        {:ok, agency}
    end
  end

  defp member_query() do
    from m in Member,
      join: u in assoc(m, :user),
      where: u.display == true,
      preload: [user: [:challenges]]
  end

  @doc """
  Check if a user is the member of any agency
  """
  def member_of_agency?(user) do
    user = Repo.preload(user, members: from(m in Member, where: m.status == "accepted"))

    !Enum.empty?(user.members)
  end

  @doc """
  Create a new agency

  Adds the user to the agency, fails if the user is already part of a agency
  """
  # def create(%{email_verified_at: nil}, _params) do
  #   %Agency{}
  #   |> Ecto.Changeset.change()
  #   |> Ecto.Changeset.add_error(:base, "You must verify your email first")
  #   |> Ecto.Changeset.apply_action(:insert)
  # end

  # TODO: Change this to use user again if needed
  def create(_user, params) do
    result =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:agency, Agency.create_changeset(%Agency{}, params))
      |> Ecto.Multi.run(:avatar, fn _repo, %{agency: agency} ->
        Avatar.maybe_upload_avatar(agency, params)
      end)
      |> Repo.transaction()

    case result do
      {:ok, %{avatar: agency}} ->
        {:ok, agency}

      {:error, :agency, changeset, _changes} ->
        {:error, changeset}

      {:error, :member, _changeset, _changes} ->
        %Agency{}
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.add_error(:base, "You are already a member of a agency")
        |> Ecto.Changeset.apply_action(:insert)
    end
  end

  def create(params) do
    %Agency{}
    |> Agency.create_changeset(params)
    |> IO.inspect
    |> Repo.insert()
    |> IO.inspect
  end

  @doc """
  Update a agency
  """
  def update(agency, params) do
    result =
      Ecto.Multi.new()
      |> Ecto.Multi.update(:agency, Agency.update_changeset(agency, params))
      |> Ecto.Multi.run(:avatar, fn _repo, %{agency: agency} ->
        Avatar.maybe_upload_avatar(agency, params)
      end)
      |> Repo.transaction()

    case result do
      {:ok, %{avatar: agency}} ->
        {:ok, agency}

      {:error, _type, changeset, _changes} ->
        {:error, changeset}
    end
  end

  @doc """
  Soft delete a agency

  Marks as deleted by setting the timestamp
  """
  def delete(agency) do
    now = DateTime.truncate(Timex.now(), :second)

    changeset =
      agency
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_change(:deleted_at, now)

    result =
      Ecto.Multi.new()
      |> Ecto.Multi.update(:agency, changeset)
      |> Ecto.Multi.run(:archive_members, &archive_members/2)
      |> Repo.transaction()

    case result do
      {:ok, %{agency: agency}} ->
        {:ok, agency}

      {:error, _type, changeset, _changes} ->
        {:error, changeset}
    end
  end

  defp archive_members(repo, %{agency: agency}) do
    result =
      Member
      |> where([m], m.agency_id == ^agency.id)
      |> repo.update_all(set: [status: "archived"])

    {:ok, result}
  end

  @doc """
  Check if a user is a full member of the agency
  """
  def member?(agency, user) do
    !is_nil(Repo.get_by(Member, agency_id: agency.id, user_id: user.id, status: "accepted"))
  end

  def remove_logo(agency) do
    agency
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_change(:avatar_key, nil)
    |> Ecto.Changeset.put_change(:avatar_extension, nil)
    |> Repo.update()
  end

  @impl true
  def filter_on_attribute({"search", value}, query) do
    value = "%" <> value <> "%"
    where(query, [c], ilike(c.name, ^value) or ilike(c.description, ^value))
  end
end

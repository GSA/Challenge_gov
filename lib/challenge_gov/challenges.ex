defmodule ChallengeGov.Challenges do
  @moduledoc """
  Context for Challenges
  """

  @behaviour Stein.Filter

  import Ecto.Query

  alias ChallengeGov.Accounts
  alias ChallengeGov.Challenges.Challenge
  alias ChallengeGov.Challenges.ChallengeManager
  alias ChallengeGov.Challenges.FederalPartner
  alias ChallengeGov.Challenges.Logo
  alias ChallengeGov.Challenges.Phase
  alias ChallengeGov.Challenges.WinnerImage
  alias ChallengeGov.Challenges.ResourceBanner
  alias ChallengeGov.Emails
  alias ChallengeGov.Mailer
  alias ChallengeGov.Phases
  alias ChallengeGov.Repo
  alias ChallengeGov.SavedChallenges
  alias ChallengeGov.Security
  alias ChallengeGov.SecurityLogs
  alias ChallengeGov.SupportingDocuments
  alias ChallengeGov.Timeline.Event
  alias Stein.Filter

  # BOOKMARK: Functions for fetching valid attribute values
  @doc false
  def challenge_types(), do: Challenge.challenge_types()

  @doc false
  def legal_authority(), do: Challenge.legal_authority()

  @doc false
  def statuses(), do: Challenge.statuses()

  @doc false
  def sub_statuses(), do: Challenge.sub_statuses()

  @doc false
  def status_label(status) do
    status_data = Enum.find(statuses(), fn s -> s.id == status end)

    if status_data do
      status_data.label
    else
      status
    end
  end

  # BOOKMARK: Wizard functionality helpers
  @doc false
  def sections(), do: Challenge.sections()

  @doc false
  def section_index(section), do: Challenge.section_index(section)

  @doc false
  def next_section(section), do: Challenge.next_section(section)

  @doc false
  def prev_section(section), do: Challenge.prev_section(section)

  @doc false
  def to_section(section, action), do: Challenge.to_section(section, action)

  # BOOKMARK: Create and update functions
  @doc """
  New changeset for a challenge
  """
  def new(user) do
    %Challenge{}
    |> challenge_form_preload()
    |> Challenge.create_changeset(%{}, user)
  end

  @doc """
  Import challenges: no user, manager, documents or security logging
  """
  def import_create(challenge_params) do
    challenge_params =
      challenge_params
      |> check_non_federal_partners

    result =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(
        :challenge,
        Challenge.import_changeset(%Challenge{}, challenge_params)
      )
      |> attach_federal_partners(challenge_params)
      |> Ecto.Multi.run(:logo, fn _repo, %{challenge: challenge} ->
        Logo.maybe_upload_logo(challenge, challenge_params)
      end)
      |> Repo.transaction()

    case result do
      {:ok, %{challenge: challenge}} ->
        {:ok, challenge}

      {:error, :challenge, changeset, _} ->
        {:error, changeset}
    end
  end

  def create(%{"action" => action, "challenge" => challenge_params}, user, remote_ip \\ nil) do
    challenge_params =
      challenge_params
      |> check_non_federal_partners

    result =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(
        :challenge,
        changeset_for_action(%Challenge{}, challenge_params, action)
      )
      |> attach_initial_manager(user)
      |> attach_federal_partners(challenge_params)
      |> attach_challenge_managers(challenge_params)
      |> attach_documents(challenge_params)
      |> Ecto.Multi.run(:logo, fn _repo, %{challenge: challenge} ->
        Logo.maybe_upload_logo(challenge, challenge_params)
      end)
      |> add_to_security_log_multi(user, "create", remote_ip)
      |> Repo.transaction()

    case result do
      {:ok, %{challenge: challenge}} ->
        {:ok, challenge}

      {:error, :challenge, changeset, _} ->
        {:error, changeset}
    end
  end

  @doc """
  Changeset for editing a challenge (as an admin)
  """
  def edit(challenge) do
    challenge
    |> challenge_form_preload()
    |> Challenge.update_changeset(%{})
  end

  def update(challenge, params, user, remote_ip \\ nil)

  def update(challenge, %{"action" => action, "challenge" => challenge_params}, user, remote_ip) do
    section = Map.get(challenge_params, "section")

    challenge_params =
      challenge_params
      |> check_non_federal_partners

    result =
      Ecto.Multi.new()
      |> Ecto.Multi.update(:challenge, changeset_for_action(challenge, challenge_params, action))
      |> attach_federal_partners(challenge_params)
      |> attach_challenge_managers(challenge_params)
      |> attach_documents(challenge_params)
      |> Ecto.Multi.run(:logo, fn _repo, %{challenge: challenge} ->
        Logo.maybe_upload_logo(challenge, challenge_params)
      end)
      |> Ecto.Multi.run(:resource_banner, fn _repo, %{challenge: challenge} ->
        ResourceBanner.maybe_upload_resource_banner(challenge, challenge_params)
      end)
      |> add_to_security_log_multi(user, "update", remote_ip, %{action: action, section: section})
      |> Repo.transaction()

    case result do
      {:ok, %{challenge: challenge}} ->
        maybe_send_submission_confirmation(challenge, action)
        {:ok, challenge}

      {:error, _type, changeset, _changes} ->
        {:error, changeset}
    end
  end

  @doc """
  Update a challenge
  """
  def update(challenge, params, current_user, remote_ip) do
    challenge = challenge_form_preload(challenge)

    params =
      params
      |> Map.put_new("challenge_managers", [])
      |> Map.put_new("federal_partners", [])
      |> Map.put_new("non_federal_partners", [])
      |> Map.put_new("events", [])

    changeset =
      if Accounts.has_admin_access?(current_user) do
        Challenge.admin_update_changeset(challenge, params)
      else
        Challenge.update_changeset(challenge, params)
      end

    result =
      Ecto.Multi.new()
      |> Ecto.Multi.update(:challenge, changeset)
      |> attach_federal_partners(params)
      |> attach_challenge_managers(params)
      |> Ecto.Multi.run(:event, fn _repo, %{challenge: challenge} ->
        maybe_create_event(challenge, changeset)
      end)
      |> Ecto.Multi.run(:logo, fn _repo, %{challenge: challenge} ->
        Logo.maybe_upload_logo(challenge, params)
      end)
      |> Ecto.Multi.run(:winner_image, fn _repo, %{challenge: challenge} ->
        WinnerImage.maybe_upload_winner_image(challenge, params)
      end)
      |> add_to_security_log_multi(current_user, "update", remote_ip)
      |> Repo.transaction()

    case result do
      {:ok, %{challenge: challenge}} ->
        {:ok, challenge}

      {:error, _type, changeset, _changes} ->
        {:error, changeset}
    end
  end

  # BOOKMARK: Create and update helper functions
  defp changeset_for_action(struct, params, action) do
    struct = challenge_form_preload(struct)

    case action do
      a when a == "save_draft" ->
        Challenge.draft_changeset(struct, params, action)

      a when a == "back" ->
        if struct.status === "draft",
          do: Challenge.draft_changeset(struct, params, action),
          else: Challenge.section_changeset(struct, params, action)

      _ ->
        Challenge.section_changeset(struct, params, action)
    end
  end

  defp challenge_form_preload(challenge) do
    Repo.preload(challenge, [
      :non_federal_partners,
      :phases,
      :events,
      :user,
      :challenge_manager_users,
      :supporting_documents,
      :sub_agency,
      federal_partners: [:agency, :sub_agency],
      federal_partner_agencies: [:sub_agencies],
      agency: [:sub_agencies]
    ])
  end

  defp base_preload(challenge) do
    preload(challenge, [
      :non_federal_partners,
      :events,
      :user,
      :challenge_manager_users,
      :supporting_documents,
      :sub_agency,
      federal_partners: [:agency, :sub_agency],
      federal_partner_agencies: [:sub_agencies],
      phases: [winners: [:winners]],
      agency: [:sub_agencies]
    ])
  end

  defp check_non_federal_partners(params) do
    if Map.get(params, "non_federal_partners") == "" do
      Map.put(params, "non_federal_partners", [])
    else
      params
    end
  end

  def all_unpaginated(opts \\ []) do
    base_query()
    |> order_by([c], asc: c.end_date, asc: c.id)
    |> Filter.filter(opts[:filter], __MODULE__)
    |> Repo.all()
  end

  # BOOKMARK: Querying functions
  @doc """
  Get all challenges
  """
  def all(opts \\ []) do
    base_query()
    |> where([c], c.status == "published")
    |> order_by([c], asc: c.end_date, asc: c.id)
    |> Filter.filter(opts[:filter], __MODULE__)
    |> Repo.paginate(opts[:page], opts[:per])
  end

  def all_public(opts \\ []) do
    base_query()
    |> where(
      [c],
      (c.status == "published" and c.sub_status == "open") or
        (c.status == "published" and is_nil(c.sub_status))
    )
    |> where([c], c.end_date >= ^DateTime.utc_now())
    |> order_by([c], asc: c.end_date, asc: c.id)
    |> Filter.filter(opts[:filter], __MODULE__)
    |> Repo.paginate(opts[:page], opts[:per])
  end

  @doc """
  Gets all archived or sub_status archived challenges
  """
  def all_archived(opts \\ []) do
    base_query()
    |> where(
      [c],
      (c.status == "published" and
         (c.sub_status == "archived" or c.sub_status == "closed" or
            (c.archive_date <= ^DateTime.utc_now() or c.end_date <= ^DateTime.utc_now()))) or
        c.status == "archived"
    )
    |> order_by([c], asc: c.end_date, asc: c.id)
    |> Filter.filter(opts[:filter], __MODULE__)
    |> Repo.paginate(opts[:page], opts[:per])
  end

  @doc """
  Get all public challenges non paginated for sitemap
  """
  def all_for_sitemap() do
    base_query()
    |> where([c], c.status == "published" or c.status == "archived")
    |> order_by([c], asc: c.end_date, asc: c.id)
    |> Repo.all()
  end

  @doc """
  Get all published challenges for govdelivery topics
  """
  def all_for_govdelivery() do
    base_query()
    |> where([c], c.status == "published" and c.sub_status != "archived")
    |> where([c], is_nil(c.gov_delivery_topic))
    |> where(
      [c],
      c.archive_date > ^DateTime.utc_now()
    )
    |> Repo.all()
  end

  @doc """
  Get all archived challenges for removal from govdelivery topics
  """
  def all_for_removal_from_govdelivery() do
    base_query()
    |> where(
      [c],
      c.status == "archived" or (c.status == "published" and c.sub_status == "archived")
    )
    |> where(
      [c],
      c.archive_date < ^DateTime.utc_now()
    )
    |> where([c], not is_nil(c.gov_delivery_topic))
    |> Repo.all()
  end

  @doc """
  Get all challenges with govdelivery topics
  """
  def all_in_govdelivery() do
    base_query()
    |> where([c], not is_nil(c.gov_delivery_topic))
    |> Repo.all()
  end

  def all_ready_for_publish() do
    base_query()
    |> where([c], c.status == "approved")
    |> where([c], fragment("? <= ?", c.auto_publish_date, ^DateTime.utc_now()))
    |> Repo.all()
  end

  @doc """
  Get all challenges
  """
  def admin_all(opts \\ []) do
    base_query()
    |> order_by([c], desc: c.status, desc: c.id)
    |> Filter.filter(opts[:filter], __MODULE__)
    |> Repo.paginate(opts[:page], opts[:per])
  end

  @doc """
  Get all challenges for a user
  """
  def all_pending_for_user(user, opts \\ []) do
    user
    |> base_all_for_user_query()
    |> where([c], c.status == "gsa_review")
    |> order_on_attribute(opts[:sort])
    |> Filter.filter(opts[:filter], __MODULE__)
    |> Repo.paginate(opts[:page], opts[:per])
  end

  @doc """
  Get all challenges for a user
  """
  def all_for_user(user, opts \\ []) do
    user
    |> base_all_for_user_query()
    |> order_on_attribute(opts[:sort])
    |> Filter.filter(opts[:filter], __MODULE__)
    |> Repo.all()
  end

  def all_for_user_paginated(user, opts \\ []) do
    user
    |> base_all_for_user_query()
    |> order_on_attribute(opts[:sort])
    |> Filter.filter(opts[:filter], __MODULE__)
    |> Repo.paginate(opts[:page], opts[:per])
  end

  defp base_query() do
    Challenge
    |> where([c], is_nil(c.deleted_at))
    |> base_preload
  end

  defp base_all_for_user_query(%{id: id, role: "challenge_manager"}) do
    base_query()
    |> join(:inner, [c], co in assoc(c, :challenge_managers))
    |> where([c, co], co.user_id == ^id and is_nil(co.revoked_at))
  end

  defp base_all_for_user_query(_), do: base_query()

  @doc """
  Get a challenge
  """
  def get(id_or_slug) do
    with false <- is_integer(id_or_slug),
         {id, ""} <- Integer.parse(id_or_slug) do
      Challenge
      |> where([c], c.id == ^id)
      |> get_query()
    else
      {_number, _remainder} ->
        Challenge
        |> where([c], c.custom_url == ^id_or_slug)
        |> get_query()

      true ->
        Challenge
        |> where([c], c.id == ^id_or_slug)
        |> get_query()

      :error ->
        Challenge
        |> where([c], c.custom_url == ^id_or_slug)
        |> get_query()
    end
    |> case do
      nil ->
        {:error, :not_found}

      challenge ->
        challenge =
          challenge
          |> Repo.preload(events: from(e in Event, order_by: e.occurs_on))
          |> Map.put(
            :timeline_events,
            challenge.timeline_events
            |> remove_nil_dates()
            |> Enum.sort(&(DateTime.compare(&1.date, &2.date) != :gt))
          )

        {:ok, challenge}
    end
  end

  def remove_nil_dates(events) when is_list(events),
    do: Enum.reject(events, fn e -> is_nil(e.date) end)

  @doc """
  Get a challenge by uuid
  """
  def get_by_uuid(uuid) do
    Challenge
    |> where([c], c.uuid == ^uuid)
    |> get_query()
    |> case do
      nil ->
        {:error, :not_found}

      challenge ->
        challenge =
          challenge
          |> Repo.preload(events: from(e in Event, order_by: e.date))
          |> Map.put(
            :timeline_events,
            challenge.timeline_events
            |> Enum.sort(&(DateTime.compare(&1.date, &2.date) != :gt))
          )

        {:ok, challenge}
    end
  end

  defp get_query(struct) do
    struct
    |> where([c], is_nil(c.deleted_at))
    |> preload([
      :supporting_documents,
      :user,
      :federal_partner_agencies,
      :non_federal_partners,
      :agency,
      :sub_agency,
      :challenge_managers,
      :challenge_manager_users,
      :events,
      :submissions,
      phases: ^{from(p in Phase, order_by: p.start_date), [winners: :winners]},
      federal_partners: [:agency, :sub_agency]
    ])
    |> Repo.one()
  end

  def get_closed_phases(%{phases: phases}) do
    Enum.filter(phases, fn phase ->
      Phases.is_past?(phase)
    end)
  end

  @doc """
  Submit a new challenge for a user
  """
  def old_create(user, params, remote_ip) do
    result =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:challenge, create_challenge(user, params))
      |> attach_initial_manager(user)
      |> attach_federal_partners(params)
      |> attach_challenge_managers(params)
      |> attach_documents(params)
      |> Ecto.Multi.run(:logo, fn _repo, %{challenge: challenge} ->
        Logo.maybe_upload_logo(challenge, params)
      end)
      |> Ecto.Multi.run(:winner_image, fn _repo, %{challenge: challenge} ->
        WinnerImage.maybe_upload_winner_image(challenge, params)
      end)
      |> add_to_security_log_multi(user, "create", remote_ip)
      |> Repo.transaction()

    case result do
      {:ok, %{challenge: challenge}} ->
        send_pending_challenge_email(challenge)
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

  defp create_challenge(user, params) do
    user
    |> Ecto.build_assoc(:challenges)
    |> Map.put(:challenge_manager_users, [])
    |> Map.put(:federal_partners, [])
    |> Map.put(:federal_partner_agencies, [])
    |> Challenge.create_changeset(params, user)
  end

  # Attach federal partners functions
  defp attach_federal_partners(multi, %{"federal_partners" => ""}) do
    attach_federal_partners(multi, %{"federal_partners" => []})
  end

  defp attach_federal_partners(multi, %{"federal_partners" => federal_partners}) do
    multi =
      Ecto.Multi.run(multi, :delete_agencies, fn _repo, changes ->
        {:ok,
         Repo.delete_all(
           from(fp in FederalPartner, where: fp.challenge_id == ^changes.challenge.id)
         )}
      end)

    Enum.reduce(federal_partners, multi, fn {id, federal_partner}, multi ->
      %{"agency_id" => agency_id, "sub_agency_id" => sub_agency_id} = federal_partner

      Ecto.Multi.run(multi, {:id, id, :agency, agency_id, :sub_agency, sub_agency_id}, fn _repo,
                                                                                          changes ->
        maybe_create_federal_partner(agency_id, sub_agency_id, changes)
      end)
    end)
  end

  defp attach_federal_partners(multi, _params), do: multi

  defp maybe_create_federal_partner(agency_id, sub_agency_id, changes)
       when not is_nil(agency_id) and agency_id !== "" do
    %FederalPartner{}
    |> FederalPartner.changeset(%{
      agency_id: agency_id,
      sub_agency_id: sub_agency_id,
      challenge_id: changes.challenge.id
    })
    |> Repo.insert()
  end

  defp maybe_create_federal_partner(_agency_id, _sub_agency_id, _changes), do: {:ok, nil}

  # Attach challenge managers functions
  defp attach_initial_manager(multi, user) do
    Ecto.Multi.run(multi, {:user, user.id}, fn _repo, changes ->
      %ChallengeManager{}
      |> ChallengeManager.changeset(%{
        user_id: user.id,
        challenge_id: changes.challenge.id
      })
      |> Repo.insert()
    end)
  end

  # Attach challenge managers functions
  defp attach_challenge_managers(multi, %{challenge_managers: ids}) do
    attach_challenge_managers(multi, %{"challenge_managers" => ids})
  end

  defp attach_challenge_managers(multi, %{"challenge_managers" => ids}) do
    multi =
      Ecto.Multi.run(multi, :delete_managers, fn _repo, changes ->
        {:ok,
         Repo.delete_all(
           from(co in ChallengeManager, where: co.challenge_id == ^changes.challenge.id)
         )}
      end)

    Enum.reduce(ids, multi, fn user_id, multi ->
      Ecto.Multi.run(multi, {:user, user_id}, fn _repo, changes ->
        %ChallengeManager{}
        |> ChallengeManager.changeset(%{
          user_id: user_id,
          challenge_id: changes.challenge.id
        })
        |> Repo.insert()
      end)
    end)
  end

  defp attach_challenge_managers(multi, _params), do: multi

  # Attach supporting document functions
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
    SupportingDocuments.attach_to_challenge(document, challenge, "resources", "")
  end

  defp attach_document(result, _challenge), do: result

  @doc """
  Delete a challenge
  """
  def delete(challenge) do
    Repo.delete(challenge)
  end

  @doc """
  Delete a challenge if allowed
  """
  def delete(challenge, user, remote_ip) do
    if allowed_to_delete(user, challenge) do
      soft_delete(challenge, user, remote_ip)
    else
      {:error, :not_permitted}
    end
  end

  def soft_delete(challenge, user, remote_ip) do
    now = DateTime.truncate(Timex.now(), :second)

    challenge
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_change(:deleted_at, now)
    |> Repo.update()
    |> case do
      {:ok, challenge} ->
        add_to_security_log(user, challenge, "delete", remote_ip)
        {:ok, challenge}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Checks if a user is allowed to delete a challenge
  """
  def allowed_to_delete(user, challenge) do
    Accounts.has_admin_access?(user) or challenge.status == "draft"
  end

  @doc """
  Checks if a user is allowed to edit a challenge
  """
  def allowed_to_edit(user, challenge) do
    if is_challenge_manager?(user, challenge) or
         Accounts.has_admin_access?(user) do
      {:ok, challenge}
    else
      {:error, :not_permitted}
    end
  end

  def allowed_to_edit?(user, challenge) do
    case allowed_to_edit(user, challenge) do
      {:ok, _challenge} -> true
      {:error, :not_permitted} -> false
    end
  end

  def allowed_to_submit?(%{role: "super_admin"}), do: true

  def allowed_to_submit?(%{role: "admin"}), do: true

  def allowed_to_submit?(user = %{role: "challenge_manager"}) do
    Security.default_challenge_manager?(user.email)
  end

  def allowed_to_submit?(_user), do: false

  @doc """
  Checks if a user can send a bulletin
  """
  def can_send_bulletin(user, challenge) do
    if (is_challenge_manager?(user, challenge) or
          Accounts.has_admin_access?(user)) and
         challenge.gov_delivery_topic != nil and
         challenge.gov_delivery_topic != "" do
      {:ok, challenge}
    else
      {:error, :not_permitted}
    end
  end

  @doc """
  Checks if a user is in the list of managers for a challenge and not revoked
  """
  def is_challenge_manager?(_user, nil), do: true

  def is_challenge_manager?(user, challenge) do
    challenge.challenge_managers
    |> Enum.reject(fn co ->
      !is_nil(co.revoked_at)
    end)
    |> Enum.map(fn co ->
      co.user_id
    end)
    |> Enum.member?(user.id)
  end

  @doc """
  Checks if a user has a submission for the challenge
  """
  def is_solver?(user, challenge) do
    challenge = Repo.preload(challenge, [:submissions])

    challenge.submissions
    |> Enum.map(fn submission ->
      submission.submitter_id
    end)
    |> Enum.member?(user.id)
  end

  @doc """
  Restores access to a user's challlenges
  """
  def restore_access(user, challenge) do
    ChallengeManager
    |> where([co], co.user_id == ^user.id and co.challenge_id == ^challenge.id)
    |> Repo.update_all(set: [revoked_at: nil])
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

  # BOOKMARK: Helper functions
  def find_start_date(challenge) do
    challenge.start_date
  end

  def find_end_date(challenge) do
    challenge.end_date
  end

  # BOOKMARK: Phase helper functions
  @doc """
  Returns currently active phase
  """
  def current_phase(%{phases: phases}) when length(phases) > 0 do
    phases
    |> Enum.find(fn phase ->
      Phases.is_current?(phase)
    end)
    |> case do
      nil ->
        {:error, :no_current_phase}

      phase ->
        {:ok, phase}
    end
  end

  def current_phase(_challenge), do: {:error, :no_current_phase}

  @doc """
  Returns phase of a challenge after the phase passed in
  """
  def next_phase(%{phases: phases}, current_phase) do
    phase_index =
      Enum.find_index(phases, fn phase ->
        phase.id == current_phase.id
      end)

    case Enum.at(phases, phase_index + 1) do
      nil ->
        {:error, :not_found}

      phase ->
        {:ok, phase}
    end
  end

  @doc """
  Returns if a challenge has closed phases or not
  """
  def has_closed_phases?(%{phases: phases}) do
    Enum.any?(phases, fn phase ->
      Phases.is_past?(phase)
    end)
  end

  def is_multi_phase?(challenge) do
    length(challenge.phases) > 1
  end

  @doc """
  Create a new status event when the status changes
  """
  def create_status_event(_), do: :ok

  # BOOKMARK: Base status functions
  def is_draft?(%{status: "draft"}), do: true
  def is_draft?(_user), do: false

  def in_review?(%{status: "gsa_review"}), do: true
  def in_review?(_user), do: false

  def is_approved?(%{status: "approved"}), do: true
  def is_approved?(_user), do: false

  def has_edits_requested?(%{status: "edits_requested"}), do: true
  def has_edits_requested?(_user), do: false

  def is_published?(%{status: "published"}), do: true
  def is_published?(_user), do: false

  def is_unpublished?(%{status: "unpublished"}), do: true
  def is_unpublished?(_user), do: false

  def is_open?(%{sub_status: "open"}), do: true

  def is_open?(challenge = %{start_date: start_date, end_date: end_date})
      when not is_nil(start_date) and not is_nil(end_date) do
    now = DateTime.utc_now()

    is_published?(challenge) and DateTime.compare(now, start_date) === :gt and
      DateTime.compare(now, end_date) === :lt
  end

  def is_open?(_challenge), do: false

  def is_closed?(%{sub_status: "closed"}), do: true

  def is_closed?(challenge = %{end_date: end_date}) when not is_nil(end_date) do
    now = DateTime.utc_now()
    is_published?(challenge) and DateTime.compare(now, end_date) === :gt
  end

  def is_closed?(_challenge), do: false

  def is_archived_new?(%{status: "archived"}), do: true

  def is_archived_new?(%{status: "published", sub_status: "archived"}), do: true

  def is_archived_new?(challenge = %{archive_date: archive_date}) when not is_nil(archive_date) do
    now = DateTime.utc_now()
    is_published?(challenge) and DateTime.compare(now, archive_date) === :gt
  end

  def is_archived_new?(challenge = %{phases: phases}) when length(phases) > 0 do
    now = DateTime.utc_now()

    phases_end_date =
      Enum.max_by(phases, fn p ->
        d = p.end_date

        if d do
          {d.year, d.month, d.day, d.hour, d.minute, d.second, d.microsecond}
        end
      end).end_date

    is_published?(challenge) and DateTime.compare(now, phases_end_date) === :gt
  end

  def is_archived_new?(_challenge), do: false

  def is_archived?(%{status: "archived"}), do: true
  def is_archived?(_user), do: false

  def set_sub_statuses() do
    Challenge
    |> where([c], c.status == "published")
    |> Repo.all()
    |> Enum.reduce(Ecto.Multi.new(), fn challenge, multi ->
      Ecto.Multi.update(multi, {:challenge, challenge.id}, set_sub_status(challenge))
    end)
    |> Repo.transaction()
  end

  def set_sub_status(challenge) do
    cond do
      is_archived_new?(challenge) ->
        challenge
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.put_change(:sub_status, "archived")

      is_closed?(challenge) ->
        challenge
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.put_change(:sub_status, "closed")

      is_open?(challenge) ->
        challenge
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.put_change(:sub_status, "open")

      true ->
        challenge
        |> Ecto.Changeset.change()
    end
  end

  def set_statuses(current_user, challenge, status, sub_status, remote_ip) do
    challenge
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_change(:status, status)
    |> Ecto.Changeset.put_change(:sub_status, sub_status)
    |> Repo.update()
    |> case do
      {:ok, challenge} ->
        add_to_security_log(current_user, challenge, "status_change", remote_ip, %{
          status: status,
          sub_status: sub_status
        })

        {:ok, challenge}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def set_status(current_user, challenge, status, remote_ip) do
    challenge
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_change(:status, status)
    |> Repo.update()
    |> case do
      {:ok, challenge} ->
        add_to_security_log(current_user, challenge, "status_change", remote_ip, %{
          status: status
        })

        {:ok, challenge}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  # BOOKMARK: Advanced status functions
  @doc """
  Checks if the challenge should be publicly accessible. Either published or archived
  """
  def is_public?(challenge) do
    is_published?(challenge) or is_archived?(challenge)
  end

  def is_submittable?(challenge) do
    !in_review?(challenge) and (is_draft?(challenge) or has_edits_requested?(challenge))
  end

  def is_submittable?(challenge, user) do
    (Accounts.has_admin_access?(user) or is_challenge_manager?(user, challenge)) and
      is_submittable?(challenge)
  end

  def is_approvable?(challenge) do
    in_review?(challenge) or is_unpublished?(challenge)
  end

  def is_approvable?(challenge, user) do
    Accounts.has_admin_access?(user) and is_approvable?(challenge)
  end

  def can_request_edits?(challenge) do
    in_review?(challenge) or has_edits_requested?(challenge) or is_open?(challenge) or
      is_approved?(challenge)
  end

  def can_request_edits?(challenge, user) do
    Accounts.has_admin_access?(user) and can_request_edits?(challenge)
  end

  def is_archivable?(challenge) do
    is_published?(challenge) or is_unpublished?(challenge)
  end

  def is_archivable?(challenge, user) do
    Accounts.has_admin_access?(user) and is_archivable?(challenge)
  end

  def is_unarchivable?(challenge) do
    is_archived?(challenge)
  end

  def is_unarchivable?(challenge, user) do
    Accounts.has_admin_access?(user) and is_unarchivable?(challenge)
  end

  def is_publishable?(challenge) do
    is_approved?(challenge)
  end

  def is_publishable?(challenge, user) do
    Accounts.has_admin_access?(user) and is_publishable?(challenge)
  end

  def is_unpublishable?(challenge) do
    (is_approved?(challenge) or is_published?(challenge) or is_archived?(challenge)) and
      !(is_closed?(challenge) or is_archived_new?(challenge))
  end

  def is_unpublishable?(challenge, user) do
    Accounts.has_admin_access?(user) and is_unpublishable?(challenge)
  end

  def edit_with_wizard?(challenge) do
    challenge.status != "gsa_review"
  end

  def is_editable?(_challenge) do
    true
  end

  def is_editable?(challenge, user) do
    (is_challenge_manager?(user, challenge) or Accounts.has_admin_access?(user)) and
      edit_with_wizard?(challenge)
  end

  # BOOKMARK: Status altering functions
  def submit(challenge, user, remote_ip) do
    changeset =
      challenge
      |> Challenge.section_changeset(%{"section" => "review"}, "submit")

    result =
      Ecto.Multi.new()
      |> Ecto.Multi.update(:challenge, changeset)
      |> add_to_security_log_multi(user, "status_change", remote_ip, %{status: "gsa_review"})
      |> Repo.transaction()

    case result do
      {:ok, %{challenge: challenge}} ->
        send_pending_challenge_email(challenge)
        {:ok, challenge}

      {:error, :challenge, changeset, _changes} ->
        {:error, changeset}
    end
  end

  def approve(challenge, user, remote_ip) do
    changeset = Challenge.approve_changeset(challenge)

    result =
      Ecto.Multi.new()
      |> Ecto.Multi.update(:challenge, changeset)
      |> add_to_security_log_multi(user, "status_change", remote_ip, %{status: "approved"})
      |> Repo.transaction()

    case result do
      {:ok, %{challenge: challenge}} ->
        {:ok, challenge}

      {:error, _type, changeset, _changes} ->
        {:error, changeset}
    end
  end

  def reject(challenge, user, remote_ip, message \\ "") do
    changeset = Challenge.reject_changeset(challenge, message)

    result =
      Ecto.Multi.new()
      |> Ecto.Multi.update(:challenge, changeset)
      |> add_to_security_log_multi(user, "status_change", remote_ip, %{
        status: "edits_requested",
        message: message
      })
      |> Repo.transaction()

    case result do
      {:ok, %{challenge: challenge}} ->
        send_challenge_rejection_emails(challenge)
        {:ok, challenge}

      {:error, _type, changeset, _changes} ->
        {:error, changeset}
    end
  end

  def publish(challenge, user, remote_ip) do
    changeset = Challenge.publish_changeset(challenge)

    result =
      Ecto.Multi.new()
      |> Ecto.Multi.update(:challenge, changeset)
      |> add_to_security_log_multi(user, "status_change", remote_ip, %{status: "published"})
      |> Repo.transaction()

    case result do
      {:ok, %{challenge: challenge}} ->
        {:ok, challenge}

      {:error, _type, changeset, _changes} ->
        {:error, changeset}
    end
  end

  def unpublish(challenge, user, remote_ip) do
    changeset = Challenge.unpublish_changeset(challenge)

    result =
      Ecto.Multi.new()
      |> Ecto.Multi.update(:challenge, changeset)
      |> add_to_security_log_multi(user, "status_change", remote_ip, %{status: "unpublished"})
      |> Repo.transaction()

    case result do
      {:ok, %{challenge: challenge}} ->
        {:ok, challenge}

      {:error, _type, changeset, _changes} ->
        {:error, changeset}
    end
  end

  def archive(challenge, user, remote_ip) do
    changeset =
      challenge
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_change(:status, "archived")

    result =
      Ecto.Multi.new()
      |> Ecto.Multi.update(:challenge, changeset)
      |> add_to_security_log_multi(user, "status_change", remote_ip, %{status: "archived"})
      |> Repo.transaction()

    case result do
      {:ok, %{challenge: challenge}} ->
        {:ok, challenge}

      {:error, _type, changeset, _changes} ->
        {:error, changeset}
    end
  end

  def unarchive(challenge, user, remote_ip) do
    changeset =
      challenge
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_change(:status, "published")

    result =
      Ecto.Multi.new()
      |> Ecto.Multi.update(:challenge, changeset)
      |> add_to_security_log_multi(user, "status_change", remote_ip, %{status: "published"})
      |> Repo.transaction()

    case result do
      {:ok, %{challenge: challenge}} ->
        {:ok, challenge}

      {:error, _type, changeset, _changes} ->
        {:error, changeset}
    end
  end

  def create_announcement(challenge, announcement) do
    challenge
    |> Challenge.create_announcement_changeset(announcement)
    |> Repo.update()
  end

  def remove_announcement(challenge) do
    challenge
    |> Challenge.remove_announcement_changeset()
    |> Repo.update()
  end

  # BOOKMARK: Email functions
  defp send_pending_challenge_email(challenge) do
    challenge
    |> Emails.pending_challenge_email()
    |> Mailer.deliver_later()
  end

  defp send_challenge_rejection_emails(challenge) do
    Enum.map(challenge.challenge_manager_users, fn manager ->
      manager
      |> Emails.challenge_rejection_email(challenge)
      |> Mailer.deliver_later()
    end)
  end

  defp maybe_send_submission_confirmation(challenge, action) when action === "submit" do
    Enum.map(challenge.challenge_manager_users, fn manager ->
      manager
      |> Emails.challenge_submission(challenge)
      |> Mailer.deliver_later()
    end)
  end

  defp maybe_send_submission_confirmation(_challenge, _action), do: nil

  # BOOKMARK: Security log functions
  defp add_to_security_log_multi(multi, user, type, remote_ip, details \\ nil) do
    Ecto.Multi.run(multi, :log, fn _repo, %{challenge: challenge} ->
      add_to_security_log(user, challenge, type, remote_ip, details)
    end)
  end

  def add_to_security_log(user, challenge, type, remote_ip, details \\ nil) do
    SecurityLogs.track(%{
      originator_id: user.id,
      originator_role: user.role,
      originator_identifier: user.email,
      originator_remote_ip: remote_ip,
      target_id: challenge.id,
      target_type: "challenge",
      target_identifier: challenge.title,
      action: type,
      details: details
    })
  end

  # BOOKMARK: Misc functions
  def remove_logo(challenge) do
    challenge
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_change(:logo_key, nil)
    |> Ecto.Changeset.put_change(:logo_extension, nil)
    |> Repo.update()
  end

  def subscriber_count(challenge) do
    max(
      SavedChallenges.count_for_challenge(challenge),
      challenge.gov_delivery_subscribers
    )
  end

  def update_subscribe_count(challenge, {:ok, count}) do
    challenge
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_change(:gov_delivery_subscribers, count)
    |> Repo.update()
  end

  def update_subscribe_count(_challenge, _result), do: nil

  def store_gov_delivery_topic(challenge, topic) do
    challenge
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_change(:gov_delivery_topic, topic)
    |> Repo.update()
  end

  def clear_gov_delivery_topic(challenge) do
    challenge
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_change(:gov_delivery_topic, nil)
    |> Ecto.Changeset.put_change(:gov_delivery_subscribers, 0)
    |> Repo.update()
  end

  def remove_winner_image(challenge) do
    challenge
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_change(:winner_image_key, nil)
    |> Ecto.Changeset.put_change(:winner_image_extension, nil)
    |> Repo.update()
  end

  def remove_resource_banner(challenge) do
    challenge
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_change(:resource_banner_key, nil)
    |> Ecto.Changeset.put_change(:resource_banner_extension, nil)
    |> Repo.update()
  end

  # BOOKMARK: Recurring tasks
  def check_for_auto_publish do
    Enum.map(all_ready_for_publish(), fn challenge ->
      challenge
      |> Challenge.publish_changeset()
      |> Repo.update()
      |> email_challenge_managers("challenge_auto_publish")
    end)
  end

  defp email_challenge_managers({:ok, challenge}, template) do
    challenge = Repo.preload(challenge, [:challenge_manager_users])

    Enum.map(challenge.challenge_manager_users, fn manager ->
      case template do
        "challenge_auto_publish" ->
          manager
          |> Emails.challenge_auto_published(challenge)
          |> Mailer.deliver_later()

        _ ->
          nil
      end
    end)
  end

  defp email_challenge_managers(_, _), do: nil

  # Used in search filter
  defp maybe_filter_id(query, id) do
    case Integer.parse(id) do
      {id, _} ->
        or_where(query, [c], c.id == ^id)

      _ ->
        query
    end
  end

  # BOOKMARK: Filter functions
  @impl Stein.Filter
  def filter_on_attribute({"search", value}, query) do
    original_value = value
    value = "%" <> value <> "%"

    query
    |> where([c], ilike(c.title, ^value) or ilike(c.description, ^value))
    |> maybe_filter_id(original_value)
  end

  def filter_on_attribute({"status", value}, query) do
    where(query, [c], c.status == ^value)
  end

  def filter_on_attribute({"sub_status", value}, query) do
    where(query, [c], c.sub_status == ^value)
  end

  def filter_on_attribute({"types", values}, query) do
    Enum.reduce(values, query, fn value, query ->
      where(query, [c], fragment("? @> ?::jsonb", c.types, ^[value]))
    end)
  end

  def filter_on_attribute({"year", value}, query) do
    {value, _} = Integer.parse(value)
    where(query, [c], fragment("date_part('year', ?) = ?", c.end_date, ^value))
  end

  def filter_on_attribute({"agency_id", value}, query) do
    where(query, [c], c.agency_id == ^value)
  end

  def filter_on_attribute({"user_id", value}, query) do
    where(query, [c], c.user_id == ^value)
  end

  def filter_on_attribute({"user_ids", ids}, query) do
    query
    |> join(:inner, [c], co in assoc(c, :challenge_managers))
    |> where([co], co.user_id in ^ids)
  end

  def filter_on_attribute({"start_date_start", value}, query) do
    {:ok, datetime} = Timex.parse(value, "{YYYY}-{0M}-{0D}")
    where(query, [c], c.start_date >= ^datetime)
  end

  def filter_on_attribute({"start_date_end", value}, query) do
    {:ok, datetime} = Timex.parse(value, "{YYYY}-{0M}-{0D}")
    where(query, [c], c.start_date <= ^datetime)
  end

  def filter_on_attribute({"end_date_start", value}, query) do
    {:ok, datetime} = Timex.parse(value, "{YYYY}-{0M}-{0D}")
    where(query, [c], c.end_date >= ^datetime)
  end

  def filter_on_attribute({"end_date_end", value}, query) do
    {:ok, datetime} = Timex.parse(value, "{YYYY}-{0M}-{0D}")
    where(query, [c], c.end_date <= ^datetime)
  end

  def filter_on_attribute(_, query), do: query

  # BOOKMARK: Order functions
  def order_on_attribute(query, %{"user" => direction}) do
    query = join(query, :left, [c], a in assoc(c, :user))

    case direction do
      "asc" ->
        order_by(query, [c, a], asc_nulls_last: a.first_name)

      "desc" ->
        order_by(query, [c, a], desc_nulls_last: a.first_name)

      _ ->
        query
    end
  end

  def order_on_attribute(query, %{"agency" => direction}) do
    query = join(query, :left, [c], a in assoc(c, :agency))

    case direction do
      "asc" ->
        order_by(query, [c, a], asc_nulls_last: a.name)

      "desc" ->
        order_by(query, [c, a], desc_nulls_last: a.name)

      _ ->
        query
    end
  end

  def order_on_attribute(query, sort_columns) do
    columns_to_sort =
      Enum.reduce(sort_columns, [], fn {column, direction}, acc ->
        column = String.to_atom(column)

        case direction do
          "asc" ->
            acc ++ [asc_nulls_last: column]

          "desc" ->
            acc ++ [desc_nulls_last: column]

          _ ->
            []
        end
      end)

    order_by(query, [c], ^columns_to_sort)
  end
end

defmodule ChallengeGov.Challenges.Challenge do
  @moduledoc """
  Challenge schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias ChallengeGov.Accounts.User
  alias ChallengeGov.Agencies.Agency
  alias ChallengeGov.Challenges
  alias ChallengeGov.Challenges.ChallengeOwner
  alias ChallengeGov.Challenges.FederalPartner
  alias ChallengeGov.Challenges.NonFederalPartner
  alias ChallengeGov.Challenges.Phase
  alias ChallengeGov.Challenges.TimelineEvent
  alias ChallengeGov.SupportingDocuments.Document
  alias ChallengeGov.Timeline.Event

  @type t :: %__MODULE__{}

  @doc """
  - Challenge owner starts the form → saves it as a draft - Draft
  - Challenge owner submit for review from PMO - GSA Review
    - (2a) GSA Admin approves the challenge (waiting to be published according to date specified)- Approved
    - (2b) GSA Admin requests edits from Challenge Owner (i.e. date is wrong)- Edits Requested**
  - Challenge Owner updates the edits and re-submit to GSA Admin - GSA Review
  - Challenge goes Live - Published 
  - Challenge is archived - Archived
  - Published status but updating Winners & FAQ and submitted to GSA Admin - GSA Review
  - Challenge Owner updates an Archived challenge posting - goes to "GSA Review" -> GSA Admin approves -> status back to Archived
  """
  @statuses [
    %{id: "draft", label: "Draft"},
    %{id: "gsa_review", label: "GSA review"},
    %{id: "approved", label: "Approved"},
    %{id: "edits_requested", label: "Edits requested"},
    %{id: "unpublished", label: "Unpublished"},
    %{id: "published", label: "Published"},
    %{id: "archived", label: "Archived"}
  ]

  def status_ids() do
    Enum.map(@statuses, & &1.id)
  end

  @challenge_types [
    "Software and apps",
    "Creative (multimedia & design)",
    "Ideas",
    "Technology demonstration and hardware",
    "Nominations",
    "Business plans",
    "Analytics, visualizations, algorithms",
    "Scientific"
  ]

  @legal_authority [
    "America COMPETES",
    "Agency Prize Authority - DOT",
    "Direct Prize Authority",
    "Direct Prize Authority - DOD",
    "Direct Prize Authority - DOE",
    "Direct Prize Authority - USAID",
    "Space Act",
    "Grants and Cooperative Agreements",
    "Necessary Expense Doctrine",
    "Authority to Provide Non-Monetary Support to Prize Competitions",
    "Procurement Authority",
    "Other Transactions Authority",
    "Agency Partnership Authority",
    "Public-Private Partnership Authority",
    "Other"
  ]

  @sections [
    %{id: "general", label: "General Info"},
    %{id: "details", label: "Details"},
    %{id: "timeline", label: "Timeline"},
    %{id: "prizes", label: "Prizes"},
    %{id: "rules", label: "Rules"},
    %{id: "judging", label: "Judging"},
    %{id: "how_to_enter", label: "How to enter"},
    %{id: "resources", label: "Resources"},
    %{id: "review", label: "Review and submit"}
  ]

  schema "challenges" do
    field(:uuid, Ecto.UUID, autogenerate: true)

    # Associations
    belongs_to(:user, User)
    belongs_to(:agency, Agency)
    has_many(:events, Event, on_replace: :delete, on_delete: :delete_all)
    has_many(:supporting_documents, Document, on_delete: :delete_all)
    has_many(:challenge_owners, ChallengeOwner, on_delete: :delete_all)
    has_many(:challenge_owner_users, through: [:challenge_owners, :user])
    has_many(:federal_partners, FederalPartner, on_delete: :delete_all)
    has_many(:federal_partner_agencies, through: [:federal_partners, :agency])

    has_many(:non_federal_partners, NonFederalPartner, on_replace: :delete, on_delete: :delete_all)

    embeds_many(:phases, Phase, on_replace: :delete)
    embeds_many(:timeline_events, TimelineEvent, on_replace: :delete)

    # Array fields. Pseudo associations
    field(:types, {:array, :string}, default: [])

    # Images
    field(:logo_key, Ecto.UUID)
    field(:logo_extension, :string)

    field(:winner_image_key, Ecto.UUID)
    field(:winner_image_extension, :string)

    field(:resource_banner_key, Ecto.UUID)
    field(:resource_banner_extension, :string)

    # Fields
    field(:status, :string, default: "draft")
    field(:last_section, :string)
    field(:challenge_manager, :string)
    field(:challenge_manager_email, :string)
    field(:poc_email, :string)
    field(:agency_name, :string)
    field(:title, :string)
    field(:custom_url, :string)
    field(:external_url, :string)
    field(:tagline, :string)
    field(:type, :string)
    field(:description, :string)
    field(:brief_description, :string)
    field(:how_to_enter, :string)
    field(:fiscal_year, :string)
    field(:start_date, :utc_datetime)
    field(:end_date, :utc_datetime)
    field(:multi_phase, :boolean)
    field(:number_of_phases, :string)
    field(:phase_descriptions, :string)
    field(:phase_dates, :string)
    field(:judging_criteria, :string)
    field(:prize_type, :string)
    field(:prize_total, :integer)
    field(:non_monetary_prizes, :string)
    field(:prize_description, :string)
    field(:eligibility_requirements, :string)
    field(:rules, :string)
    field(:terms_and_conditions, :string)
    field(:legal_authority, :string)
    field(:faq, :string)
    field(:winner_information, :string)
    field(:captured_on, :date)
    field(:auto_publish_date, :utc_datetime)
    field(:published_on, :date)
    field(:rejection_message, :string)
    field(:how_to_enter_link, :string)

    field(:upload_logo, :boolean)
    field(:is_multi_phase, :boolean)
    field(:terms_equal_rules, :boolean)

    # Virtual Fields
    field(:logo, :string, virtual: true)

    field(:imported, :boolean)

    # Meta Timestamps
    field(:deleted_at, :utc_datetime)
    timestamps()
  end

  @doc """
  List of all challenge statuses
  """
  def statuses(), do: @statuses

  @doc """
  List of all challenge types
  """
  def challenge_types(), do: @challenge_types

  @doc """
  List of all legal authority options
  """
  def legal_authority(), do: @legal_authority

  @doc """
  List of all valid sections
  """
  def sections(), do: @sections

  # TODO: user_id, agency_id, and status should be locked behind admin only changeset
  def changeset(struct, params) do
    struct
    |> cast(params, [
      :user_id,
      :agency_id,
      :status,
      :challenge_manager,
      :challenge_manager_email,
      :poc_email,
      :agency_name,
      :title,
      :custom_url,
      :external_url,
      :tagline,
      :description,
      :brief_description,
      :how_to_enter,
      :fiscal_year,
      :start_date,
      :end_date,
      :multi_phase,
      :number_of_phases,
      :phase_descriptions,
      :phase_dates,
      :judging_criteria,
      :prize_total,
      :non_monetary_prizes,
      :prize_description,
      :eligibility_requirements,
      :rules,
      :terms_and_conditions,
      :legal_authority,
      :faq,
      :winner_information,
      :types,
      :auto_publish_date,
      :upload_logo,
      :is_multi_phase,
      :terms_equal_rules,
      :prize_type,
      :how_to_enter_link
    ])
    |> cast_assoc(:non_federal_partners, with: &NonFederalPartner.draft_changeset/2)
    |> cast_assoc(:events)
    |> cast_embed(:phases, with: &Phase.draft_changeset/2)
    |> validate_timeline_events_draft(params)
    |> validate_terms_draft(params)
  end

  def import_changeset(struct, params) do
    struct
    |> cast(params, [
      :user_id,
      :agency_id,
      :status,
      :challenge_manager,
      :challenge_manager_email,
      :poc_email,
      :agency_name,
      :title,
      :custom_url,
      :external_url,
      :tagline,
      :description,
      :brief_description,
      :how_to_enter,
      :fiscal_year,
      :start_date,
      :end_date,
      :multi_phase,
      :number_of_phases,
      :phase_descriptions,
      :phase_dates,
      :judging_criteria,
      :prize_total,
      :non_monetary_prizes,
      :prize_description,
      :eligibility_requirements,
      :rules,
      :terms_and_conditions,
      :legal_authority,
      :faq,
      :winner_information,
      :types,
      :auto_publish_date,
      :upload_logo,
      :is_multi_phase,
      :imported
    ])
    |> cast_assoc(:non_federal_partners, with: &NonFederalPartner.draft_changeset/2)
    |> cast_assoc(:events)
    |> cast_embed(:phases, with: &Phase.draft_changeset/2)
  end

  def draft_changeset(struct, params = %{"section" => section}) do
    struct
    |> changeset(params)
    |> put_change(:status, "draft")
    |> put_change(:last_section, section)
  end

  def section_changeset(struct, params = %{"section" => section}) do
    struct =
      struct
      |> changeset(params)
      |> put_change(:last_section, section)

    if section do
      apply(__MODULE__, String.to_atom("#{section}_changeset"), [struct, params])
    else
      struct
    end
  end

  def general_changeset(struct, _params) do
    struct
    |> validate_required([
      :challenge_manager,
      :challenge_manager_email,
      :poc_email,
      :agency_id,
      :fiscal_year
    ])
    |> cast_assoc(:non_federal_partners)
    |> validate_format(:challenge_manager_email, ~r/.+@.+\..+/)
    |> validate_format(:poc_email, ~r/.+@.+\..+/)
    |> validate_format(:fiscal_year, ~r/\bFY[0-9]{2}\b/)
  end

  def details_changeset(struct, params) do
    struct
    |> validate_required([
      :title,
      :tagline,
      :types,
      :brief_description,
      :description,
      :auto_publish_date,
      :upload_logo,
      :is_multi_phase
    ])
    |> validate_length(:tagline, max: 90)
    |> validate_length(:brief_description, max: 200)
    |> validate_length(:description, max: 4000)
    |> validate_types(params)
    |> validate_upload_logo(params)
    |> validate_auto_publish_date(params)
    |> validate_custom_url(params)
    |> validate_phases(params)
  end

  def timeline_changeset(struct, params) do
    struct
    |> validate_timeline_events(params)
  end

  def prizes_changeset(struct, params) do
    struct
    |> validate_required([
      :prize_type
    ])
    |> validate_prizes(params)
    |> force_change(:prize_description, fetch_field!(struct, :prize_description))
    |> validate_length(:prize_description, max: 1500)
  end

  def rules_changeset(struct, params) do
    struct
    |> validate_required([
      :terms_equal_rules,
      :eligibility_requirements,
      :rules,
      :legal_authority
    ])
    |> validate_terms(params)
  end

  def judging_changeset(struct, _params) do
    struct
    |> cast_embed(:phases, with: &Phase.judging_changeset/2)
  end

  def how_to_enter_changeset(struct, _params) do
    struct
    |> cast_embed(:phases, with: &Phase.how_to_enter_changeset/2)
  end

  def resources_changeset(struct, _params) do
    struct
    |> force_change(:faq, fetch_field!(struct, :faq))
    |> validate_length(:faq, max: 4000)
  end

  def review_changeset(struct, _params) do
    struct
  end

  # TODO: Add user usage back in if needing to track submitter
  def create_changeset(struct, params, _user) do
    struct
    |> changeset(params)
    |> cast_assoc(:non_federal_partners)
    |> put_change(:status, "gsa_review")
    |> put_change(:captured_on, Date.utc_today())
    |> validate_required([
      :user_id,
      :agency_id,
      :challenge_manager,
      :challenge_manager_email,
      :poc_email,
      :non_federal_partners,
      :title,
      :tagline,
      :description,
      :brief_description,
      :start_date,
      :end_date,
      :auto_publish_date
    ])
    |> foreign_key_constraint(:agency)
    |> unique_constraint(:custom_url)
    |> validate_inclusion(:status, status_ids())
    |> validate_auto_publish_date(params)
    |> validate_start_and_end_dates(params)
  end

  def update_changeset(struct, params) do
    struct
    |> changeset(params)
    |> cast_assoc(:non_federal_partners)
    |> validate_required([
      :user_id,
      :agency_id,
      :challenge_manager,
      :challenge_manager_email,
      :poc_email,
      :non_federal_partners,
      :title,
      :tagline,
      :description,
      :brief_description,
      :start_date,
      :end_date,
      :auto_publish_date
    ])
    |> foreign_key_constraint(:agency)
    |> unique_constraint(:custom_url)
    |> validate_inclusion(:status, status_ids())
    |> validate_auto_publish_date(params)
    |> validate_start_and_end_dates(params)
  end

  # to allow change to admin info?
  def admin_update_changeset(struct, params) do
    struct
    |> cast(params, [:user_id])
    |> update_changeset(params)
  end

  def approve_changeset(struct) do
    struct
    |> change()
    |> put_change(:status, "approved")
    |> put_change(:published_on, Date.utc_today())
    |> validate_inclusion(:status, status_ids())
  end

  def publish_changeset(struct) do
    struct
    |> change()
    |> put_change(:status, "published")
    |> put_change(:published_on, Date.utc_today())
    |> validate_inclusion(:status, status_ids())
  end

  def unpublish_changeset(struct) do
    struct
    |> change()
    |> put_change(:status, "unpublished")
    |> put_change(:published_on, Date.utc_today())
    |> validate_inclusion(:status, status_ids())
  end

  def reject_changeset(struct, message) do
    struct
    |> change()
    |> put_change(:rejection_message, message)
    |> put_change(:status, "edits_requested")
    |> validate_inclusion(:status, status_ids())
  end

  def submit_changeset(struct) do
    struct
    |> change()
    |> put_change(:status, "gsa_review")
    |> validate_inclusion(:status, status_ids())
  end

  # Image changesets
  def logo_changeset(struct, key, extension) do
    struct
    |> change()
    |> put_change(:logo_key, key)
    |> put_change(:logo_extension, extension)
  end

  def winner_image_changeset(struct, key, extension) do
    struct
    |> change()
    |> put_change(:winner_image_key, key)
    |> put_change(:winner_image_extension, extension)
  end

  def resource_banner_changeset(struct, key, extension) do
    struct
    |> change()
    |> put_change(:resource_banner_key, key)
    |> put_change(:resource_banner_extension, extension)
  end

  # Custom validations
  # TODO: Make this check that the types added are valid
  defp validate_types(struct, params) do
    case Map.get(params, "types") do
      "" ->
        add_error(struct, :types, "Must choose a challenge type")

      types when is_list(types) ->
        struct

      _ ->
        struct
    end
  end

  defp validate_upload_logo(struct, params = %{"upload_logo" => "true"}),
    do: validate_logo(struct, params)

  # TODO: Make this situation properly delete the uploaded file instead of just severing the connection
  defp validate_upload_logo(struct, %{"upload_logo" => "false"}) do
    struct
    |> put_change(:logo_key, nil)
    |> put_change(:logo_extension, nil)
  end

  defp validate_logo(struct, %{"logo" => logo}) when is_nil(logo),
    do: add_error(struct, :logo, "Must upload a logo")

  defp validate_logo(struct, %{"logo" => _logo}), do: struct

  defp validate_logo(struct = %{data: %{logo_key: logo_key}}, _params) when is_nil(logo_key),
    do: add_error(struct, :logo, "Must upload a logo")

  defp validate_logo(struct, _params), do: struct

  defp validate_start_and_end_dates(struct, params) do
    with {:ok, start_date} <- Map.fetch(params, "start_date"),
         {:ok, end_date} <- Map.fetch(params, "end_date"),
         {:ok, start_date} <- Timex.parse(start_date, "{ISO:Extended}"),
         {:ok, end_date} <- Timex.parse(end_date, "{ISO:Extended}"),
         1 <- Timex.compare(end_date, start_date) do
      struct
    else
      tc when tc == -1 or tc == 0 ->
        add_error(struct, :end_date, "must come after start date")

      _ ->
        add_error(struct, :start_and_end_date, "start and end date are required")
    end
  end

  defp validate_auto_publish_date(struct, %{"auto_publish_date" => date}) when not is_nil(date) do
    {:ok, date} = Timex.parse(date, "{ISO:Extended}")
    check_auto_publish_date(struct, date)
  end

  defp validate_auto_publish_date(struct = %{data: %{auto_publish_date: date}}, _params)
       when not is_nil(date) do
    check_auto_publish_date(struct, date)
  end

  defp validate_auto_publish_date(struct, _params) do
    struct
  end

  defp check_auto_publish_date(struct, date) do
    now = Timex.now()

    with 1 <- Timex.compare(date, now) do
      struct
    else
      tc when tc == -1 or tc == 0 ->
        add_error(struct, :auto_publish_date, "must be in the future")

      _error ->
        add_error(struct, :auto_publish_date, "is required")
    end
  end

  defp validate_custom_url(struct, params) do
    custom_url = Map.get(params, "custom_url")
    challenge_title = Map.get(params, "title")

    cond do
      custom_url != "" && custom_url != nil ->
        put_change(struct, :custom_url, create_custom_url_slug(custom_url))

      challenge_title != "" && challenge_title != nil ->
        put_change(struct, :custom_url, create_custom_url_slug(challenge_title))

      true ->
        struct
    end
  end

  defp create_custom_url_slug(value) do
    value
    |> String.trim()
    |> String.downcase()
    |> String.replace(" ", "-")
  end

  defp validate_phases(struct, %{"is_multi_phase" => "true", "phases" => phases}) do
    struct = cast_embed(struct, :phases, with: &Phase.multi_phase_changeset/2)

    phases
    |> Enum.map(fn {index, phase} ->
      overlap_check =
        phases
        |> Enum.reject(fn {i, _p} -> i === index end)
        |> Enum.map(fn {_i, p} ->
          date_range_overlaps(phase, p)
        end)
        |> Enum.any?()

      !overlap_check && validate_phase_start_and_end(phase)
    end)
    |> Enum.all?()
    |> case do
      true ->
        struct

      false ->
        add_error(
          struct,
          :phase_dates,
          "Please check your phase dates for overlaps or invalid date ranges"
        )
    end
  end

  defp validate_phases(struct, %{"is_multi_phase" => "false", "phases" => phases}) do
    struct = cast_embed(struct, :phases, with: &Phase.save_changeset/2)

    {_index, phase} = Enum.at(phases, 0)

    phase
    |> validate_phase_start_and_end
    |> case do
      true ->
        struct

      false ->
        add_error(
          struct,
          :phase_dates,
          "Please make sure you end date comes after your start date"
        )
    end
  end

  defp validate_phases(struct, _params), do: struct

  defp validate_phase_start_and_end(%{"start_date" => "", "end_date" => ""}), do: false

  defp validate_phase_start_and_end(%{"start_date" => start_date, "end_date" => end_date}) do
    with {:ok, start_date} <- Timex.parse(start_date, "{ISO:Extended}"),
         {:ok, end_date} <- Timex.parse(end_date, "{ISO:Extended}") do
      Timex.compare(start_date, end_date) < 0
    else
      _ -> false
    end
  end

  defp validate_phase_start_and_end(_phase), do: false

  # If there is an overlap return true else false
  defp date_range_overlaps(%{"start_date" => a_start, "end_date" => a_end}, %{
         "start_date" => b_start,
         "end_date" => b_end
       }) do
    with {:ok, a_start} <- Timex.parse(a_start, "{ISO:Extended}"),
         {:ok, a_end} <- Timex.parse(a_end, "{ISO:Extended}"),
         {:ok, b_start} <- Timex.parse(b_start, "{ISO:Extended}"),
         {:ok, b_end} <- Timex.parse(b_end, "{ISO:Extended}") do
      if (Timex.compare(a_start, b_start) <= 0 && Timex.compare(b_start, a_end) <= 0) ||
           (Timex.compare(a_start, b_end) <= 0 && Timex.compare(b_end, a_end) <= 0) ||
           (Timex.compare(b_start, a_start) < 0 && Timex.compare(a_end, b_end) < 0) do
        true
      else
        false
      end
    else
      _ ->
        false
    end
  end

  defp date_range_overlaps(_, _), do: true

  defp validate_timeline_events(struct, %{"timeline_events" => ""}),
    do: put_change(struct, :timeline_events, [])

  defp validate_timeline_events(struct, %{"timeline_events" => _timeline_events}),
    do:
      cast_embed(struct, :timeline_events,
        with: {TimelineEvent, :save_changeset, [Challenges.find_start_date(struct.data)]}
      )

  defp validate_timeline_events(struct, _), do: struct

  defp validate_timeline_events_draft(struct, %{"timeline_events" => ""}),
    do: put_change(struct, :timeline_events, [])

  defp validate_timeline_events_draft(struct, %{"timeline_events" => _timeline_events}),
    do: cast_embed(struct, :timeline_events, with: &TimelineEvent.draft_changeset/2)

  defp validate_timeline_events_draft(struct, _), do: struct

  defp validate_terms(struct, %{"terms_equal_rules" => "true", "rules" => rules}),
    do: put_change(struct, :terms_and_conditions, rules)

  defp validate_terms(struct, _params), do: validate_required(struct, [:terms_and_conditions])

  defp validate_terms_draft(struct, %{"terms_equal_rules" => "true", "rules" => rules}),
    do: put_change(struct, :terms_and_conditions, rules)

  defp validate_terms_draft(struct, _params), do: struct

  defp validate_prizes(struct, %{"prize_type" => "monetary"}) do
    validate_required(struct, [:prize_total])
  end

  defp validate_prizes(struct, %{"prize_type" => "non_monetary"}) do
    validate_required(struct, [:non_monetary_prizes])
  end

  defp validate_prizes(struct, %{"prize_type" => "both"}) do
    validate_required(struct, [
      :prize_total,
      :non_monetary_prizes
    ])
  end

  defp validate_prizes(struct, _params), do: struct
end

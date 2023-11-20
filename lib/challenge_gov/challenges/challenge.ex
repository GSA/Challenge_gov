defmodule ChallengeGov.Challenges.Challenge do
  @moduledoc """
  Challenge schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias ChallengeGov.Accounts.User
  alias ChallengeGov.Agencies.Agency
  alias ChallengeGov.Challenges
  alias ChallengeGov.Challenges.ChallengeManager
  alias ChallengeGov.Challenges.FederalPartner
  alias ChallengeGov.Challenges.NonFederalPartner
  alias ChallengeGov.Challenges.Phase
  alias ChallengeGov.Submissions.Submission
  alias ChallengeGov.Challenges.TimelineEvent
  alias ChallengeGov.Submissions.SubmissionExport
  alias ChallengeGov.SupportingDocuments.Document
  alias ChallengeGov.Timeline.Event

  @type t :: %__MODULE__{}

  schema "challenges" do
    field(:uuid, Ecto.UUID, autogenerate: true)

    # Associations
    belongs_to(:user, User)
    belongs_to(:agency, Agency)
    belongs_to(:sub_agency, Agency)
    has_many(:events, Event, on_replace: :delete, on_delete: :delete_all)
    has_many(:supporting_documents, Document, on_delete: :delete_all)
    has_many(:challenge_managers, ChallengeManager, on_delete: :delete_all)
    has_many(:challenge_manager_users, through: [:challenge_managers, :user])
    has_many(:federal_partners, FederalPartner, on_delete: :delete_all)
    has_many(:federal_partner_agencies, through: [:federal_partners, :agency])

    has_many(:non_federal_partners, NonFederalPartner, on_replace: :delete, on_delete: :delete_all)

    has_many(:phases, Phase)
    has_many(:submissions, Submission)

    has_many(:submission_exports, SubmissionExport)

    embeds_many(:timeline_events, TimelineEvent, on_replace: :delete)

    # Array fields. Pseudo associations
    field(:primary_type, :string)
    field(:types, {:array, :string}, default: [])
    field(:other_type, :string)

    # Images
    field(:logo_key, Ecto.UUID)
    field(:logo_extension, :string)
    field(:logo_alt_text, :string)

    field(:winner_image_key, Ecto.UUID)
    field(:winner_image_extension, :string)

    field(:resource_banner_key, Ecto.UUID)
    field(:resource_banner_extension, :string)

    # Fields
    field(:status, :string, default: "draft")
    field(:sub_status, :string)
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
    field(:description_delta, :string)
    field(:description_length, :integer, virtual: true)
    field(:brief_description, :string)
    field(:brief_description_delta, :string)
    field(:brief_description_length, :integer, virtual: true)
    field(:how_to_enter, :string)
    field(:fiscal_year, :string)
    field(:start_date, :utc_datetime)
    field(:end_date, :utc_datetime)
    field(:archive_date, :utc_datetime)
    field(:multi_phase, :boolean)
    field(:number_of_phases, :string)
    field(:phase_descriptions, :string)
    field(:phase_dates, :string)
    field(:judging_criteria, :string)
    field(:prize_type, :string)
    field(:prize_total, :integer, default: 0)
    field(:non_monetary_prizes, :string)
    field(:prize_description, :string)
    field(:prize_description_delta, :string)
    field(:prize_description_length, :integer, virtual: true)
    field(:eligibility_requirements, :string)
    field(:eligibility_requirements_delta, :string)
    field(:rules, :string)
    field(:rules_delta, :string)
    field(:terms_and_conditions, :string)
    field(:terms_and_conditions_delta, :string)
    field(:legal_authority, :string)
    field(:faq, :string)
    field(:faq_delta, :string)
    field(:faq_length, :integer, virtual: true)
    field(:winner_information, :string)
    field(:captured_on, :date)
    field(:auto_publish_date, :utc_datetime)
    field(:published_on, :date)
    field(:rejection_message, :string)
    field(:how_to_enter_link, :string)
    field(:announcement, :string)
    field(:announcement_datetime, :utc_datetime)
    field(:gov_delivery_topic, :string)
    field(:gov_delivery_subscribers, :integer, default: 0)
    field(:short_url, :string)

    field(:upload_logo, :boolean)
    field(:is_multi_phase, :boolean)
    field(:terms_equal_rules, :boolean)

    # Virtual Fields
    field(:logo, :string, virtual: true)

    field(:imported, :boolean)

    # Meta Timestamps
    field(:deleted_at, :utc_datetime)
    timestamps(type: :utc_datetime_usec)
  end

  # - Challenge manager starts the form → saves it as a draft - Draft
  # - Challenge manager submit for review from PMO - GSA Review
  #   - (2a) GSA Admin approves the challenge (waiting to be published according to date specified)- Approved
  #   - (2b) GSA Admin requests edits from Challenge Manager (i.e. date is wrong)- Edits Requested**
  # - Challenge Manager updates the edits and re-submit to GSA Admin - GSA Review
  # - Challenge goes Live - Published
  # - Challenge is archived - Archived
  # - Published status but updating Winners & FAQ and submitted to GSA Admin - GSA Review
  # - Challenge Manager updates an Archived challenge posting - goes to "GSA Review" -> GSA Admin approves -> status back to Archived
  @statuses [
    %{id: "draft", label: "Draft"},
    %{id: "gsa_review", label: "GSA review"},
    %{id: "approved", label: "Approved"},
    %{id: "edits_requested", label: "Edits requested"},
    %{id: "unpublished", label: "Unpublished"},
    %{id: "published", label: "Published"},
    %{id: "archived", label: "Archived"}
  ]

  @doc """
  List of all challenge statuses
  """
  def statuses(), do: @statuses

  def status_ids() do
    Enum.map(@statuses, & &1.id)
  end

  @doc """
  Sub statuses that a published challenge can have
  """
  @sub_statuses [
    "open",
    "closed",
    "archived"
  ]

  def sub_statuses(), do: @sub_statuses

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

  @doc """
  List of all challenge types
  """
  def challenge_types(), do: @challenge_types

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

  @doc """
  List of all legal authority options
  """
  def legal_authority(), do: @legal_authority

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

  @doc """
  List of all valid sections
  """
  def sections(), do: @sections

  @doc false
  def section_index(section) do
    sections = sections()
    Enum.find_index(sections, fn s -> s.id == section end)
  end

  @doc false
  def curr_section(section) do
    sections = sections()
    curr_index = section_index(section)
    Enum.at(sections, curr_index)
  end

  @doc false
  def next_section(section) do
    sections = sections()

    curr_index = section_index(section)

    if curr_index < length(sections) do
      Enum.at(sections, curr_index + 1)
    end
  end

  @doc false
  def prev_section(section) do
    sections = sections()

    curr_index = section_index(section)

    if curr_index > 0 do
      Enum.at(sections, curr_index - 1)
    end
  end

  @doc false
  def to_section(section, action) do
    case action do
      "next" -> next_section(section)
      "back" -> prev_section(section)
      _ -> curr_section(section)
    end
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [
      :user_id,
      :agency_id,
      :sub_agency_id,
      :status,
      :sub_status,
      :challenge_manager,
      :challenge_manager_email,
      :poc_email,
      :agency_name,
      :title,
      :custom_url,
      :external_url,
      :tagline,
      :description,
      :description_delta,
      :description_length,
      :brief_description,
      :brief_description_delta,
      :brief_description_length,
      :how_to_enter,
      :fiscal_year,
      :start_date,
      :end_date,
      :multi_phase,
      :number_of_phases,
      :phase_descriptions,
      :phase_dates,
      :judging_criteria,
      :non_monetary_prizes,
      :prize_description,
      :prize_description_delta,
      :eligibility_requirements,
      :eligibility_requirements_delta,
      :rules,
      :rules_delta,
      :terms_and_conditions,
      :terms_and_conditions_delta,
      :legal_authority,
      :faq,
      :faq_delta,
      :winner_information,
      :primary_type,
      :types,
      :other_type,
      :auto_publish_date,
      :upload_logo,
      :is_multi_phase,
      :terms_equal_rules,
      :prize_type,
      :how_to_enter_link,
      :announcement,
      :announcement_datetime,
      :short_url
    ])
    |> cast_assoc(:non_federal_partners, with: &NonFederalPartner.draft_changeset/2)
    |> cast_assoc(:events)
    |> cast_assoc(:phases, with: &Phase.draft_changeset/2)
    |> validate_timeline_events_draft(params)
    |> validate_terms_draft(params)
    |> maybe_set_start_end_dates(params)
    |> unique_constraint(:custom_url, name: "challenges_custom_url_index")
  end

  def import_changeset(struct, params) do
    struct
    |> cast(params, [
      :id,
      :user_id,
      :agency_id,
      :sub_agency_id,
      :status,
      :sub_status,
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
      :prize_type,
      :prize_total,
      :non_monetary_prizes,
      :prize_description,
      :eligibility_requirements,
      :rules,
      :terms_and_conditions,
      :terms_equal_rules,
      :legal_authority,
      :faq,
      :winner_information,
      :primary_type,
      :types,
      :other_type,
      :auto_publish_date,
      :upload_logo,
      :is_multi_phase,
      :imported
    ])
    |> unique_constraint(:id, name: :challenges_pkey)
    |> cast_assoc(:non_federal_partners, with: &NonFederalPartner.draft_changeset/2)
    |> cast_assoc(:events)
    |> cast_assoc(:phases, with: &Phase.draft_changeset/2)
    |> unique_constraint(:custom_url, name: "challenges_custom_url_index")
    |> validate_phases(params)
    |> maybe_set_start_end_dates(params)
  end

  def draft_changeset(struct, params = %{"section" => section}, action) do
    struct
    |> changeset(params)
    |> put_change(:status, "draft")
    |> put_change(:last_section, to_section(section, action).id)
  end

  def section_changeset(struct, params = %{"section" => section}, action) do
    struct
    |> changeset(params)
    |> put_change(:last_section, to_section(section, action).id)
    |> section_changeset_selector(params)
  end

  defp section_changeset_selector(struct, params = %{"section" => "general"}),
    do: general_changeset(struct, params)

  defp section_changeset_selector(struct, params = %{"section" => "details"}),
    do: details_changeset(struct, params)

  defp section_changeset_selector(struct, params = %{"section" => "timeline"}),
    do: timeline_changeset(struct, params)

  defp section_changeset_selector(struct, params = %{"section" => "prizes"}),
    do: prizes_changeset(struct, params)

  defp section_changeset_selector(struct, params = %{"section" => "rules"}),
    do: rules_changeset(struct, params)

  defp section_changeset_selector(struct, params = %{"section" => "judging"}),
    do: judging_changeset(struct, params)

  defp section_changeset_selector(struct, params = %{"section" => "how_to_enter"}),
    do: how_to_enter_changeset(struct, params)

  defp section_changeset_selector(struct, params = %{"section" => "resources"}),
    do: resources_changeset(struct, params)

  defp section_changeset_selector(struct, params = %{"section" => "review"}),
    do: review_changeset(struct, params)

  defp section_changeset_selector(struct, _), do: struct

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
    |> force_change(:fiscal_year, fetch_field!(struct, :fiscal_year))
    |> validate_format(:challenge_manager_email, ~r/.+@.+\..+/)
    |> validate_format(:poc_email, ~r/.+@.+\..+/)
    |> validate_format(:fiscal_year, ~r/\bFY[0-9]{2}\b/)
  end

  def details_changeset(struct, params) do
    struct
    |> validate_required([
      :title,
      :tagline,
      :primary_type,
      :description,
      :auto_publish_date,
      :upload_logo,
      :is_multi_phase
    ])
    |> validate_length(:title, max: 90)
    |> validate_length(:tagline, max: 90)
    |> validate_length(:brief_description, max: 200)
    |> validate_length(:other_type, max: 45)
    |> validate_inclusion(:primary_type, @challenge_types)
    |> maybe_validate_types(params)
    |> validate_upload_logo(params)
    |> validate_auto_publish_date(params)
    |> validate_custom_url(params)
    |> validate_custom_url()
    |> validate_phases(params)
  end

  defp validate_custom_url(changeset) do
    url = Ecto.Changeset.get_field(changeset, :custom_url)

    maybe_add_url_error(changeset, url)
  end

  defp maybe_add_url_error(changeset, nil), do: changeset

  defp maybe_add_url_error(changeset, url) do
    if Regex.match?(~r/[^a-z0-9\-]/, url) do
      Ecto.Changeset.add_error(changeset, :custom_url, "URL Contains Invalid Character(s).")
    else
      changeset
    end
  end

  def validate_rich_text_length(struct, field, length) do
    field_length = String.to_existing_atom("#{field}_length")
    value = get_field(struct, field_length)

    case value do
      nil ->
        struct

      _ ->
        if value > length do
          add_error(struct, field, "can't be greater than #{length} characters")
        else
          struct
        end
    end
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
  end

  def parse_currency(struct, %{"prize_total" => prize_total}) do
    case Money.parse(prize_total, :USD) do
      {:ok, money} ->
        case money.amount <= 0 do
          true ->
            add_error(struct, :prize_total, "must be more than $0")

          false ->
            put_change(struct, :prize_total, money.amount)
        end

      :error ->
        add_error(struct, :prize_total, "Invalid currency formatting")
    end
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
    |> cast_assoc(:phases, with: &Phase.judging_changeset/2)
  end

  def how_to_enter_changeset(struct, _params) do
    struct
    |> cast_assoc(:phases, with: &Phase.how_to_enter_changeset/2)
  end

  def resources_changeset(struct, _params) do
    struct
    |> force_change(:faq, fetch_field!(struct, :faq))
  end

  def review_changeset(struct, params) do
    struct
    |> general_changeset(params)
    |> details_changeset(params)
    |> timeline_changeset(params)
    |> prizes_changeset(params)
    |> rules_changeset(params)
    |> judging_changeset(params)
    |> how_to_enter_changeset(params)
    |> resources_changeset(params)
    |> submit_changeset()
  end

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
      :title,
      :tagline,
      :description,
      :brief_description,
      :auto_publish_date
    ])
    |> foreign_key_constraint(:agency)
    |> unique_constraint(:custom_url, name: "challenges_custom_url_index")
    |> validate_inclusion(:status, status_ids())
    |> validate_auto_publish_date(params)
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
      :title,
      :tagline,
      :description,
      :brief_description,
      :auto_publish_date
    ])
    |> foreign_key_constraint(:agency)
    |> unique_constraint(:custom_url, name: "challenges_custom_url_index")
    |> validate_inclusion(:status, status_ids())
    |> validate_auto_publish_date(params)
  end

  def create_announcement_changeset(struct, announcement) do
    struct
    |> change()
    |> put_change(:announcement, announcement)
    |> put_change(:announcement_datetime, DateTime.truncate(DateTime.utc_now(), :second))
    |> validate_length(:announcement, max: 150)
  end

  def remove_announcement_changeset(struct) do
    struct
    |> change()
    |> put_change(:announcement, nil)
    |> put_change(:announcement_datetime, nil)
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
  def logo_changeset(struct, key, extension, alt_text) do
    struct
    |> change()
    |> put_change(:logo_key, key)
    |> put_change(:logo_extension, extension)
    |> put_change(:logo_alt_text, alt_text)
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

  defp maybe_validate_types(struct, %{"types" => types}) do
    Enum.reduce(types, struct, fn type, struct ->
      if type != "" and !Enum.member?(@challenge_types, type) do
        add_error(struct, :types, "A value selected for an optional challenge type is invalid")
      else
        struct
      end
    end)
  end

  defp maybe_validate_types(struct, _params), do: struct

  defp validate_upload_logo(struct, params = %{"upload_logo" => "true"}),
    do: validate_logo(struct, params)

  defp validate_upload_logo(struct, %{"upload_logo" => "false"}) do
    struct
    |> put_change(:logo_key, nil)
    |> put_change(:logo_extension, nil)
    |> put_change(:logo_alt_text, nil)
  end

  defp validate_upload_logo(struct, _params), do: struct

  defp validate_logo(struct, %{"logo" => logo}) when is_nil(logo),
    do: add_error(struct, :logo, "Must upload a logo")

  defp validate_logo(struct, %{"logo" => _logo}), do: struct

  defp validate_logo(struct = %{data: %{logo_key: logo_key}}, _params) when is_nil(logo_key),
    do: add_error(struct, :logo, "Must upload a logo")

  defp validate_logo(struct, _params), do: struct

  defp validate_auto_publish_date(struct, %{"auto_publish_date" => date, "challenge_id" => id})
       when not is_nil(date) do
    {:ok, date} = Timex.parse(date, "{ISO:Extended}")
    {:ok, %{status: status}} = Challenges.get(id)
    if status === "published", do: struct, else: check_auto_publish_date(struct, date)
  end

  defp validate_auto_publish_date(
         struct = %{data: %{auto_publish_date: date, status: status}},
         _params
       )
       when not is_nil(date) do
    case status do
      "published" ->
        struct

      _ ->
        check_auto_publish_date(struct, date)
    end
  end

  defp validate_auto_publish_date(struct, _params) do
    struct
  end

  defp check_auto_publish_date(struct, date) do
    now = Timex.now()

    case Timex.compare(date, now) do
      1 ->
        struct

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
    |> String.replace(~r/[^a-z0-9\-]/, "")
  end

  defp maybe_set_start_end_dates(struct, %{"phases" => phases}) do
    struct
    |> set_start_date(phases)
    |> set_end_date(phases)
    |> set_archive_date(phases)
    |> put_change(:sub_status, nil)
  end

  defp maybe_set_start_end_dates(struct, _params), do: struct

  defp set_start_date(struct, phases) do
    if Enum.any?(phases, fn {_, phase} -> dates_exist?(phase) end) do
      {_, start_phase} =
        phases
        |> Enum.filter(fn {_, p} ->
          p["open_to_submissions"] === "true" or p["open_to_submissions"] === true
        end)
        |> Enum.min_by(fn {_, p} -> p["start_date"] end)

      {:ok, start_date} =
        start_phase
        |> Map.fetch!("start_date")
        |> Timex.parse("{ISO:Extended}")

      put_change(struct, :start_date, DateTime.truncate(start_date, :second))
    else
      struct
    end
  end

  defp set_end_date(struct, phases) do
    if Enum.any?(phases, fn {_, phase} -> dates_exist?(phase) end) do
      {_, end_phase} =
        phases
        |> Enum.filter(fn {_, p} ->
          p["open_to_submissions"] === "true" or p["open_to_submissions"] === true
        end)
        |> Enum.max_by(fn {_, p} -> p["end_date"] end)

      {:ok, end_date} =
        end_phase
        |> Map.fetch!("end_date")
        |> Timex.parse("{ISO:Extended}")

      put_change(struct, :end_date, DateTime.truncate(end_date, :second))
    else
      struct
    end
  end

  defp set_archive_date(struct, phases) do
    if Enum.any?(phases, fn {_, phase} -> dates_exist?(phase) end) do
      {_, end_phase} =
        phases
        |> Enum.max_by(fn {_, p} -> p["end_date"] end)

      {:ok, end_date} =
        end_phase
        |> Map.fetch!("end_date")
        |> Timex.parse("{ISO:Extended}")

      archive_date = Timex.shift(end_date, months: 3)

      put_change(struct, :archive_date, DateTime.truncate(archive_date, :second))
    else
      struct
    end
  end

  defp dates_exist?(%{"open_to_submissions" => "true", "start_date" => "", "end_date" => ""}),
    do: false

  defp dates_exist?(%{"open_to_submissions" => "true", "start_date" => "", "end_date" => _}),
    do: false

  defp dates_exist?(%{"open_to_submissions" => "true", "start_date" => _, "end_date" => ""}),
    do: false

  defp dates_exist?(%{"open_to_submissions" => true, "start_date" => "", "end_date" => ""}),
    do: false

  defp dates_exist?(%{"open_to_submissions" => true, "start_date" => "", "end_date" => _}),
    do: false

  defp dates_exist?(%{"open_to_submissions" => true, "start_date" => _, "end_date" => ""}),
    do: false

  defp dates_exist?(%{"open_to_submissions" => "true", "start_date" => _, "end_date" => _}),
    do: true

  defp dates_exist?(%{"open_to_submissions" => true, "start_date" => _, "end_date" => _}),
    do: true

  defp dates_exist?(_phase), do: false

  defp validate_phases(struct, %{"is_multi_phase" => "true", "phases" => phases}) do
    struct = cast_assoc(struct, :phases, with: &Phase.multi_phase_changeset/2)

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
    struct = cast_assoc(struct, :phases, with: &Phase.save_changeset/2)

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

  defp validate_terms(struct, %{
         "terms_equal_rules" => "true",
         "rules" => rules,
         "rules_delta" => rules_delta
       }) do
    struct
    |> put_change(:terms_and_conditions, rules)
    |> put_change(:terms_and_conditions_delta, rules_delta)
  end

  defp validate_terms(struct, _params), do: validate_required(struct, [:terms_and_conditions])

  defp validate_terms_draft(struct, %{
         "terms_equal_rules" => "true",
         "rules" => rules,
         "rules_delta" => rules_delta
       }) do
    struct
    |> put_change(:terms_and_conditions, rules)
    |> put_change(:terms_and_conditions_delta, rules_delta)
  end

  defp validate_terms_draft(struct, _params), do: struct

  defp validate_prizes(struct, params = %{"prize_type" => "monetary"}) do
    struct
    |> parse_currency(params)
    |> validate_required([:prize_total])
    |> put_change(:non_monetary_prizes, nil)
  end

  defp validate_prizes(struct, _params = %{"prize_type" => "non_monetary"}) do
    struct
    |> validate_required([:non_monetary_prizes])
    |> put_change(:prize_total, 0)
  end

  defp validate_prizes(struct, params = %{"prize_type" => "both"}) do
    struct
    |> parse_currency(params)
    |> validate_required([
      :prize_total,
      :non_monetary_prizes
    ])
  end

  defp validate_prizes(struct, _params), do: struct
end

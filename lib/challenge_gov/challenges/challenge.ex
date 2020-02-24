defmodule ChallengeGov.Challenges.Challenge do
  @moduledoc """
  Challenge schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias ChallengeGov.Accounts.User
  alias ChallengeGov.Agencies.Agency
  alias ChallengeGov.Challenges.FederalPartner
  alias ChallengeGov.Challenges.NonFederalPartner
  alias ChallengeGov.SupportingDocuments.Document
  alias ChallengeGov.Timeline.Event

  @type t :: %__MODULE__{}

  @statuses [
    "draft",
    "pending",
    "created",
    "rejected",
    "published",
    "archived"
  ]

  @challenge_types [
    "Ideation",
    "Scientific Discovery",
    "Technology Development and hardware",
    "Software and Apps",
    "Data Analytics,Visualizations",
    "Algorithms",
    "Design"
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
    "Public-Private Partnership Authority"
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
    # Associations
    belongs_to(:user, User)
    belongs_to(:agency, Agency)
    has_many(:events, Event, on_replace: :delete)
    has_many(:supporting_documents, Document)
    has_many(:federal_partners, FederalPartner)
    has_many(:federal_partner_agencies, through: [:federal_partners, :agency])
    has_many(:non_federal_partners, NonFederalPartner, on_replace: :delete)

    # Images
    field(:logo_key, Ecto.UUID)
    field(:logo_extension, :string)

    field(:winner_image_key, Ecto.UUID)
    field(:winner_image_extension, :string)

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
    field(:fiscal_year, :integer)
    field(:start_date, :utc_datetime)
    field(:end_date, :utc_datetime)
    field(:multi_phase, :boolean)
    field(:number_of_phases, :string)
    field(:phase_descriptions, :string)
    field(:phase_dates, :string)
    field(:judging_criteria, :string)
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
    field(:published_on, :date)

    timestamps()
  end

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

  def changeset(struct, params) do
    struct
    |> cast(params, [
      :user_id,
      :agency_id,
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
      :winner_information
    ])
    |> cast_assoc(:non_federal_partners)
    |> cast_assoc(:events)
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
    |> validate_required([:title])
  end

  def details_changeset(struct, _params) do
    struct
  end

  def timeline_changeset(struct, _params) do
    struct
  end

  def prizes_changeset(struct, _params) do
    struct
  end

  def rules_changeset(struct, _params) do
    struct
  end

  def judging_changeset(struct, _params) do
    struct
  end

  def how_to_enter_changeset(struct, _params) do
    struct
  end

  def resources_changeset(struct, _params) do
    struct
  end

  def review_changeset(struct, _params) do
    struct
  end

  # TODO: Add user usage back in if needing to track submitter
  def create_changeset(struct, params, _user) do
    struct
    |> changeset(params)
    |> put_change(:captured_on, Date.utc_today())
    |> validate_required([
      :user_id,
      :agency_id,
      :challenge_manager,
      :challenge_manager_email,
      :poc_email,
      :non_federal_partners,
      :title,
      :custom_url,
      :external_url,
      :tagline,
      :description,
      :brief_description,
      :how_to_enter,
      :start_date,
      :end_date,
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
      :winner_information
    ])
    |> foreign_key_constraint(:agency)
    |> unique_constraint(:custom_url)
    |> validate_inclusion(:status, @statuses)
  end

  def update_changeset(struct, params) do
    struct
    |> changeset(params)
    |> validate_required([
      :user_id,
      :agency_id,
      :status,
      :challenge_manager,
      :challenge_manager_email,
      :poc_email,
      :non_federal_partners,
      :title,
      :custom_url,
      :external_url,
      :tagline,
      :description,
      :brief_description,
      :how_to_enter,
      :start_date,
      :end_date,
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
      :winner_information
    ])
    |> foreign_key_constraint(:agency)
    |> unique_constraint(:custom_url)
    |> validate_inclusion(:status, @statuses)
  end

  # to allow change to admin info?
  def admin_update_changeset(struct, params) do
    struct
    |> cast(params, [:user_id])
    |> update_changeset(params)
  end

  def publish_changeset(struct) do
    struct
    |> change()
    |> put_change(:status, "created")
    |> put_change(:published_on, Date.utc_today())
    |> validate_inclusion(:status, @statuses)
  end

  def reject_changeset(struct) do
    struct
    |> change()
    |> put_change(:status, "rejected")
    |> validate_inclusion(:status, @statuses)
  end

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
end

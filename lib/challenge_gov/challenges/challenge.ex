defmodule ChallengeGov.Challenges.Challenge do
  @moduledoc """
  User schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias ChallengeGov.Accounts.User
  alias ChallengeGov.SupportingDocuments.Document
  alias ChallengeGov.Timeline.Event

  @type t :: %__MODULE__{}

  @statuses [
    "pending", "created", "rejected", "published", "archived"
  ]

  @agencies [
    "IARPA", "Bureau of the Census", "Agency for International Development", "Bureau of Reclamation", "Department of the Interior", "Department of Energy", "Environmental Protection Agency", "Department of State", "Defense Advanced Research Projects Agency", "National Science Foundation", "United States Patent and Trademark Office", "Department of Health and Human Services", "Department of Homeland Security", "Department of the Interior", "NASA", "Department of Defense", "International Assistance Programs - Department of State", "International Assistance Programs - Agency for International Development", "The White House", "Executive Residence at the White House", "Commission of the Intelligence Capabilities of the…ited States Regarding Weapons of Mass Destruction", "Council of Economic Advisers", "Council on Environmental Quality and Office of Environmental  Quality", "Council on International Economic Policy", "Council on Wage and Price Stability", "Office of Policy Development", "National Security Council and Homeland Security Council", "National Space Council", "National Critical Materials Council", "Armstrong Resolution", "Office of National Service", "Office of Management and Budget", "Office of National Drug Control Policy", "Office of Science and Technology Policy", "Office of the United States Trade Representative", "Office of Telecommunications Policy", "The Points of Light Foundation", "White House Conference for a Drug Free America", "Special Action Office for Drug Abuse Prevention", "Office of Drug Abuse Policy", "Unanticipated Needs", "Expenses of Management Improvement", "Presidential Transition", "National Nuclear Security Administration", "Environmental and Other Defense Activities", "Energy Programs", "Power Marketing Administration", "General Administration", "United States Parole Commission", "Legal Activities and U.S. Marshals", "Radiation Exposure Compensation", "National Security Division", "Federal Bureau of Investigation", "Drug Enforcement Administration", "Bureau of Alcohol, Tobacco, Firearms, and Explosives", "Federal Prison System", "Office of Justice Programs", "Violent Crime Reduction Trust Fund", "Employment and Training Administration", "Employee Benefits Security Administration", "Pension Benefit Guaranty Corporation", "Office of Workers' Compensation Programs", "Wage and Hour Division", "Employment Standards Administration", "Occupational Safety and Health Administration", "Mine Safety and Health Administration", "Bureau of Labor Statistics", "Office of Federal Contract Compliance Programs", "Office of Labor Management Standards", "Office of Elementary and Secondary Education", "Office of Innovation and Improvement", "Office of Safe and Drug-Free Schools", "Office of English Language Acquisition", "Office of Special Education and Rehabilitative Services", "Office of Vocational and Adult Education", "Office of Postsecondary Education", "Office of Federal Student Aid", "Institute of Education Sciences", "Hurricane Education Recovery", "Financial Crimes Enforcement Network", "Financial Management Service", "Federal Financing Bank", "Fiscal Service", "Alcohol and Tobacco Tax and Trade Bureau", "Bureau of Engraving and Printing", "United States Mint", "Bureau of the Public Debt", "Internal Revenue Service", "Comptroller of the Currency", "Office of Thrift Supervision", "Interest on the Public Debt", "Bureau of Land Management", "Bureau of Ocean Energy Management", "Bureau of Safety and Environmental Enforcement", "Office of Surface Mining Reclamation and Enforcement", "Department of the Interior - Bureau of Reclamation", "Central Utah Project", "United States Geological Survey", "Bureau of Mines", "United States Fish and Wildlife Service"
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

  schema "challenges" do
    belongs_to(:user, User)
    has_many(:events, Event)
    has_many(:supporting_documents, Document)

    field(:status, :string, default: "pending")
    field(:title, :string)
    field(:tagline, :string)
    field(:poc_email, :string) # Might just be a point of contact relation
    field(:agency_name, :string)
    field(:how_to_enter, :string)
    field(:rules, :string)
    field(:description, :string)
    field(:external_url, :string)
    field(:custom_url, :string)
    field(:start_date, :utc_datetime)
    field(:end_date, :utc_datetime)
    # field(:logo_key, Ecto.UUID)
    # field(:logo_extension, :string)
    field(:fiscal_year, :integer)
    field(:type, :string)
    # Terms and conditions - Boolean or datetime for when they were accepted
    field(:prize_total, :integer)
    field(:prize_description, :string)
    # Non monetary prizes
    field(:judging_criteria, :string)
    # Judging criteria uploads
    # Federal partners
    # Non federal partners
    # Other field - Multiple with a title and text. Another relation
    field(:challenge_manager, :string) # Will probably be a relation
    field(:legal_authority, :string)
    # Phases has_many relation probably
    # Winning participant images
    field(:captured_on, :date)
    field(:published_on, :date)

    timestamps()
  end

  @doc """
  List of all agencies
  """
  def agencies(), do: @agencies

  @doc """
  List of all challenge types
  """
  def challenge_types(), do: @challenge_types

  def create_changeset(struct, params, user) do
    struct
    |> cast(params, [
      :title,
      :tagline,
      :poc_email,
      :agency_name,
      :how_to_enter,
      :rules,
      :description,
      :external_url,
      :custom_url,
      :start_date,
      :end_date,
      :fiscal_year,
      :type,
      :prize_total,
      :prize_description,
      :judging_criteria,
      :challenge_manager,
      :legal_authority
    ])
    |> put_change(:captured_on, Date.utc_today())
    |> validate_required([
      :title,
      :tagline,
      :poc_email,
      :agency_name,
      :how_to_enter,
      :rules,
      :description,
      :external_url,
      :custom_url,
      :start_date,
      :end_date,
      :fiscal_year,
      :type,
      :prize_total,
      :prize_description,
      :judging_criteria,
      :challenge_manager,
      :legal_authority
    ])
    |> validate_inclusion(:agency_name, @agencies)
    |> validate_inclusion(:type, @challenge_types)
  end

  def update_changeset(struct, params) do
    struct
    |> cast(params, [
      :status,
      :title,
      :tagline,
      :poc_email,
      :agency_name,
      :how_to_enter,
      :rules,
      :description,
      :external_url,
      :custom_url,
      :start_date,
      :end_date,
      :fiscal_year,
      :type,
      :prize_total,
      :prize_description,
      :judging_criteria,
      :challenge_manager,
      :legal_authority
    ])
    |> validate_required([
      :status,
      :title,
      :tagline,
      :poc_email,
      :agency_name,
      :how_to_enter,
      :rules,
      :description,
      :external_url,
      :custom_url,
      :start_date,
      :end_date,
      :fiscal_year,
      :type,
      :prize_total,
      :prize_description,
      :judging_criteria,
      :challenge_manager,
      :legal_authority
    ])
    |> validate_inclusion(:agency_name, @agencies)
    |> validate_inclusion(:type, @challenge_types)
  end

# to allow change to admin info?
  def admin_changeset(struct, params, user) do
    struct
    |> create_changeset(params, user)
  end

  def publish_changeset(struct) do
    struct
    |> change()
    |> put_change(:status, "created")
    |> put_change(:published_on, Date.utc_today())
  end

  def reject_changeset(struct) do
    struct
    |> change()
    |> put_change(:status, "rejected")
  end
end

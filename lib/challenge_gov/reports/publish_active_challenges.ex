defmodule ChallengeGov.Reports.PublishActiveChallenges do
  @moduledoc """
  Reportschema
  """

  use Ecto.Schema
  alias ChallengeGov.Repo

 # @type t :: %__MODULE__{}

  @primary_key false
  schema "publishactivechallenges" do
    field :challenge_id, :integer
    field :challenge_name, :string
    field :agency_name, :string
    field :agency_id, :integer
    field :prize_amount, :float
    field :created_date, :utc_datetime
    field :published_date, :date
    field :status, :string
    field :listing_type, :string
    field :challenge_type, :string
    field :challenge_suscribers, :integer
    field :submissions, :integer
    field :start_date, :string
    field :end_date, :string
    field :current_timestamp, :utc_datetime
  end

end

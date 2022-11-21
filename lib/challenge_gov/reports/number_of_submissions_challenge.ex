defmodule ChallengeGov.Reports.NumberOfSubmissionsChallenge do
  @moduledoc """
  Reportschema
  """

  use Ecto.Schema
  alias ChallengeGov.Repo

 # @type t :: %__MODULE__{}

  @primary_key false
  schema "numberofsubmissionschallenge" do
    field :challenge_id, :integer
    field :challenge_name, :string
    field :created_date, :utc_datetime
    field :listing_type, :string
    field :submissions, :integer
    field :current_timestamp, :utc_datetime
  end

end

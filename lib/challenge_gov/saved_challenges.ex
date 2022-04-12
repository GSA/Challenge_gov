defmodule ChallengeGov.SavedChallenges do
  @moduledoc """
  Context for saved challenges
  """
  @behaviour Stein.Filter

  import Ecto.Query

  alias ChallengeGov.Challenges
  alias ChallengeGov.GovDelivery
  alias ChallengeGov.Repo
  alias ChallengeGov.SavedChallenges.SavedChallenge
  alias Stein.Filter

  def all(user, opts \\ []) do
    SavedChallenge
    |> base_preload
    |> where([sc], sc.user_id == ^user.id)
    |> Filter.filter(opts[:filter], __MODULE__)
    |> Repo.paginate(opts[:page], opts[:per])
  end

  def get(id) do
    SavedChallenge
    |> base_preload
    |> where([sc], sc.id == ^id)
    |> Repo.one()
    |> case do
      nil ->
        {:error, :not_found}

      saved_challenge ->
        {:ok, saved_challenge}
    end
  end

  def get_saved_challenge(id) do
    SavedChallenge
    |> where([sc], sc.id == ^id)
    |> Repo.one()
    |> case do
      nil ->
        {:error, :not_found}

      saved_challenge ->
        {:ok, saved_challenge}
    end
  end

  def create(user, challenge) do
    if is_nil(challenge.deleted_at) and Challenges.is_public?(challenge) do
      result =
        %SavedChallenge{}
        |> SavedChallenge.changeset(user, challenge)
        |> Repo.insert()

      GovDelivery.subscribe_user_general(user)
      GovDelivery.subscribe_user_challenge(user, challenge)

      result
    else
      {:error, :not_saved}
    end
  end

  def delete(user, saved_challenge) do
    if user.id === saved_challenge.user_id do
      Repo.delete(saved_challenge)
    else
      {:error, :not_allowed}
    end
  end

  def check_manager(user, saved_challenge) do
    if user.id === saved_challenge.user_id do
      {:ok, saved_challenge}
    else
      {:error, :wrong_manager}
    end
  end

  defp base_preload(saved_challenge) do
    preload(saved_challenge, [:user, challenge: [:agency, :sub_agency]])
  end

  def count_for_challenge(challenge) do
    SavedChallenge
    |> select([sc], count(sc))
    |> where([sc], sc.challenge_id == ^challenge.id)
    |> Repo.one()
  end

  @impl Stein.Filter
  def filter_on_attribute({"user_id", value}, query) do
    where(query, [sc], sc.user_id == ^value)
  end
end

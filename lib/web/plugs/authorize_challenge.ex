defmodule Web.Plugs.AuthorizeChallenge do
  @moduledoc """
  Verify the currently logged in user has edit permissions
  for the current challenge set in the conn assigns

  Requires the following plugs to be called before this one can function:
  Web.Plugs.FetchUser - Sets current_user in assigns
  Web.Plugs.FetchChallenge - Sets current_challenge in assigns
  """

  import Phoenix.Controller

  alias ChallengeGov.Challenges
  alias Web.Router.Helpers, as: Routes

  def init(default), do: default

  def call(conn, opts) do
    redirect_route = Keyword.get(opts, :redirect, Routes.dashboard_path(conn, :index))
    %{current_user: user} = conn.assigns

    case allowed_to_edit?(conn, user) do
      {:ok, _challenge} ->
        conn

      {:error, :not_permitted} ->
        conn
        |> put_flash(:error, "You are not allowed to view this challenge")
        |> redirect(to: redirect_route)
    end
  end

  defp allowed_to_edit?(conn, user) do
    case Map.fetch(conn.assigns, :current_challenge) do
      {:ok, challenge} ->
        Challenges.allowed_to_edit(user, challenge)

      :error ->
        {:error, :not_permitted}
    end
  end
end

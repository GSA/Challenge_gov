defmodule Web.GuideView do
  use Web, :view

  alias Web.SharedView

  alias ChallengeGov.Accounts

  def user_signed_in?(conn) do
    Map.has_key?(conn.assigns, :current_user)
  end

  def current_user(conn) do
    if user_signed_in?(conn) do
      Map.get(conn.assigns, :current_user)
    end
  end
end

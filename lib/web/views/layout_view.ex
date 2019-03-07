defmodule Web.LayoutView do
  use Web, :view

  def user_signed_in?(conn) do
    Map.has_key?(conn.assigns, :current_user)
  end
end

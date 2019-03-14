defmodule Web.LayoutView do
  use Web, :view

  alias IdeaPortal.Recaptcha

  def user_signed_in?(conn) do
    Map.has_key?(conn.assigns, :current_user)
  end

  def recaptcha_script() do
    recaptcha_key = Recaptcha.recaptcha_key()

    case is_nil(recaptcha_key) do
      true ->
        []

      false ->
        content_tag(:script, "",
          src: "https://www.google.com/recaptcha/api.js?render=#{recaptcha_key}"
        )
    end
  end

  def tab_selected(conn, "dashboard") do
    case conn.path_info == ["admin"] do
      true ->
        "active"

      false ->
        ""
    end
  end

  def tab_selected(conn, route) do
    case conn.path_info do
      ["admin", ^route] ->
        "active"

      ["admin", ^route, _] ->
        "active"

      _ ->
        ""
    end
  end
end

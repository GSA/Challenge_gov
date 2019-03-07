defmodule Web.LayoutView do
  use Web, :view

  def user_signed_in?(conn) do
    Map.has_key?(conn.assigns, :current_user)
  end

  def recaptcha_script() do
    recaptcha_key = Application.get_env(:idea_portal, :recaptcha)[:key]

    case is_nil(recaptcha_key) do
      true ->
        []

      false ->
        content_tag(:script, "",
          src: "https://www.google.com/recaptcha/api.js?render=#{recaptcha_key}"
        )
    end
  end
end

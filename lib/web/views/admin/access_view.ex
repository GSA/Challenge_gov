defmodule Web.Admin.AccessView do
  use Web, :view

  def recertification_heading_based_on_user(user) do
    case user.status == "decertified" do
      true ->
        [
          content_tag(:h4, "Your account must be recertified."),
          content_tag(:p, "You may request recertification by submitting the following:")
        ]

      false ->
        [
          content_tag(:p, "Request recertification by submitting the following:")
        ]
    end
  end
end

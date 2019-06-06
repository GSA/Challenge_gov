defmodule Web.AccountView do
  use Web, :view

  alias IdeaPortal.Accounts.Avatar
  alias Stein.Storage
  alias Web.FormView
  alias Web.SharedView

  def avatar_img(user) do
    case is_nil(user.avatar_key) do
      true ->
        img_tag(Routes.static_path(Web.Endpoint, "/images/icon-profile.png"), alt: "Avatar")

      false ->
        img_tag(Storage.url(Avatar.avatar_path(user, "thumbnail")), alt: "Avatar")
    end
  end

  def full_name(user) do
    "#{user.first_name} #{user.last_name}"
  end
end

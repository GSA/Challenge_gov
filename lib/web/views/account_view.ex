defmodule Web.AccountView do
  use Web, :view

  alias Web.FormView
  alias Web.SharedView

  def full_name(user) do
    "#{user.first_name} #{user.last_name}"
  end
end

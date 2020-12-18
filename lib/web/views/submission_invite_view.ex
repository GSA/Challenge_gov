defmodule Web.SubmissionInviteView do
  use Web, :view

  alias Web.FormView
  alias Web.SharedView

  def status_text(%{invite: invite}) when not is_nil(invite) do
    case invite.status do
      "pending" ->
        [
          "Invite sent at ",
          SharedView.local_datetime_tag(invite.updated_at, :span)
        ]

      "accepted" ->
        [
          "Accepted at ",
          SharedView.local_datetime_tag(invite.updated_at, :span)
        ]

      "revoked" ->
        [
          "Revoked at ",
          SharedView.local_datetime_tag(invite.updated_at, :span)
        ]
    end
  end

  def status_text(_submission), do: nil
end

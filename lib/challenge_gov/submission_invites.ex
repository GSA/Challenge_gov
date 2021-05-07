defmodule ChallengeGov.SubmissionInvites do
  @moduledoc """
  Context for managing submission invites for a phase
  """

  import Ecto.Query

  alias ChallengeGov.Emails
  alias ChallengeGov.Mailer
  alias ChallengeGov.Repo
  alias ChallengeGov.Submissions
  alias ChallengeGov.Submissions.SubmissionInvite

  def get(id) do
    SubmissionInvite
    |> preload([:submission])
    |> Repo.get(id)
    |> case do
      nil ->
        {:error, :not_found}

      submission_invite ->
        {:ok, submission_invite}
    end
  end

  def create(params, submission) do
    %SubmissionInvite{}
    |> SubmissionInvite.create_changeset(params, submission)
    |> Repo.insert()
    |> case do
      {:ok, submission_invite} ->
        submission_invite
        |> Emails.submission_invite()
        |> Mailer.deliver_later()

        {:ok, submission_invite}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def reinvite(submission_invite, params) do
    submission_invite
    |> SubmissionInvite.reinvite_changeset(params)
    |> Repo.update()
    |> case do
      {:ok, submission_invite} ->
        submission_invite = Repo.preload(submission_invite, submission: [:challenge, :submitter])

        submission_invite
        |> Emails.submission_invite()
        |> Mailer.deliver_later()

        {:ok, submission_invite}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def bulk_create(params, submission_ids) do
    submission_ids
    |> Enum.reduce(Ecto.Multi.new(), fn submission_id, multi ->
      Ecto.Multi.run(multi, submission_id, fn _repo, _changes ->
        {:ok, submission} = Submissions.get(submission_id)

        if submission.invite do
          reinvite(submission.invite, params)
        else
          create(params, submission)
        end
      end)
    end)
    |> Repo.transaction()
  end

  def accept(submission_invite) do
    submission_invite
    |> SubmissionInvite.accept_changeset()
    |> Repo.update()
  end

  def revoke(submission_invite) do
    submission_invite
    |> SubmissionInvite.revoke_changeset()
    |> Repo.update()
  end
end

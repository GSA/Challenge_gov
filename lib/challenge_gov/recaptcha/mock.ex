defmodule ChallengeGov.Recaptcha.Mock do
  @moduledoc """
  Mock implementation details for Recaptcha
  """

  @behaviour ChallengeGov.Recaptcha

  alias __MODULE__.FakeCaptcha

  @doc false
  def start_mock() do
    {:ok, pid} = FakeCaptcha.start_link()
    Process.put(:recpatcha, pid)
  end

  def set_valid_token_response(is_valid) do
    start_mock()
    pid = Process.get(:recpatcha)
    FakeCaptcha.set_valid_token(pid, is_valid)
  end

  @impl ChallengeGov.Recaptcha
  def valid_token?(_token) do
    case Process.get(:recpatcha) do
      nil ->
        {:ok, 0.9}

      pid ->
        FakeCaptcha.valid_token?(pid)
    end
  end

  defmodule FakeCaptcha do
    @moduledoc false

    use GenServer

    def start_link() do
      GenServer.start_link(__MODULE__, [])
    end

    def set_valid_token(pid, is_valid) do
      GenServer.call(pid, {:set_valid, is_valid})
    end

    def valid_token?(pid) do
      GenServer.call(pid, :valid_token?)
    end

    def init(_) do
      {:ok, %{valid_token?: {:error, "init"}}}
    end

    def handle_call({:set_valid, is_valid}, _from, state) do
      state = Map.put(state, :valid_token?, is_valid)

      {:reply, :ok, state}
    end

    def handle_call(:valid_token?, _from, state) do
      {:reply, state.valid_token?, state}
    end
  end
end

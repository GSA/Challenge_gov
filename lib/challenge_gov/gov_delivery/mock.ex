defmodule ChallengeGov.GovDelivery.Mock do
  @moduledoc """
  Mock implementation details for GovDelivery
  """

  @behaviour ChallengeGov.GovDelivery

  alias __MODULE__.FakeGovDelivery

  @doc false
  def start_mock() do
    {:ok, pid} = FakeGovDelivery.start_link()
    Process.put(:govdelivery, pid)
  end

  def set_remove_topic_response(response) do
    start_mock()
    pid = Process.get(:govdelivery)
    FakeGovDelivery.set_remove_topic(pid, response)
  end

  def set_add_topic_response(response) do
    start_mock()
    pid = Process.get(:govdelivery)
    FakeGovDelivery.set_add_topic(pid, response)
  end

  @impl true
  def remove_topic(_id) do
    case Process.get(:govdelivery) do
      nil ->
        {:not_found}

      pid ->
        FakeGovDelivery.remove_topic_response(pid)
    end
  end

  @impl true
  def add_topic(_challenge) do
    case Process.get(:govdelivery) do
      nil ->
        {:not_found}

      pid ->
        FakeGovDelivery.add_topic_response(pid)
    end
  end

  defmodule FakeGovDelivery do
    @moduledoc false

    use GenServer

    def start_link() do
      GenServer.start_link(__MODULE__, [])
    end

    def set_remove_topic(pid, response) do
      GenServer.call(pid, {:remove_topic, response})
    end

    def remove_topic_response(pid) do
      GenServer.call(pid, :get_remove)
    end

    def set_add_topic(pid, response) do
      GenServer.call(pid, {:add_topic, response})
    end

    def add_topic_response(pid) do
      GenServer.call(pid, :get_add)
    end

    def init(_) do
      {:ok, %{add: nil, remove: nil}}
    end

    def handle_call({:remove_topic, response}, _from, state) do
      state = Map.put(state, :remove, response)

      {:reply, :ok, state}
    end

    def handle_call(:get_remove, _from, state) do
      {:reply, state.remove, state}
    end

    def handle_call({:add_topic, response}, _from, state) do
      state = Map.put(state, :add, response)

      {:reply, :ok, state}
    end

    def handle_call(:get_add, _from, state) do
      {:reply, state.add, state}
    end
  end
end

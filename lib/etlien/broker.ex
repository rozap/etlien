defmodule Etlien.Broker do
  use Workex
  require Logger
  alias Etlien.Nice
  alias Etlien.Group

  defmodule BrokerState do
    defstruct groups: %{}
  end

  @notify_tag :ref_notify

  def start_link do
    water_mark = Application.get_env(:etlien, :broker)[:water_mark]
    {:ok, pid} = Workex.start_link(__MODULE__, [], max_size: water_mark)
    Process.register(pid, __MODULE__)
    {:ok, pid}
  end

  def init(_) do
    {:ok, %BrokerState{}}
  end

  def handle_cast({:subscribe, %Group{id: gid} = group, who}, state) do
    listeners = [who | Map.get(state.groups, gid, [])] |> Enum.dedup
    groups = Map.put(state.groups, gid, listeners)
    {:ok, struct(state, groups: groups)}
  end

  def handle_cast({:notify, %Group{id: gid} = group, set, ref}, state) do
    num = state.groups
    |> Map.get(gid, [])
    |> Enum.reduce(0, fn listener, c ->
      send listener, {@notify_tag, {group, set, ref}}
      c + 1
    end)

    Logger.info("Dispatched #{num} notifications")

    {:ok, state}
  end

  def handle(messages, state) do
    state = Enum.reduce(messages, state, fn message, acc ->
      {:ok, state} = handle_cast(message, acc)
      state
    end)

    {:ok, state}
  end

  def notify(group, set, ref) do
    Workex.push(__MODULE__, {:notify, group, set, ref})
  end

  def subscribe(group) do
    Workex.push(__MODULE__, {:subscribe, group, self})
  end


end
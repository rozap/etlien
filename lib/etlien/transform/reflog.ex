defmodule Etlien.Transform.Reflog do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], [name: __MODULE__])
  end

  def init(_) do
    {:ok, %{refs: %{}}}
  end


  def handle_call({:append, expr, chunk_ref}, _, %{refs: refs} = state) do
    refs = Dict.put(refs, expr, [chunk_ref | Dict.get(refs, expr, [])])
    {:noreply, %{state | refs: refs}}
  end

  def append(expr, chunk_ref) do
    GenServer.call(__MODULE__, {:append, expr, chunk_ref})
  end


end
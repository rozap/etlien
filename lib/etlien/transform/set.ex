defmodule Etlien.Transform.Set do
  use Supervisor
  require Logger

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    :pg2.delete(__MODULE__.Worker)
    :pg2.create(__MODULE__.Worker)
    count = Application.get_env(:etlien, :set)[:count]
    Enum.map(1..count, fn i ->
      id = String.to_atom("set_worker_#{i}")
      worker(__MODULE__.Worker, [[id: id]], id: id)
    end)
    |> supervise(strategy: :one_for_one, name: __MODULE__)
  end

  defmodule Worker do
    use Workex
    def start_link(args) do
      water_mark = Application.get_env(:etlien, :set)[:water_mark]
      {:ok, pid} = Workex.start_link(__MODULE__, args, max_size: water_mark)
      :pg2.join(__MODULE__, pid)
      {:ok, pid}
    end

    def init([id: id]) do
      Logger.info("Started #{id}")
      {:ok, %{}}
    end

    def handle({:append, job, {header, rows}}) do

    end
  end

  def append(job, chunk) do
    timeout = Application.get_env(:etlien, :set)[:max_attempt_timeout]
    Etlien.Nice.cast_for(
      __MODULE__.Worker,
      {:append, job, chunk},
      timeout
    )
  end

end
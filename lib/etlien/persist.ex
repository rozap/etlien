defmodule Etlien.Persist do
  use Supervisor
  require Logger
  alias Etlien.Transform.Applicator
  alias Etlien.Transformed

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  defp hash_term(term) do
    bin = :erlang.term_to_binary(term)

    :crypto.hash(:sha256, bin)
    |> Base.encode16
  end

  def chunk_hash(actual_chunk) do
    hash_term(actual_chunk)
  end


  def key(%Transformed{expr: {_, impl}, original_header: h, original_chunk_hash: hashed_chunk}) do
    key({impl, h, hashed_chunk})
  end

  def key({expr, header, chunk_h}) when is_binary(chunk_h) do
    primary_key = {expr, header, chunk_h}
    hash_term(primary_key)
  end

  def key({expr, header, actual_chunk}) when is_list(actual_chunk) do
    chunk_h = chunk_hash(actual_chunk)
    key({expr, header, chunk_h})
  end


  defmodule Worker do
    def start_link(args) do
      water_mark = Application.get_env(:etlien, :persist)[:water_mark]
      {:ok, pid} = Workex.start_link(__MODULE__, args, max_size: water_mark)
      :pg2.join(__MODULE__, pid)
      {:ok, pid}
    end

    def init([id: id]) do
      Logger.info("Started #{id}")
      {:ok, %{}}
    end

    defp handle({:put, transformed, sender}) do
      Logger.debug("#{inspect self} Handling chunk #{inspect transformed}")

      thing = :erlang.term_to_binary transformed
      ref = Etlien.Persist.key(transformed)

      Application.get_env(:etlien, :persist)[:path]
      |> Path.join("#{ref}.erl")
      |> File.write!(thing)

      send sender, {:put, {:ok, ref}}

      :ok
    end

    defp handle({:get, ref, sender}) do
      path = Application.get_env(:etlien, :persist)[:path]
      |> Path.join("#{ref}.erl")

      if File.exists?(path) do
        item = path
        |> File.read!
        |> :erlang.binary_to_term

        send sender, {:get, {:ok, item}}
      else
        send sender, {:get, {:error, :not_found}}
      end

      :ok
    end

    def handle(messages, state) do
      Enum.reduce_while(messages, :ok, fn message, acc ->
        case handle(message) do
          :ok -> {:cont, acc}
          {:error, reason} ->
            Logger.error("Failed to push chunk #{reason}")
            {:halt, reason}
        end
      end)

      {:ok, state}
    end
  end


  def init(_) do
    :pg2.delete(__MODULE__.Worker)
    :pg2.create(__MODULE__.Worker)
    count = Application.get_env(:etlien, :persist)[:count]
    Enum.map(1..count, fn i ->
      id = String.to_atom("persist_worker_#{i}")
      worker(__MODULE__.Worker, [[id: id]], id: id)
    end)
    |> supervise(strategy: :one_for_one, name: __MODULE__)
  end


  def put(transformed) do
    timeout = Application.get_env(:etlien, :persist)[:max_attempt_timeout]
    Etlien.Nice.cast_for(
      __MODULE__.Worker,
      {:put, transformed, self},
      timeout
    )
    receive do
      {:put, result} -> result
    after timeout -> {:error, :timeout}
    end
  end

  def get(ref) do
    timeout = Application.get_env(:etlien, :persist)[:max_attempt_timeout]
    Etlien.Nice.cast_for(
      __MODULE__.Worker,
      {:get, ref, self},
      timeout
    )    
    receive do
      {:get, result} -> result
    after timeout -> {:error, :timeout}
    end
    
  end


end
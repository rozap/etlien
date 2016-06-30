defmodule Etlien.Transform.Chunker do
  alias Etlien.{Persist, Transform, Ref, Repo, Broker}

  def on_chunk(group, set, chunk) do
    result = Transform.identity(set.columns, chunk)
    |> Persist.put

    with {:ok, ref} <- result,
      {:ok, ref} <- Repo.insert(%Ref{ref: ref, set_id: set.id}) do
      Broker.notify(group, set, ref)
    end
  end

  defp fits_in?(set, chunk) do
    true
  end

  defp get_or_create_set(group, chunk) do
    case Enum.find(group.sets, &fits_in?(&1, chunk)) do
      nil ->
        IO.puts "Creating set for #{inspect chunk}"
        {group, nil}
      set ->
        IO.puts "Fits in #{inspect set}"
        {group, set}
    end
  end

  def unflatten(group, stream) do
    group = Repo.preload group, :sets
    Stream.transform(
      stream,
      group,
      fn chunk, acc ->
        {group, set} = get_or_create_set(group, chunk)
        {[{group, set, chunk}], group}
      end
    )
  end
end
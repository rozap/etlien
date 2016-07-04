defmodule Etlien.Transform.Chunker do
  alias Etlien.{Persist, Transform, Ref, Repo, Broker, Set}

  @chunk_size 4

  def on_chunk(group, set, chunk) do
    result = Transform.identity(set.columns, chunk)
    |> Persist.put

    with {:ok, ref} <- result,
      {:ok, ref} <- Repo.insert(%Ref{ref: ref, set_id: set.id}) do
      Broker.notify(group, set, ref)
    end
  end

  defp fits_in?(header, {header, _}), do: true
  defp fits_in?(_, {_, _}), do: false

  defp get_or_create_set(group, row) do
    case Enum.find(group.sets, &fits_in?(&1.columns.names, row)) do
      nil ->
        {names, _} = row
        set = Repo.insert! %Set{
          group_id: group.id,
          columns: %{
            names: names
          }
        }
        group = struct(group, sets: [set | group.sets])
        {group, set}
      set ->
        {group, set}
    end
  end

  def unflatten(stream, group) do
    group = Repo.preload group, :sets
    Stream.transform(
      stream,
      group,
      fn row, acc_group ->
        {group, set} = get_or_create_set(acc_group, row)
        {_, datum} = row
        {[{set, datum}], group}
      end
    )
  end

  ## speed - unflatten and chunk can be coalesced into a single pass
  def chunk(stream, group) do
    stream
    |> Stream.chunk(@chunk_size, @chunk_size, [])
    |> Stream.flat_map(fn chunk ->
      Enum.reduce(chunk, %{}, fn {set, row}, acc ->
        members = case Map.get(acc, set) do
          nil -> [row]
          members -> [row | members]
        end

        Map.put(acc, set, members)
      end)
      |> Enum.map(fn set_chunk -> set_chunk end)
    end)
  end

  def emit!(stream, group) do
    Stream.each(stream, fn {set, chunk} -> on_chunk(group, set, chunk) end)
  end
end
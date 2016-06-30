defmodule Etlien.Resource.Csv do
  @behaviour Etlien.Resource

  alias Etlien.Resource.State

  defp closed?(<< ?" :: utf8, rest :: binary >>, inside) do
    closed?(rest, not inside)
  end

  defp closed?(<< _ :: utf8, rest :: binary >>, inside) do
    closed?(rest, inside)
  end

  defp closed?("", inside) do
    not inside
  end

  defp columns(line, separator) do
    columns([], false, 0, line, line, separator) |> Enum.reverse |> Enum.map fn
      << ?" :: utf8, rest :: binary >> ->
        String.slice(rest, 0 .. -2) |> String.replace ~S<"">, ~S<">

      column ->
        column
    end
  end

  defp columns(columns, _, offset, "", line, _) do
    [String.slice(line, 0 .. offset) | columns]
  end

  defp columns(columns, inside, offset, << ?" :: utf8, rest :: binary >>, line, separator) do
    columns(columns, not inside, offset + 1, rest, line, separator)
  end

  defp columns(columns, inside, offset, rest, line, separator) do
    if not inside and rest |> String.starts_with? separator do
      columns = [String.slice(line, 0 .. offset - 1) | columns]
      line    = String.slice(line, offset + String.length(separator) .. -1)

      columns(columns, inside, 0, line, line, separator)
    else
      << _ :: utf8, rest :: binary >> = rest

      columns(columns, inside, offset + 1, rest, line, separator)
    end
  end


  def init([]) do
    %State{
      meta: %{
        inside: false
      }
    }
  end

  def unescape(lines, unescaped, inside) do
    Enum.reduce(lines, {[], unescaped, inside}, fn line, {to_emit, current, inside} ->

      current = [line | current]
      if closed?(line, inside) do

        emit = current
        |> Enum.reverse
        |> Enum.join("\n")

        { [emit | to_emit], [], false }
      else
        { to_emit, current, true }
      end
    end)
  end

  defp read(<< ?\n :: utf8, rest :: binary>>, state) do
    read(rest, struct(
      state,
      prev: [state.buf | state.prev],
      buf: ""
    ))
  end

  defp read(<< b :: binary-size(1), rest :: binary >>, state) do
    read(rest, struct(state, buf: state.buf <> b))
  end

  defp read("", state) do
    state
  end

  def zip_header(header, to_emit) do
    Enum.map(to_emit, fn e -> {header, e} end)
  end

  def on_bytes(bytes, state) do
    unescaped = state.prev
    state = read(bytes, struct(state, prev: []))
    {to_emit, prev, inside} = unescape(Enum.reverse(state.prev), unescaped, state.meta.inside)

    to_emit = to_emit
    |> Enum.map(fn e -> columns(e, ",") end)
    |> Enum.reverse

    state = struct(state, prev: prev, meta: %{inside: inside})

    if state.header == [] do
      case to_emit do
        [] -> {to_emit, state}
        [header | rest] -> {zip_header(header, rest), struct(state, header: header)}
      end
    else
      {zip_header(state.header, to_emit), state}
    end
  end

end
defmodule Etlien.Transform.Applicator do
  require Logger
  alias Etlien.Persist
  alias Etlien.Transformed

  @identity {:fn, [pure: true],
    [{:->, [],
     [[{:header, [], Elixir}, {:row, [], Elixir}],
      {:{}, [], [:ok, {:header, [], Elixir}, {:row, [], Elixir}]}]}]}

  def identity, do: @identity

  def pure(func) do
    {:fn, meta, args} = func
    {:fn, [{:pure, true} | meta], args}
  end
  ## This should be read only from persist store

  # Every transform looks like
  # fn header, row -> {:ok, _} | {:error, _} end
  # Wrap given
  #   fn header, row -> {:ok, row} end = inner
  #   fn header, row, a, b -> {:ok, "hello"} end = outer
  # would need to return
  #
  # fn meta, header, row, a, b ->
  #    case inner(row) do
  #      {:ok, result} -> outer(result)
  #      err -> err
  #    end
  # end
  def wrap(inner_expr, outer_expr) do
    inner_application = {{:., [], [inner_expr]}, [],
     [{:header, [], Elixir}, {:row, [], Elixir}]}

    outer_application = {{:., [], [outer_expr]}, [],
     [{:result_header, [], Elixir}, {:result_row, [], Elixir}]}


    {:fn, [],
     [{:->, [],
       [[{:header, [], Elixir}, {:row, [], Elixir}],
        {:case, [], [inner_application,
          [do: [
            {:->, [], [[{:{}, [],
              [:ok, {:result_header, [], Elixir}, {:result_row, [], Elixir}]}],
              outer_application]},
            {:->, [], [[{:err, [], Elixir}], {:err, [], Elixir}]}]]]}]}]}
  end

  def unwrap(outer) do
    {:fn, [],
     [{:->, [],
       [[{:header, [], Elixir}, {:row, [], Elixir}],
        {:case, [], [{{:., [], [inner_expr]}, _, _},
          [do: [
            {:->, [], [_, {{:., [], [outer_expr]}, _, _}]},
            {:->, [], [[{:err, [], Elixir}], {:err, [], Elixir}]}]]]}]}]} = outer

    {inner_expr, outer_expr}
  end



  defp descend_expr(expr, datum) do
    {inner_expr, outer_expr} = unwrap(expr)


    IO.puts "Inner #{Macro.to_string(inner_expr)}"
    IO.puts "Outer #{Macro.to_string(outer_expr)}"

    case apply_to_chunk(inner_expr, datum) do
      {:ok, %Transformed{result_header: header, result_chunk: chunk} = t} ->
        {outer_func, _} = Code.eval_quoted(outer_expr)

        {_, out_header, out_chunk, errors} = Enum.reduce(
          chunk,
          {header, nil, [], []},
          fn row, {in_header, out_header, transformed, errors} ->
            case outer_func.(in_header, row) do
              {:ok, new_header, new_row} ->
                {in_header, new_header, [new_row | transformed], errors}
              {:error, reason} ->
                Logger.warn(reason)
                {in_header, out_header, transformed, [reason | errors]}
            end
        end)

        {:ok, struct(t,
          result_header: out_header,
          result_chunk: out_chunk,
          result_errors: errors ++ t.result_errors
        )}

      err -> err
    end
  end

  defp apply_expr(@identity, {header, chunk}) do
    Persist.key({@identity, header, chunk})
    |> Persist.get
  end

  def apply_to_chunk(@identity, datum) do
    apply_expr(@identity, datum)
  end

  def apply_to_chunk(expr, {header, chunk} = datum) do
    existing = Persist.key({expr, header, chunk})
    |> Persist.get

    case existing do
      {:ok, _} = resp -> resp
      {:error, :not_found} -> descend_expr(expr, datum)
      err -> err
    end

  end

end
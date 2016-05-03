defmodule Etlien.Transform.Applicator do
  require Logger
  alias Etlien.Persist
  alias Etlien.Transformed

  @identity (quote do: fn header, row -> {:ok, header, row} end)

  def identity, do: {true, @identity}
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
  def wrap({inner_pure?, inner_expr}, {outer_pure?, outer_expr}) do
    inner_application = {{:., [], [inner_expr]}, [],
     [{:header, [], Elixir}, {:row, [], Elixir}]}

    outer_application = {{:., [], [outer_expr]}, [],
     [{:result_header, [], Elixir}, {:result_row, [], Elixir}]}


    {inner_pure? && outer_pure?, {:fn, [],
     [{:->, [],
       [[{:header, [], Elixir}, {:row, [], Elixir}],
        {:case, [], [inner_application,
          [do: [
            {:->, [], [[{:{}, [],
              [:ok, {:result_header, [], Elixir}, {:result_row, [], Elixir}]}], 
              outer_application]},
            {:->, [], [[{:err, [], Elixir}], {:err, [], Elixir}]}]]]}]}]}}
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
    {upstream_expr, outer_expr} = unwrap(expr)
    case apply_expr(upstream_expr, datum) do
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
        # IO.inspect upstream_expr
        # struct()


        # {func, _} = Code.eval_quoted(expr)

        # {_, out_header, transformed, errors} = Enum.reduce(
        #   t.chunk, 
        #   {t.header, nil, [], []}, 
        #   fn row, {in_header, out_header, transformed, errors} ->
        #     case func.(in_header, row) do
        #       {:ok, new_header, new_row} ->
        #         {in_header, new_header, [new_row | transformed], errors}
        #       {:error, reason} ->
        #         Logger.warn(reason)
        #         {in_header, out_header, transformed, [reason | errors]}
        #     end
        # end)
  end

  defp apply_expr(@identity, {header, chunk}) do
    Persist.key({@identity, header, chunk})
    |> Persist.get
  end

  def apply_to_chunk({true, @identity}, datum) do
    apply_expr(@identity, datum)
  end

  def apply_to_chunk({true, expr}, {header, chunk} = datum) do
    existing = Persist.key({expr, header, chunk})
    |> Persist.get

    case existing do
      {:ok, _} = resp -> resp
      {:error, :not_found} -> descend_expr(expr, datum)
      err -> err
    end

  end

end
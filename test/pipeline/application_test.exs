defmodule ApplicatorTest do
  use ExUnit.Case, async: false
  alias Etlien.Persist
  alias Etlien.Transform.Applicator
  alias Etlien.Transformed

  @foobar {:foo, [], [{:bar, [], [:__DATUM__]}]}

  setup_all do
    {:ok, pid} = Etlien.Persist.start_link
    on_exit fn -> Process.exit(pid, :kill) end
    :ok
  end

  test "will give an error when identity isn't in Persist" do
    expr = Applicator.identity
    header = ["some_header"]
    chunk = [["some_chunk"]]

    assert Applicator.apply_to_chunk(expr, {header, chunk}) == {:error, :not_found}
  end

  test "can apply the identity transform by retrieving it from Persist" do
    expr = Applicator.identity
    header = ["some", "letters", "wow"]
    chunk = [["a"], ["b"], ["c"]]

    t = %Transformed{
      expr: expr, 
      original_header: header,
      original_chunk_hash: Persist.chunk_hash(chunk),
      result_header: header, 
      result_chunk: chunk
    }

    {:ok, _} = Persist.put(t)

    {:ok, result} = Applicator.apply_to_chunk(expr, {header, chunk})

     assert result == t
  end


  test "can return an error for a missing base case in a wrapped expr" do
    expr = Applicator.identity
    header = ["az", "bz", "cz"]
    chunk = [["aa", "bb", "cc"]]

    t = %Transformed{
      expr: Applicator.identity, 
      original_header: header,
      original_chunk_hash: Persist.chunk_hash(chunk),
      result_header: header, 
      result_chunk: chunk
    }

    wrapped_expr = Applicator.wrap(
      expr, 
      quote do: {true, fn header, row -> 
        {:ok, header |> Enum.reverse, row |> Enum.reverse} 
      end}
    )

    res = Applicator.apply_to_chunk(wrapped_expr, {header, chunk})
    assert res == {:error, :not_found}
  end

  test "can wrap the identity function" do
    expr = Applicator.identity
    header = ["a", "b", "c"]
    chunk = [["aa", "bb", "cc"]]

    t = %Transformed{
      expr: Applicator.identity, 
      original_header: header,
      original_chunk_hash: Persist.chunk_hash(chunk),
      result_header: header, 
      result_chunk: chunk
    }
    {:ok, _} = Persist.put(t)

    wrapped_expr = Applicator.wrap(
      expr, 
      quote do: {true, fn header, row -> 
        {:ok, header |> Enum.reverse, row |> Enum.reverse} 
      end}
    )

    {:ok, %Transformed{
      result_chunk: result_chunk,
      result_header: result_header
    }} = Applicator.apply_to_chunk(wrapped_expr, {header, chunk})

    assert result_header == ["c", "b", "a"]
    assert result_chunk == [["cc", "bb", "aa"]]
  end

  # test "can unwrap wrapped functions" do
  #   t = %Transform{
  #     func: Applicator.identity, 
  #     header: [[]], 
  #     seq_num: 1, 
  #     chunk: [[]]
  #   }
  #   {:ok, _} = Persist.put(t)

  #   t = struct(t, func: Applicator.wrap(
  #     Applicator.identity, 
  #     quote do: {true, fn header, row -> {:ok, header |> Enum.reverse, row |> Enum.reverse} end}
  #   ))

  #   {true, i} = Applicator.identity
  #   assert Applicator.unwrap(t.func) == i
  # end

  # test "can apply by unwrapping nested transforms by retrieving it from Persist" do
  #   t = %Transform{
  #     func: Applicator.identity, 
  #     header: ["a_letter"], 
  #     seq_num: 1, 
  #     chunk: [["a"], ["b"], ["c"]]
  #   }

  #   {:ok, _} = Persist.put(t)
    
  #   # Wrap it...
  #   t = struct(t, func: Applicator.wrap(
  #     Applicator.identity, 
  #     quote do: {true, fn header, row -> {:ok, header |> Enum.reverse, row |> Enum.reverse} end}
  #   ))


  #   {:ok, result} = Applicator.apply(t)

  #    IO.inspect result
  # end

end
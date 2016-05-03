defmodule PersistTest do
  use ExUnit.Case, async: false
  alias Etlien.Persist
  alias Etlien.Transformed
  alias Etlien.Transform.Applicator

  setup_all do
    {:ok, pid} = Etlien.Persist.start_link
    on_exit fn -> Process.exit(pid, :kill) end
    :ok
  end

  test "can put a chunk somewhere and send a ref to the next stage" do
    chunk = [["a chunk"]]
    {:ok, ref} = %Transformed{
      expr: Applicator.identity,
      original_header: ["foo"],
      original_chunk_hash: Persist.chunk_hash(chunk),
      result_header: ["foo"],
      result_chunk: chunk
    }
    |> Persist.put
    assert ref == "AF5223E3EA5335CDE787D5604F5531831CA254668EAFA765FA9408044DFBA76E"
  end

  test "can put a chunk somewhere and get it" do
    chunk = [["a chunk"]]


    {:ok, ref} = %Transformed{
      expr: Applicator.identity,
      original_header: ["foo"],
      original_chunk_hash: Persist.chunk_hash(chunk),
      result_header: ["foo"],
      result_chunk: chunk
    }
    |> Persist.put

    {:ok, item} = Persist.get(ref)
    assert item == %Transformed{
      expr: Applicator.identity,
      original_header: ["foo"],
      original_chunk_hash: Persist.chunk_hash(chunk),
      result_header: ["foo"],
      result_chunk: chunk
    }
  end

end
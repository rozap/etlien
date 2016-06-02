defmodule Etlien.Transformed do
  defstruct expr: nil,
    original_header: [],
    original_chunk_hash: nil,
    result_header: [],
    result_chunk:  [],
    result_errors: []
end
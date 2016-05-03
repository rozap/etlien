defmodule Etlien.Transformed do
  defstruct expr: nil, 
    seq_num: 0, 
    original_header: [], 
    original_chunk_hash: nil,
    result_header: [],
    result_chunk:  [],
    result_errors: []
end
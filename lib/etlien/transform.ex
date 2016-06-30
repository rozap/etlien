defmodule Etlien.Transform do
  alias Etlien.Transform.Applicator
  alias Etlien.Persist

  defmodule Transformation do
    defstruct expr: nil,
      original_header: [],
      original_chunk_hash: nil,
      result_header: [],
      result_chunk:  [],
      result_errors: []
  end

  def identity(header, chunk) do
    %Etlien.Transform.Transformation{
      expr: Applicator.identity,
      original_header: header,
      result_header: header,
      original_chunk_hash: Persist.chunk_hash(chunk),
      result_chunk: chunk
    }
  end
end
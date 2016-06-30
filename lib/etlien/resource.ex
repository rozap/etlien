defmodule Etlien.Resource do
  use Behaviour

  @type header :: []
  @type row :: []
  @type chunk :: [row]

  defmodule State do
    defstruct header: [],
      row: 0,
      column: 0,
      buf: "",
      prev: [],
      offset: 0,
      meta: %{}
  end

  @callback init(opts :: []) :: State.t
  @callback on_bytes(bs :: Bitstring, state :: State.t) :: {chunk, State.t}

  def transform(stream, module, opts \\ []) do
    Stream.transform(stream, module.init(opts), fn bytes, state ->
      state = struct(state, offset: state.offset + String.length(bytes))
      module.on_bytes(bytes, state)
    end)
  end


  @kinds %{
    "csv" => Etlien.Resource.Csv
  }

  Enum.each(@kinds, fn {kind, module} ->
    def compose(stream, unquote(kind)) do
      transform(stream, unquote(module))
    end
  end)

end
defmodule Etlien.Resource do
  @type header :: []
  @type row :: []
  @type chunk :: [row]
  @type datum :: {header, chunk}
  @type resource_state :: %{}

  @callback init([]) :: resource_state
  @callback feed(String.t) :: {resource_state, datum}
end
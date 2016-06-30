ExUnit.start

Ecto.Adapters.SQL.Sandbox.mode(Etlien.Repo, :manual)

defmodule TestHelper do
  def fixture!(name) do
    __DIR__
    |> Path.join(["fixtures", name])
    |> File.stream!([:read], 256)
  end
end
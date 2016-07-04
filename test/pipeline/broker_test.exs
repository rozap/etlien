defmodule BrokerTest do
  use ExUnit.Case, async: false
  alias Etlien.Group
  import TestHelper

  alias Etlien.{Repo, Broker, Set, Ref, Resource, Persist}
  alias Etlien.Transform.Chunker
  alias Etlien.Resource.Csv



  setup do
    # https://hexdocs.pm/ecto/Ecto.Adapters.SQL.Sandbox.html for reference
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  setup_all do
    {:ok, pid} = Etlien.Persist.start_link
    on_exit fn -> Process.exit(pid, :kill) end
    :ok
  end

  test "can get some chunks from a flat resource" do
    group = Repo.insert!(%Group{
      name: "goober"
    })

    Broker.subscribe(group)

    fixture!("/csv/weather.csv")
    |> Resource.transform(Csv)
    |> Chunker.unflatten(group)
    |> Chunker.chunk(group)
    |> Chunker.emit!(group)
    |> Stream.run

    receive do
      {:ref_notify, {_, _, %Ref{ref: ref}}} ->
        # IO.inspect message
        IO.puts ref
        Persist.get(ref) |> IO.inspect
    end

  end


end
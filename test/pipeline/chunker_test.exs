defmodule ChunkerTest do
  use ExUnit.Case, async: false
  alias Etlien.Group

  alias Etlien.Repo
  alias Etlien.Set
  alias Etlien.Transform.Chunker


  setup do
    # https://hexdocs.pm/ecto/Ecto.Adapters.SQL.Sandbox.html for reference
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  setup_all do
    {:ok, pid} = Etlien.Persist.start_link
    on_exit fn -> Process.exit(pid, :kill) end
    :ok
  end

  test "can unflatten a single chunk stream" do
    group = Repo.insert!(%Group{
      name: "goober"
    })

    header = ["foo", "bar"]

    result = [
      {header, ["im a foo1", "im a bar1"]},
      {header, ["im a foo2", "im a bar2"]},
      {header, ["im a foo3", "im a bar3"]}
    ]
    |> Stream.map(fn i -> i end)
    |> Chunker.unflatten(group)
    |> Enum.into([])

    assert [{
      %Set{columns: %{names: ["foo", "bar"]}},
      ["im a foo1", "im a bar1"]
    },
    {
      %Set{columns: %{names: ["foo", "bar"]}},
      ["im a foo2", "im a bar2"]
    },
    {
      %Set{columns: %{names: ["foo", "bar"]}},
      ["im a foo3", "im a bar3"]
    }] = result
  end

  test "can unflatten a multi chunk stream" do
    group = Repo.insert!(%Group{
      name: "goober"
    })

    header = ["foo", "bar"]
    other = ["foo", "qux"]

    result = [
      {header, ["im a foo1", "im a bar1"]},
      {other, ["im a foo2", "im a qux"]},
      {header, ["im a foo3", "im a bar3"]}
    ]
    |> Stream.map(fn i -> i end)
    |> Chunker.unflatten(group)
    |> Enum.into([])

    assert [{
      %Set{columns: %{names: ["foo", "bar"]}},
      ["im a foo1", "im a bar1"]
    },
    {
      %Set{columns: %{names: ["foo", "qux"]}},
      ["im a foo2", "im a qux"]
    },
    {
      %Set{columns: %{names: ["foo", "bar"]}},
      ["im a foo3", "im a bar3"]
    }] = result
  end

  test "can chunk a single stream" do
    group = Repo.insert!(%Group{
      name: "goober"
    })

    header = ["foo", "bar"]
    result = [
      {header, ["im a foo1", "im a bar1"]},
      {header, ["im a foo2", "im a bar2"]},
      {header, ["im a foo3", "im a bar3"]}
    ]
    |> Stream.map(fn i -> i end)
    |> Chunker.unflatten(group)
    |> Chunker.chunk(group)
    |> Enum.into([])

    assert [{
      %Set{columns: %{names: ["foo", "bar"]}},
      [
        ["im a foo3", "im a bar3"],
        ["im a foo2", "im a bar2"],
        ["im a foo1", "im a bar1"]]}] = result
  end

  test "can chunk a double stream" do
    group = Repo.insert!(%Group{
      name: "goober"
    })

    header = ["foo", "bar"]
    other = ["foo", "qux"]

    result = [
      {header, ["im a foo1", "im a bar1"]},
      {other, ["im a foo2", "im a qux"]},
      {header, ["im a foo3", "im a bar3"]}
    ]
    |> Stream.map(fn i -> i end)
    |> Chunker.unflatten(group)
    |> Chunker.chunk(group)
    |> Enum.into([])

    assert [{
      %Set{columns: %{names: ["foo", "bar"]}},
      [
        ["im a foo3", "im a bar3"],
        ["im a foo1", "im a bar1"]
      ]
    }, {
      %Set{columns: %{names: ["foo", "qux"]}},
      [["im a foo2", "im a qux"]]
    }] = result
  end


end
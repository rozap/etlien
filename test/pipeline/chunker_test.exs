defmodule ChunkerTest do
  use ExUnit.Case, async: false
  alias Etlien.Group
  alias Etlien.Set
  alias Etlien.Broker

  alias Etlien.Repo
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

  test "can unflatten a single chunk type" do
    columns = %{
      names: ["foo", "bar"],
      types: [:string, :string]
    }


    group = Repo.insert!(%Group{
      name: "goober"
    })

    Broker.subscribe(group)

    Chunker.unflatten(
      group,
      [
        ["im a foo1", "im a bar1"],
        ["im a foo2", "im a bar2"],
        ["im a foo3", "im a bar3"]
      ]
    )
    |> Stream.run

    expected_hash = "91D2BC80317695AA0D6365E1BE76758BB1B41B947C0245BE0A743FA3199C4CCF"

    # receive do
    #   {:ref_notify, ^group, ^set, ref} ->
    #     assert ref.ref == expected_hash
    # after 200 ->
    #   :error
    # end


  end


end
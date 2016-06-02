defmodule BrokerTest do
  use ExUnit.Case, async: false
  alias Etlien.Persist
  alias Etlien.Transform.Applicator
  alias Etlien.Transformed

  setup_all do
    {:ok, pid} = Etlien.Persist.start_link
    # {:ok, broker} = Etlien..start_link

    on_exit fn ->
      # Process.exit(broker, :kill)
      Process.exit(pid, :kill)
    end
    :ok
  end

  test "will add a stream of chunks to expr_reflog" do

  end


end
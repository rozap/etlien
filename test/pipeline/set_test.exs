defmodule SetTest do
  use ExUnit.Case, async: false
  alias Etlien.Persist
  alias Etlien.Transform.Applicator
  alias Etlien.Transformed

  setup_all do
    {:ok, pid} = Etlien.Transform.Set.start_link
    on_exit fn -> Process.exit(pid, :kill) end
    :ok
  end

  test "given a job and a datum, stores the stuff in persist" do

  end


end
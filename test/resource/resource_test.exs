defmodule ResourceTest do
  use ExUnit.Case, async: true
  import TestHelper

  alias Etlien.Resource

  test "can stream a csv resource" do
    actual = fixture!("/csv/weather.csv")
    |> Resource.compose("csv")
  end

end
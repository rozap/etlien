defmodule CsvTest do
  use ExUnit.Case, async: true
  import TestHelper

  alias Etlien.Resource.Csv
  alias Etlien.Resource

  test "can turn some bytes into terms" do
    actual = fixture!("/csv/weather.csv")
    |> Resource.transform(Csv)
    |> Enum.into([])

    expected = [
      {["StationName", "StationLocation", "DateTime", "RecordId",
        "RoadSurfaceTemperature", "AirTemperature"],
       ["35thAveSW_SWMyrtleSt", "(4\n7.53918, -122.37658)", "03/03/2014 12:42:00 PM",
        "672560", "53.88", "53.88"]},
      {["StationName", "StationLocation", "DateTime", "RecordId",
        "RoadSurfaceTemperature", "AirTemperature"],
       ["35thAveSW_SWMyrtleSt", "(47.53918, -122.37658)", "03/03/2014 12:43:00 PM",
        "672561", "54.05", "54.05"]},
      {["StationName", "StationLocation", "DateTime", "RecordId",
        "RoadSurfaceTemperature", "AirTemperature"],
       ["35thAveSW_SWMyrtleSt", "(47.53918, -\n\n122.37658)",
        "03/03/2014 12:44:00 PM", "672562", "54.21", "54.21"]}
      ]

      assert actual == expected
  end

end
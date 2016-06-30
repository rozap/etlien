defmodule ApiTest.TestGroup do
  use Etlien.ConnCase
  alias Etlien.Group
  import TestHelper

  @headers [{"Content-Type", "application/json"}]

  def api_conn do
    build_conn()
    |> put_req_header("accept", "application/json")
    |> put_req_header("content-type", "application/ldjson")
  end

  test "POST chunks to /group/:id/chunk" do
    group = Repo.insert!(%Group{
      name: "goober",
      resource_type: "csv"
    })


    upload = fixture!("/csv/police.csv") |> Enum.into("")

    conn = post(api_conn(), "/api/group/#{group.id}/chunk", upload)
    assert json_response(conn, 201) =~ "thx"
  end
end
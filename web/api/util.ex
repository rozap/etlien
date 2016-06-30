defmodule Etlien.Api.Util do
  import Plug.Conn
  def json(conn, status, payload) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, Poison.encode!(payload))
  end
end
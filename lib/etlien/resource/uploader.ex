defmodule Etlien.Resource.Uploader do
  import Plug.Conn

  def stream!(conn) do
    chunk_size = Application.get_env(:etlien, :api)[:chunk_size_bytes]
    Stream.resource(
      fn -> read_body(conn, read_length: chunk_size) end,
      fn
        {:error, _}        -> {:halt, conn}
        {:done, conn}      -> {:halt, conn}
        {:ok, bin, conn}   -> {[bin], {:done, conn}}
        {:more, bin, conn} -> {[bin], read_body(conn, read_length: chunk_size)}
      end,
      fn conn -> conn end
    )
  end
end
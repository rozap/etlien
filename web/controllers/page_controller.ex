defmodule Etlien.PageController do
  use Etlien.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end

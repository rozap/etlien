defmodule Etlien.Api.Group.Append do
  import Plug.Conn
  import Ecto.Query
  import Etlien.Api.Util
  alias Etlien.{Group, Repo}
  alias Etlien.Resource

  def init(args), do: args


  def call(conn, args) do
    group_id = String.to_integer(conn.params["group_id"])
    case Repo.one(from g in Group,
      where: g.id == ^group_id,
      preload: [:sets]
    ) do
      nil -> json(conn, 404, "nope")
      group ->
        conn
        |> Resource.Uploader.stream!
        |> Resource.compose(group.resource_type)

        json(conn, 201, "thx")
    end
  end

end
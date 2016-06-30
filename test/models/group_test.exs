defmodule Etlien.GroupTest do
  use Etlien.ModelCase

  # alias Etlien.Group

  @valid_attrs %{description: "some content", name: "some content", schemas: %{}, uuid: "7488a646-e31f-11e4-aace-600308960662"}
  @invalid_attrs %{}

  # test "changeset with valid attributes" do
  #   changeset = Group.changeset(%Group{}, @valid_attrs)
  #   assert changeset.valid?
  # end

  # test "changeset with invalid attributes" do
  #   changeset = Group.changeset(%Group{}, @invalid_attrs)
  #   refute changeset.valid?
  # end
end

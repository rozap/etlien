defmodule Etlien.ExprTest do
  use Etlien.ModelCase

  alias Etlien.Expr

  @valid_attrs %{name: "some content", source: %{}}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Expr.changeset(%Expr{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Expr.changeset(%Expr{}, @invalid_attrs)
    refute changeset.valid?
  end
end

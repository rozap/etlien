defmodule Etlien.JobTest do
  use Etlien.ModelCase

  alias Etlien.Job

  @valid_attrs %{description: "some content", name: "some content", schemas: %{}, uuid: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Job.changeset(%Job{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Job.changeset(%Job{}, @invalid_attrs)
    refute changeset.valid?
  end
end

defmodule Etlien.Group do
  use Etlien.Web, :model

  schema "groups" do
    field :uuid, Ecto.UUID
    field :name, :string
    field :description, :string
    field :schemas, :map

    timestamps
  end

  @required_fields ~w(uuid name description schemas)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end

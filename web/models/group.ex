defmodule Etlien.Group do
  use Etlien.Web, :model
  alias Etlien.Set

  schema "groups" do
    field :uuid, Ecto.UUID
    field :name, :string
    field :description, :string
    field :resource_type, :string
    has_many :sets, Set
    timestamps
  end

  @required_fields ~w(uuid name description sets resource_type)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end

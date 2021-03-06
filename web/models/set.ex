defmodule Etlien.Set do
  use Etlien.Web, :model

  schema "sets" do
    field :columns, :map
    belongs_to :group, Etlien.Group

    timestamps
  end

  @required_fields ~w(columns)
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

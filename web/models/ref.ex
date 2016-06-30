defmodule Etlien.Ref do
  use Etlien.Web, :model

  schema "refs" do
    field :ref, :string
    belongs_to :set, Etlien.Set

    timestamps
  end

  @required_fields ~w(ref)
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

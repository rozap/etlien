defmodule Etlien.Repo.Migrations.CreateRef do
  use Ecto.Migration

  def change do
    create table(:refs) do
      add :ref, :string
      add :set_id, references(:sets, on_delete: :nothing)

      timestamps
    end
    create index(:refs, [:set_id])

  end
end

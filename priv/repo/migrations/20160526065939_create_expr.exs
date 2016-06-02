defmodule Etlien.Repo.Migrations.CreateExpr do
  use Ecto.Migration

  def change do
    create table(:exprs) do
      add :name, :string
      add :source, :map
      add :group_id, references(:groups, on_delete: :nothing)

      timestamps
    end
    create index(:exprs, [:group_id])

  end
end

defmodule Etlien.Repo.Migrations.CreateSet do
  use Ecto.Migration

  def change do
    create table(:sets) do
      add :columns, :map
      add :group_id, references(:groups, on_delete: :nothing)

      timestamps
    end
    create index(:sets, [:group_id])

  end
end

defmodule Etlien.Repo.Migrations.CreateGroup do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :uuid, :uuid
      add :name, :string
      add :description, :string
      add :schemas, :map

      timestamps
    end

  end
end

defmodule Etlien.Repo.Migrations.AddGroupResourceType do
  use Ecto.Migration

  def change do
    alter table(:groups) do
      add :resource_type, :text
    end
  end
end

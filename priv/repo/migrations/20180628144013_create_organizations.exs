defmodule Dummy.Repo.Migrations.CreateOrganizations do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS ltree" # Enables Ltree action

    create table(:organizations) do
      add :name, :string
      add :ancestry, :ltree
    end

    create index(:organizations, [:ancestry], using: "GIST")
  end
end

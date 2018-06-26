defmodule Dummy.Repo.Migrations.CreateCatelogs do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION ltree" # Enables Ltree action

    create table(:catelogs, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string
      add :path, :ltree, null: false

      timestamps()
    end

    create index(:catelogs, [:path], using: "GIST")
  end
end

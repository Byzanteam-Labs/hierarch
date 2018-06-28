defmodule Dummy.Organization do
  @moduledoc false
  use Ecto.Schema
  use Hierarch, path_column: :ancestry

  schema "organizations" do
    field :name, :string
    field :ancestry, Hierarch.Ecto.LTree
  end
end

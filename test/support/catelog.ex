defmodule Dummy.Catelog do
  @moduledoc false
  use Ecto.Schema
  use Hierarch

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "catelogs" do
    field :name, :string
    field :path, Hierarch.Ecto.UUIDLTree

    timestamps()
  end
end

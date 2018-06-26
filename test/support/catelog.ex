defmodule Dummy.Catelog do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "catelogs" do
    field :name, :string
    field :path, Hierarch.Ecto.LTree

    timestamps()
  end
end

defmodule Hierarch do
  @moduledoc """
  Using `Hierarch` will add hierarchical functions to your Ecto model.

  ## Examples

      defmodule Catelog do
        @moduledoc false
        use Ecto.Schema
        use Hierarch

        @primary_key {:id, :binary_id, autogenerate: true}

        schema "catelogs" do
          field :name, :string
          field :path, Hierarch.Ecto.LTree

          timestamps()
        end
      end
  """

  defmacro __using__(opts) do
    quote do
      import unquote(__MODULE__)
      @column_name Keyword.get(unquote(opts), :column_name, "path")
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(%{module: definition}) do
    column_name = Module.get_attribute(definition, :column_name)

    quote bind_quoted: [
      column_name: column_name,
      definition: definition
    ] do
      import Ecto.Query
      alias Hierarch.LTree

      @doc """
      Return query expressions for the parent
      """
      def parent(%{unquote(:"#{column_name}") => %LTree{labels: labels}, __struct__: __MODULE__}) when length(labels) <= 1 do
        from(
          t in unquote(definition),
          where: fragment("1 = 0")
        )
      end
      def parent(schema = %{__struct__: __MODULE__}) do
        parent_labels = schema
                        |> get_ltree_value()
                        |> LTree.parent()
                        |> LTree.dump()

        from(
          t in unquote(definition),
          where: fragment("path = ?", ^parent_labels)
        )
      end

      defp get_ltree_value(schema) do
        Map.get(schema, unquote(:"#{column_name}"))
      end
    end
  end
end

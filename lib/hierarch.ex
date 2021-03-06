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
          field :path, Hierarch.Ecto.UUIDLTree

          timestamps()
        end
      end
  """

  defmacro __using__(opts) do
    path_column = Keyword.get(opts, :path_column, :path)

    quote do
      def __hierarch__(:path_column) do
        unquote(path_column)
      end

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(%{module: schema}) do
    quote do
      # queries
      defdelegate ancestors(struct, opts \\ []), to: Hierarch.Query.Ancestors, as: :query
      defdelegate children(struct, opts \\ []), to: Hierarch.Query.Children, as: :query
      defdelegate descendants(struct, opts \\ []), to: Hierarch.Query.Descendants, as: :query
      defdelegate parent(struct), to: Hierarch.Query.Parent, as: :query
      defdelegate root(struct), to: Hierarch.Query.Root, as: :query

      def roots do
        Hierarch.Query.Roots.query(unquote(schema))
      end

      defdelegate siblings(struct, opts \\ []), to: Hierarch.Query.Siblings, as: :query

      # utils
      defdelegate is_root?(struct), to: Hierarch.Util
      defdelegate build_child_of(struct, attrs \\ %{}), to: Hierarch.Util

      def build(attrs) do
        Hierarch.Util.build(unquote(schema), attrs)
      end
    end
  end
end

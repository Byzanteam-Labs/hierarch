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
    quote do
      import unquote(__MODULE__)
      @path_column Keyword.get(unquote(opts), :path_column, :path)
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(%{module: table}) do
    path_column = Module.get_attribute(table, :path_column)

    quote bind_quoted: [
      path_column: path_column,
      table: table
    ] do
      import Ecto.Query
      alias Hierarch.LTree

      schema_argument = quote do: %{unquote(path_column) => path, __struct__: __MODULE__}

      @doc """
      Return query expressions for the parent
      """
      def parent(schema = unquote(schema_argument)) do
        parent_id = LTree.parent_id(path)

        if is_nil(parent_id) do
          blank_query()
        else
          {id_column, _, _} = @primary_key

          from(
            t in unquote(table),
            where: ^[{id_column, parent_id}]
          )
        end
      end

      @doc """
      Return query expressions for the root
      """
      def root(schema = unquote(schema_argument)) do
        {id_column, id} = get_primary_key(schema)
        root_id = LTree.root_id(path, id)

        from(
          t in unquote(table),
          where: ^[{id_column, root_id}]
        )
      end

      @doc """
      Return query expressions for ancestors

      ## Options

        * `:with_self` - when true to include itself. Defaults to false.
      """
      def ancestors(schema = unquote(schema_argument), opts \\ [with_self: false]) do
        {id_column, id} = get_primary_key(schema)

        ancestor_ids =
          case opts[:with_self] do
            true -> LTree.split(path) ++ [id]
            _ -> LTree.split(path)
          end

        if Enum.empty?(ancestor_ids) do
          blank_query()
        else
          from(
            t in unquote(table),
            where: field(t, ^id_column) in ^ancestor_ids
          )
        end
      end

      @doc """
      Return query expressions for children
      ## Options

        * `:with_self` - when true to include itself. Defaults to false.
      """
      def children(schema = unquote(schema_argument), opts \\ [with_self: false]) do
        {id_column, id} = get_primary_key(schema)

        children_path = LTree.concat(path, id)

        children = unquote(table)
                   |> where([t], field(t, ^unquote(path_column)) == ^children_path)

        case opts[:with_self] do
          true -> children |> or_where([t], field(t, ^id_column) == ^id)
          _ -> children
        end
      end

      @doc """
      Return query expressions for discendants

      ## Options

        * `:with_self` - when true to include itself. Defaults to false.
      """
      def discendants(schema = unquote(schema_argument), opts \\ [with_self: false]) do
        {id_column, id} = get_primary_key(schema)

        discendants_path = LTree.concat(path, id)

        discendants =
          unquote(table)
          |> where([t], fragment("? <@ ?", field(t, ^unquote(path_column)), type(^discendants_path, field(t, unquote(path_column)))))

        case opts[:with_self] do
          true -> discendants |> or_where([t], field(t, ^id_column) == ^id)
          _ -> discendants
        end
      end

      @doc """
      Return query expressions for siblings

      ## Options

        * `:with_self` - when true to include itself. Defaults to false.
      """
      def siblings(schema = unquote(schema_argument), opts \\ [with_self: false]) do
        {id_column, id} = get_primary_key(schema)
        parent_path = path

        siblings_with_self =
          unquote(table)
          |> where([t], field(t, ^unquote(path_column)) == ^parent_path)

        case opts[:with_self] do
          true ->
            siblings_with_self
          _ ->
            siblings_with_self
            |> 
            where([t], field(t, ^id_column) != ^id)
        end
      end

      @doc """
      Return query expressions for roots
      """
      def roots do
        roots_path = ""

        from(
          t in unquote(table),
          where: field(t, ^unquote(path_column)) == ^roots_path
        )
      end

      @doc """
      Return true if the node is root
      """
      def is_root?(%{unquote(:"#{path_column}") => nil, __struct__: __MODULE__}), do: true
      def is_root?(%{unquote(:"#{path_column}") => "", __struct__: __MODULE__}), do: true
      def is_root?(%{__struct__: __MODULE__}), do: false

      @doc """
      Build child of a node
      """
      def build_child_of(schema, attrs \\ %{})
      def build_child_of(schema = unquote(schema_argument), attrs) do
        {_, id} = get_primary_key(schema)

        path = LTree.concat(path, to_string(id))
        schema_attrs = Map.put(attrs, unquote(path_column), path)
        struct(__MODULE__, schema_attrs)
      end
      # Build the root
      def build_child_of(_, attrs) do
        schema_attrs = Map.put(attrs, unquote(path_column), "")
        struct(__MODULE__, schema_attrs)
      end

      defp blank_query do
        from(
          t in unquote(table),
          where: fragment("1 = 0")
        )
      end

      defp get_primary_key(schema) do
        [{id_column, value}] = Ecto.primary_key(schema)
        {id_column, to_string(value)}
      end
    end
  end
end

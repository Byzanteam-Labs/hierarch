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
      def parent(%{unquote(:"#{column_name}") => %LTree{labels: labels}, __struct__: __MODULE__}) when length(labels) <= 1, do: blank_query()
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

      @doc """
      Return query expressions for ancestors

      ## Options

        * `:with_self` - when true to include itself. Defaults to false.
      """
      def ancestors(schema = %{unquote(:"#{column_name}") => %LTree{labels: labels}, __struct__: __MODULE__}, opts \\ [with_self: false]) do
        parent_labels =
          case {length(labels), opts[:with_self]} do
            {_, true} ->
              schema
              |> get_ltree_value()
              |> LTree.dump()
            {1, false} ->
              nil
            _ ->
              schema
              |> get_ltree_value()
              |> LTree.parent()
              |> LTree.dump()
          end

        if parent_labels do
          from(
            t in unquote(definition),
            where: fragment("path @> ?", ^parent_labels)
          )
        else
          blank_query()
        end
      end

      @doc """
      Return query expressions for children
      ## Options

        * `:with_self` - when true to include itself. Defaults to false.
      """
      def children(schema = %{__struct__: __MODULE__}, opts \\ [with_self: false]) do
        labels = schema
                 |> get_ltree_value()
                 |> LTree.dump()

        children_labels =
          case opts[:with_self] do
            true -> labels <> ".*{,1}"
            _ -> labels <> ".*{1}"
          end

        from(
          t in unquote(definition),
          where: fragment("path ~ ?", ^children_labels)
        )
      end

      @doc """
      Return query expressions for discendants

      ## Options

        * `:with_self` - when true to include itself. Defaults to false.
      """
      def discendants(schema = %{unquote(:"#{column_name}") => %LTree{labels: labels}, __struct__: __MODULE__}, opts \\ [with_self: false]) do
        labels = schema
                 |> get_ltree_value()
                 |> LTree.dump()

        discendants_labels =
          case opts[:with_self] do
            true -> labels <> ".*{0,}"
            _ -> labels <> ".*{1,}"
          end

        from(
          t in unquote(definition),
          where: fragment("path ~ ?", ^discendants_labels)
        )
      end

      @doc """
      Return query expressions for sblings

      ## Options

        * `:with_self` - when true to include itself. Defaults to false.
      """
      def sblings(schema = %{__struct__: __MODULE__}, opts \\ [with_self: false]) do
        parent_labels = schema
                        |> get_ltree_value()
                        |> LTree.parent()
                        |> LTree.dump()

        sblings_labels = parent_labels <> ".*{1}"

        if opts[:with_self] do
          from(
            t in unquote(definition),
            where: fragment("path ~ ?", ^sblings_labels)
          )
        else
          itself_labels = schema
                          |> get_ltree_value()
                          |> LTree.dump()
          from(
            t in unquote(definition),
            where: fragment("path ~ ?", ^sblings_labels),
            where: fragment("path <> ?", ^itself_labels)
          )
        end
      end

      @doc """
      Return query expressions for roots
      """
      def roots do
        from(
          t in unquote(definition),
          where: fragment("path ~ ?", "*{1}")
        )
      end

      defp get_ltree_value(schema) do
        Map.get(schema, unquote(:"#{column_name}"))
      end

      defp blank_query do
        from(
          t in unquote(definition),
          where: fragment("1 = 0")
        )
      end
    end
  end
end

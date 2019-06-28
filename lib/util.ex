defmodule Hierarch.Util do
  def struct_path(%schema{} = struct) do
    Map.get(struct, schema.__hierarch__(:path_column))
  end

  @doc """
  Return true if the struct is root
  """
  def is_root?(%_schema{} = struct) do
    case struct_path(struct) do
      nil -> true
      "" -> true
      _ -> false
    end
  end

  @doc """
  Build child of a struct
  """
  def build_child_of(%schema{} = struct, attrs \\ %{}) do
    parent_path = struct_path(struct)
    [{_pk_column, value}] = Ecto.primary_key(struct)

    path = Hierarch.LTree.concat(parent_path, to_string(value))

    struct_attrs = Map.put(attrs, schema.__hierarch__(:path_column), path)
    struct(schema, struct_attrs)
  end

  @doc """
  Build a struct
  """
  def build(schema, attrs) do
    struct_attrs = Map.put(attrs, schema.__hierarch__(:path_column), "")
    struct(schema, struct_attrs)
  end
end

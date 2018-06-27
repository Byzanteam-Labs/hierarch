defmodule HierarchTest do
  use Hierarch.TestCase, async: true

  doctest Hierarch

  setup_all do
    catelogs = create_catelogs()
    {:ok, catelogs}
  end

  describe "parent/1" do
    test "returns its parent", catelogs do
      science = Map.get(catelogs, "Science")
      top     = Map.get(catelogs, "Top")

      parent = science
               |> Catelog.parent
               |> Repo.one
      assert parent == top
    end

    test "returns nil if it is the root", catelogs do
      top = Map.get(catelogs, "Top")

      parent = top
               |> Catelog.parent
               |> Repo.one
      assert is_nil(parent)
    end
  end
end

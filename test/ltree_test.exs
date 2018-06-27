defmodule Hierarch.LtreeTest do
  use ExUnit.Case, async: true
  alias Hierarch.LTree

  doctest LTree

  describe "cast" do
    test "parses with bianry" do
      assert LTree.cast("Top.Science") == %LTree{labels: ["Top", "Science"]}
    end

    test "parses with list" do
      assert LTree.cast(["Top", "Science"]) == %LTree{labels: ["Top", "Science"]}
    end

    test "removes blank string item" do
      assert LTree.cast("") == %LTree{labels: []}
    end

    test "falis with wrong value" do
      assert LTree.cast(nil) == :error
    end
  end

  describe "dump" do
    test "dump to string" do
      assert LTree.dump(%LTree{labels: ["Top", "Science"]}) == "Top.Science"
    end
  end

  describe "parent" do
    test "returns parent ltree" do
      ltree = %LTree{labels: ["Top", "Science"]}
      parent = LTree.parent(ltree)

      assert parent.labels == ["Top"]
    end
  end
end

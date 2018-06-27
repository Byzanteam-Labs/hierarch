defmodule HierarchTest do
  use ExUnit.Case

  doctest Hierarch

  alias Dummy.Catelog

  describe "is_root?/1" do
    test "returns true if it is root" do
      labels_str = "Top"
      catelog = %Catelog{name: labels_str, path: Hierarch.LTree.cast(labels_str)}
      assert Catelog.is_root?(catelog)
    end

    test "returns false if it isnt root" do
      labels_str = "Top.Science"
      catelog = %Catelog{name: labels_str, path: Hierarch.LTree.cast(labels_str)}
      refute Catelog.is_root?(catelog)
    end
  end
end

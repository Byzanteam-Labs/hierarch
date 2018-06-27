defmodule HierarchTest do
  use Hierarch.TestCase

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

  describe "build_child_of/2" do
    test "builds a child" do
      parent = %Catelog{name: "Top", path: Hierarch.LTree.cast("")} |> Repo.insert!
      catelog = Catelog.build_child_of(parent, %{name: "Top.Science"})

      assert catelog.path.labels == [parent.id]
    end
  end
end

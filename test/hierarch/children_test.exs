defmodule Hierarch.ChildrenTest do
  use Hierarch.TestCase

  setup_all do
    catelogs = create_catelogs()

    on_exit fn ->
      Repo.delete_all(Catelog)
    end

    {:ok, catelogs}
  end

  describe "children/2" do
    test "returns its children", catelogs do
      science   = Map.get(catelogs, "Top.Science")
      astronomy = Map.get(catelogs, "Top.Science.Astronomy")

      children = science
                 |> Catelog.children
                 |> Repo.all
      assert children == [astronomy]
    end

    test "returns blank array if it is the leaf", catelogs do
      cosmology = Map.get(catelogs, "Top.Science.Astronomy.Cosmology")

      children = cosmology
                 |> Catelog.children
                 |> Repo.all
      assert children == []
    end
  end

  describe "children/2 with_self" do
    test "returns its children and itself when with_self is true", catelogs do
      science   = Map.get(catelogs, "Top.Science")
      astronomy = Map.get(catelogs, "Top.Science.Astronomy")

      children = science
                 |> Catelog.children(with_self: true)
                 |> Repo.all
      assert_match children, [science, astronomy]
    end

    test "returns its children when with_self is false", catelogs do
      science   = Map.get(catelogs, "Top.Science")
      astronomy = Map.get(catelogs, "Top.Science.Astronomy")

      children = science
                 |> Catelog.children(with_self: false)
                 |> Repo.all
      assert children == [astronomy]
    end
  end
end

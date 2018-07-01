defmodule Hierarch.ParentTest do
  use Hierarch.TestCase

  setup_all do
    Repo.delete_all(Catelog)
    catelogs = create_catelogs()

    on_exit fn ->
      Repo.delete_all(Catelog)
    end

    {:ok, catelogs}
  end

  describe "parent/1" do
    test "returns its parent", catelogs do
      science = Map.get(catelogs, "Top.Science")
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

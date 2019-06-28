defmodule Hierarch.RootTest do
  use Hierarch.TestCase

  setup_all do
    Repo.delete_all(Catelog)
    catelogs = create_catelogs()

    on_exit(fn ->
      Repo.delete_all(Catelog)
    end)

    {:ok, catelogs}
  end

  describe "root/1" do
    test "returns its root", catelogs do
      science = Map.get(catelogs, "Top.Science")
      top = Map.get(catelogs, "Top")

      root =
        science
        |> Catelog.root()
        |> Repo.one()

      assert root == top
    end

    test "returns itself if it is the root", catelogs do
      top = Map.get(catelogs, "Top")

      root =
        top
        |> Catelog.root()
        |> Repo.one()

      assert root == top
    end
  end
end

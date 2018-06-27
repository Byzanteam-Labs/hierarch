defmodule Hierarch.AncestorsTest do
  use Hierarch.TestCase

  setup_all do
    catelogs = create_catelogs()

    on_exit fn ->
      Repo.delete_all(Catelog)
    end

    {:ok, catelogs}
  end

  describe "ancestors/1" do
    test "returns its ancestors", catelogs do
      top       = Map.get(catelogs, "Top")
      science   = Map.get(catelogs, "Top.Science")
      astronomy = Map.get(catelogs, "Top.Science.Astronomy")

      ancestors = astronomy
                  |> Catelog.ancestors
                  |> Repo.all
      assert ancestors == [top, science]
    end

    test "returns blank array if it is the root", catelogs do
      top = Map.get(catelogs, "Top")

      ancestors = top
                  |> Catelog.ancestors
                  |> Repo.all
      assert ancestors == []
    end
  end

  describe "ancestors_and_self/1" do
    test "returns its ancestors and itself", catelogs do
      top       = Map.get(catelogs, "Top")
      science   = Map.get(catelogs, "Top.Science")
      astronomy = Map.get(catelogs, "Top.Science.Astronomy")

      ancestors = astronomy
                  |> Catelog.ancestors_and_self
                  |> Repo.all
      assert ancestors == [top, science, astronomy]
    end

    test "returns itself if it is the root", catelogs do
      top = Map.get(catelogs, "Top")

      ancestors = top
                  |> Catelog.ancestors_and_self
                  |> Repo.all
      assert ancestors == [top]
    end
  end
end

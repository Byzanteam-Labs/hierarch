defmodule Hierarch.SblingsTest do
  use Hierarch.TestCase

  setup_all do
    catelogs = create_catelogs()

    on_exit fn ->
      Repo.delete_all(Catelog)
    end

    {:ok, catelogs}
  end

  describe "sblings/2" do
    test "returns its sblings", catelogs do
      science     = Map.get(catelogs, "Top.Science")
      hobbies     = Map.get(catelogs, "Top.Hobbies")
      collections = Map.get(catelogs, "Top.Collections")

      sblings = science
                |> Catelog.sblings
                |> Repo.all
      assert sblings == [hobbies, collections]
    end
  end

  describe "sblings/2 with_self" do
    test "returns its sblings and itself when with_self is true", catelogs do
      science     = Map.get(catelogs, "Top.Science")
      hobbies     = Map.get(catelogs, "Top.Hobbies")
      collections = Map.get(catelogs, "Top.Collections")

      sblings = science
                |> Catelog.sblings(with_self: true)
                |> Repo.all
      assert sblings == [science, hobbies, collections]
    end

    test "returns its sblings when with_self is false", catelogs do
      science     = Map.get(catelogs, "Top.Science")
      hobbies     = Map.get(catelogs, "Top.Hobbies")
      collections = Map.get(catelogs, "Top.Collections")

      sblings = science
                |> Catelog.sblings(with_self: false)
                |> Repo.all
      assert sblings == [hobbies, collections]
    end
  end
end

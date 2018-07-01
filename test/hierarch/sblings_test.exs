defmodule Hierarch.SiblingsTest do
  use Hierarch.TestCase

  setup_all do
    catelogs = create_catelogs()

    on_exit fn ->
      Repo.delete_all(Catelog)
    end

    {:ok, catelogs}
  end

  describe "siblings/2" do
    test "returns its siblings", catelogs do
      science     = Map.get(catelogs, "Top.Science")
      hobbies     = Map.get(catelogs, "Top.Hobbies")
      collections = Map.get(catelogs, "Top.Collections")

      siblings = science
                 |> Catelog.siblings
                 |> Repo.all
      assert siblings == [hobbies, collections]
    end
  end

  describe "siblings/2 with_self" do
    test "returns its siblings and itself when with_self is true", catelogs do
      science     = Map.get(catelogs, "Top.Science")
      hobbies     = Map.get(catelogs, "Top.Hobbies")
      collections = Map.get(catelogs, "Top.Collections")

      siblings = science
                 |> Catelog.siblings(with_self: true)
                 |> Repo.all
      assert siblings == [science, hobbies, collections]
    end

    test "returns its siblings when with_self is false", catelogs do
      science     = Map.get(catelogs, "Top.Science")
      hobbies     = Map.get(catelogs, "Top.Hobbies")
      collections = Map.get(catelogs, "Top.Collections")

      siblings = science
                 |> Catelog.siblings(with_self: false)
                 |> Repo.all
      assert siblings == [hobbies, collections]
    end
  end
end

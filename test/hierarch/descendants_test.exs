defmodule Hierarch.DescendantsTest do
  use Hierarch.TestCase

  setup_all do
    catelogs = create_catelogs()

    on_exit fn ->
      Repo.delete_all(Catelog)
    end

    {:ok, catelogs}
  end

  describe "descendants/2" do
    test "returns its descendants", catelogs do
      science      = Map.get(catelogs, "Top.Science")
      astronomy    = Map.get(catelogs, "Top.Science.Astronomy")
      astrophysics = Map.get(catelogs, "Top.Science.Astronomy.Astrophysics")
      cosmology    = Map.get(catelogs, "Top.Science.Astronomy.Cosmology")

      descendants = science
                    |> Catelog.descendants
                    |> Repo.all
      assert_match descendants, [astronomy, astrophysics, cosmology]
    end

    test "returns blank array if it is the leaf", catelogs do
      cosmology = Map.get(catelogs, "Top.Science.Astronomy.Cosmology")

      descendants = cosmology
                    |> Catelog.descendants
                    |> Repo.all
      assert descendants == []
    end
  end

  describe "descendants/2 with_self" do
    test "returns its descendants and itself when with_self is true", catelogs do
      science      = Map.get(catelogs, "Top.Science")
      astronomy    = Map.get(catelogs, "Top.Science.Astronomy")
      astrophysics = Map.get(catelogs, "Top.Science.Astronomy.Astrophysics")
      cosmology    = Map.get(catelogs, "Top.Science.Astronomy.Cosmology")

      descendants = science
                    |> Catelog.descendants(with_self: true)
                    |> Repo.all
      assert_match descendants, [science, astronomy, astrophysics, cosmology]
    end

    test "returns its descendants when with_self is false", catelogs do
      science      = Map.get(catelogs, "Top.Science")
      astronomy    = Map.get(catelogs, "Top.Science.Astronomy")
      astrophysics = Map.get(catelogs, "Top.Science.Astronomy.Astrophysics")
      cosmology    = Map.get(catelogs, "Top.Science.Astronomy.Cosmology")

      descendants = science
                    |> Catelog.descendants(with_self: false)
                    |> Repo.all
      assert_match descendants, [astronomy, astrophysics, cosmology]
    end
  end
end

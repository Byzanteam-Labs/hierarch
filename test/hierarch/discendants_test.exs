defmodule Hierarch.DiscendantsTest do
  use Hierarch.TestCase

  setup_all do
    catelogs = create_catelogs()

    # on_exit fn ->
    #   Repo.delete_all(Catelog)
    # end

    {:ok, catelogs}
  end

  describe "discendants/2" do
    test "returns its discendants", catelogs do
      science      = Map.get(catelogs, "Top.Science")
      astronomy    = Map.get(catelogs, "Top.Science.Astronomy")
      astrophysics = Map.get(catelogs, "Top.Science.Astronomy.Astrophysics")
      cosmology    = Map.get(catelogs, "Top.Science.Astronomy.Cosmology")

      discendants = science
                    |> Catelog.discendants
                    |> Repo.all
      assert discendants == [astronomy, astrophysics, cosmology]
    end

    test "returns blank array if it is the leaf", catelogs do
      cosmology = Map.get(catelogs, "Top.Science.Astronomy.Cosmology")

      discendants = cosmology
                    |> Catelog.discendants
                    |> Repo.all
      assert discendants == []
    end
  end

  describe "discendants/2 with_self" do
    test "returns its discendants and itself when with_self is true", catelogs do
      science      = Map.get(catelogs, "Top.Science")
      astronomy    = Map.get(catelogs, "Top.Science.Astronomy")
      astrophysics = Map.get(catelogs, "Top.Science.Astronomy.Astrophysics")
      cosmology    = Map.get(catelogs, "Top.Science.Astronomy.Cosmology")

      discendants = science
                    |> Catelog.discendants(with_self: true)
                    |> Repo.all
      assert discendants == [science, astronomy, astrophysics, cosmology]
    end

    test "returns its discendants when with_self is false", catelogs do
      science      = Map.get(catelogs, "Top.Science")
      astronomy    = Map.get(catelogs, "Top.Science.Astronomy")
      astrophysics = Map.get(catelogs, "Top.Science.Astronomy.Astrophysics")
      cosmology    = Map.get(catelogs, "Top.Science.Astronomy.Cosmology")

      discendants = science
                    |> Catelog.discendants(with_self: false)
                    |> Repo.all
      assert discendants == [astronomy, astrophysics, cosmology]
    end
  end
end

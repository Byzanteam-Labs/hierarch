defmodule Hierarch.AncestorsTest do
  use Hierarch.TestCase

  setup_all do
    catelogs = create_catelogs()

    on_exit(fn ->
      Repo.delete_all(Catelog)
    end)

    {:ok, catelogs}
  end

  describe "ancestors/2" do
    test "returns its ancestors", catelogs do
      top = Map.get(catelogs, "Top")
      science = Map.get(catelogs, "Top.Science")
      astronomy = Map.get(catelogs, "Top.Science.Astronomy")

      ancestors =
        astronomy
        |> Catelog.ancestors()
        |> Repo.all()

      assert ancestors == [top, science]
    end

    test "returns blank array if it is the root", catelogs do
      top = Map.get(catelogs, "Top")

      ancestors =
        top
        |> Catelog.ancestors()
        |> Repo.all()

      assert ancestors == []
    end
  end

  describe "ancestors/2 with_self" do
    test "returns its ancestors and itself", catelogs do
      top = Map.get(catelogs, "Top")
      science = Map.get(catelogs, "Top.Science")
      astronomy = Map.get(catelogs, "Top.Science.Astronomy")

      ancestors =
        astronomy
        |> Catelog.ancestors(with_self: true)
        |> Repo.all()

      assert ancestors == [top, science, astronomy]
    end

    test "returns itself if it is the root", catelogs do
      top = Map.get(catelogs, "Top")

      ancestors =
        top
        |> Catelog.ancestors(with_self: true)
        |> Repo.all()

      assert ancestors == [top]
    end
  end

  describe "ancestors/1" do
    import Ecto.Query

    test "returns ancestors of a query", catelogs do
      science = Map.get(catelogs, "Top.Science")
      hobbies = Map.get(catelogs, "Top.Hobbies")
      pictures = Map.get(catelogs, "Top.Collections.Pictures")

      top = Map.get(catelogs, "Top")
      collections = Map.get(catelogs, "Top.Collections")

      query =
        from(
          c in Catelog,
          where: c.id in ^[science.id, hobbies.id, pictures.id]
        )

      descendants =
        query
        |> Hierarch.Query.Ancestors.query()
        |> Repo.all()

      assert_match(descendants, [top, collections])
    end
  end
end

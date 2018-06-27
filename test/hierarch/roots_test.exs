defmodule Hierarch.RootsTest do
  use Hierarch.TestCase

  setup_all do
    catelogs = create_catelogs()

    # on_exit fn ->
    #   Repo.delete_all(Catelog)
    # end

    {:ok, catelogs}
  end

  describe "roots/0" do
    test "returns its roots", catelogs do
      top = Map.get(catelogs, "Top")

      roots = Catelog.roots
              |> Repo.all
      assert roots == [top]
    end
  end
end

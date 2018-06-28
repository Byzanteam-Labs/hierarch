defmodule BigintPrimaryKeyTest do
  use Hierarch.TestCase

  setup_all do
    organizations = create_organizations()

    on_exit fn ->
      Repo.delete_all(Organization)
    end

    {:ok, organizations}
  end

  test "returns the parent", organizations do
    b = Map.get(organizations, "A.B")
    c = Map.get(organizations, "A.B.C")

    discendants = c
                  |> Organization.parent
                  |> Repo.one
    assert discendants == b
  end

  test "returns sbilings", organizations do
    b = Map.get(organizations, "A.B")
    d = Map.get(organizations, "A.D")

    sblings = b
              |> Organization.sblings
              |> Repo.all
    assert sblings == [d]
  end

  test "return discendants", organizations do
    a = Map.get(organizations, "A")
    b = Map.get(organizations, "A.B")
    c = Map.get(organizations, "A.B.C")
    d = Map.get(organizations, "A.D")

    discendants = a
                  |> Organization.discendants
                  |> Repo.all
    assert discendants == [b, c, d]
  end
end

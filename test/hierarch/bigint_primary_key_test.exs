defmodule BigintPrimaryKeyTest do
  use Hierarch.TestCase

  setup_all do
    organizations = create_organizations()

    on_exit(fn ->
      Repo.delete_all(Organization)
    end)

    {:ok, organizations}
  end

  test "returns the parent", organizations do
    b = Map.get(organizations, "A.B")
    c = Map.get(organizations, "A.B.C")

    descendants =
      c
      |> Organization.parent()
      |> Repo.one()

    assert descendants == b
  end

  test "returns sbilings", organizations do
    b = Map.get(organizations, "A.B")
    d = Map.get(organizations, "A.D")

    siblings =
      b
      |> Organization.siblings()
      |> Repo.all()

    assert siblings == [d]
  end

  test "return descendants", organizations do
    a = Map.get(organizations, "A")
    b = Map.get(organizations, "A.B")
    c = Map.get(organizations, "A.B.C")
    d = Map.get(organizations, "A.D")

    descendants =
      a
      |> Organization.descendants()
      |> Repo.all()

    assert descendants == [b, c, d]
  end
end

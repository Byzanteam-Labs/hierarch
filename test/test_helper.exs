defmodule Hierarch.TestCase do
  use ExUnit.CaseTemplate

  using(opts) do
    quote do
      use ExUnit.Case, unquote(opts)
      alias Dummy.{Repo, Catelog}

      def create_catelogs do
        catelogs_list = [
          "Top",
          "Top.Science",
          "Top.Science.Astronomy",
          "Top.Science.Astronomy.Astrophysics",
          "Top.Science.Astronomy.Cosmology",
          "Top.Hobbies",
          "Top.Hobbies.Amateurs_Astronomy",
          "Top.Collections",
          "Top.Collections.Pictures",
          "Top.Collections.Pictures.Astronomy",
          "Top.Collections.Pictures.Astronomy.Stars",
          "Top.Collections.Pictures.Astronomy.Galaxies",
          "Top.Collections.Pictures.Astronomy.Astronauts"
        ]

        Enum.reduce(catelogs_list, %{}, fn (name, acc) ->
          parent_name = Hierarch.LTree.parent_path(name)
          parent = Map.get(acc, parent_name)

          catelog = Catelog.build_child_of(parent, %{name: name}) |> Repo.insert!
          Map.put acc, name, catelog
        end)
      end
    end
  end

  setup do
    Ecto.Adapters.SQL.Sandbox.mode(Dummy.Repo, {:shared, self()})
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Dummy.Repo)
  end
end

{:ok, _} = Dummy.Repo.start_link
ExUnit.start()

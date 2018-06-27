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

        Enum.reduce(catelogs_list, %{}, fn (labels_str, acc) ->
          catelog = %Catelog{name: labels_str, path: Hierarch.LTree.cast(labels_str)} |> Repo.insert!
          Map.put acc, labels_str, catelog
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

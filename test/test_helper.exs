defmodule Hierarch.TestCase do
  use ExUnit.CaseTemplate

  defmacro __using__(opts) do
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

        Enum.reduce(catelogs_list, %{}, fn (labels, acc) ->
          name = labels |> String.split(".") |> List.last()
          catelog = %Catelog{name: name, path: Hierarch.LTree.cast(labels)} |> Repo.insert!()
          Map.put acc, name, catelog
        end)
      end
    end
  end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Dummy.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Dummy.Repo, {:shared, self()})
  end
end

{:ok, _pid} = Dummy.Repo.start_link

ExUnit.start()

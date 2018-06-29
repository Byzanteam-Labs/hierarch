defmodule Hierarch.TestCase do
  use ExUnit.CaseTemplate

  using(opts) do
    quote do
      use ExUnit.Case, unquote(opts)
      alias Dummy.{Repo, Catelog, Organization}

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

      def create_organizations do
        organizations_list = [
          "A",
          "A.B",
          "A.B.C",
          "A.D",
        ]

        Enum.reduce(organizations_list, %{}, fn (name, acc) ->
          parent_name = Hierarch.LTree.parent_path(name)
          parent = Map.get(acc, parent_name)

          organization = Organization.build_child_of(parent, %{name: name}) |> Repo.insert!
          Map.put acc, name, organization
        end)
      end
    end
  end

  setup do
    Ecto.Adapters.SQL.Sandbox.mode(Dummy.Repo, {:shared, self()})
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Dummy.Repo)
  end
end

if System.get_env("CI") == "true" do
  junit_folder = Mix.Project.build_path() <> "/junit/#{Mix.Project.config[:app]}"
  File.mkdir_p!(junit_folder)
  :ok = Application.put_env(:junit_formatter, :report_dir, junit_folder)

  ExUnit.configure formatters: [JUnitFormatter, ExUnit.CLIFormatter]
end

{:ok, _} = Dummy.Repo.start_link
ExUnit.start()

defmodule Hierarch.MixProject do
  use Mix.Project

  @project_url "https://github.com/GreenNerd-Labs/hierarch"
  @version "0.1.0"

  def project do
    [
      app: :hierarch,
      version: @version,
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      source_url: @project_url,
      homepage_url: @project_url,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end

  defp description() do
    "Hierarchy structure for ecto models with PostgreSQL LTree."
  end

  defp package() do
    [
      name: :hierarch,
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      licenses: ["MIT"],
      links: %{"GitHub" => @project_url}
    ]
  end
end

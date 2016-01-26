defmodule ExOrient.Mixfile do
  use Mix.Project

  def project do
    [app: :ex_orient,
     version: "0.1.2",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description,
     package: package,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      mod: {ExOrient, []},
      applications: [:logger]
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:marco_polo, "~> 0.1"},
      {:poison, "~> 1.5 or ~> 2.0"},
      {:poolboy, "~> 1.5 or ~> 1.4"},
      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.11", only: :dev}
    ]
  end

  defp description do
    """
    OrientDB query builder that provides nice syntax and connection pooling.
    Uses MarcoPolo under the hood to run commands.
    """
  end

  defp package do
    [
      maintainers: ["Paul Dilyard"],
      licenses: ["MIT"],
      links: %{
        "Github" => "https://github.com/Remesh/ex_orient/",
        "Docs" => "http://hexdocs.pm/ex_orient/"
      }
    ]
  end
end

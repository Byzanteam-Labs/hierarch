Postgrex.Types.define(
  Hierarch.Postgrex.Types,
  [
    Hierarch.Postgrex.Extensions.LTree,
    Hierarch.Postgrex.Extensions.LQuery
  ] ++ Ecto.Adapters.Postgres.extensions()
)

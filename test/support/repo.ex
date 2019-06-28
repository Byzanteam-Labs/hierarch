defmodule Dummy.Repo do
  @moduledoc false
  use Ecto.Repo,
    otp_app: :hierarch,
    adapter: Ecto.Adapters.Postgres
end

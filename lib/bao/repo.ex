defmodule Bao.Repo do
  use Ecto.Repo,
    otp_app: :bao,
    adapter: Ecto.Adapters.Postgres
end

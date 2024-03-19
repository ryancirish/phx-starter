defmodule Ryancirish.Repo do
  use Ecto.Repo,
    otp_app: :ryancirish,
    adapter: Ecto.Adapters.Postgres
end

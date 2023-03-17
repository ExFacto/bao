defmodule Bao.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :pubkey_ct, :integer
      add :state, :string
      add :point, :string
      add :scalar, :string

      timestamps()
    end
  end
end

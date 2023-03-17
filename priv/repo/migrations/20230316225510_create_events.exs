defmodule Bao.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :pubkey_ct, :integer
      add :point, :string
      add :scalar, :string

      timestamps()
    end
  end
end

defmodule Bao.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :pubkey_ct, :integer
      add :hash, :string
      add :point, :string
      add :signature, :string
      add :scalar, :string

      timestamps()
    end

    create unique_index(:events, [:point])
  end
end

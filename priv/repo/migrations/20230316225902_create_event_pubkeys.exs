defmodule Bao.Repo.Migrations.CreateEventPubkeys do
  use Ecto.Migration

  def change do
    create table(:event_pubkeys) do
      add :pubkey, :string
      add :signed, :boolean, default: false, null: false
      add :signature, :string
      add :event_id, references(:events, on_delete: :nothing)

      timestamps()
    end

    # TODO create index(:events_event_pubkeys, [:pubkey, :event_id])
    create index(:event_pubkeys, [:event_id])
  end
end

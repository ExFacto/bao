defmodule Bao.Events.EventPubkey do
  use Ecto.Schema
  import Ecto.Changeset

  schema "event_pubkeys" do
    field :pubkey, :string
    field :signature, :string
    field :signed, :boolean, default: false
    field :signed_at, :utc_datetime
    field :event_id, :id

    timestamps()
  end

  @doc false
  def changeset(event_pubkey, attrs) do
    event_pubkey
    |> cast(attrs, [:pubkey])
    |> validate_required([:pubkey])
  end
end

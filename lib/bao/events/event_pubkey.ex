defmodule Bao.Events.EventPubkey do
  use Ecto.Schema
  import Ecto.Changeset

  schema "event_pubkeys" do
    field :pubkey, :string
    field :signature, :string
    field :signed, :boolean, default: false
    field :signed_at, :utc_datetime
    belongs_to :event, Event

    timestamps()
  end

  @doc false
  def changeset(event_pubkey, attrs) do
    event_pubkey
    |> cast(attrs, [:pubkey])
    |> validate_required([:pubkey])
  end
end

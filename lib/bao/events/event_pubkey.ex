defmodule Bao.Events.EventPubkey do
  use Ecto.Schema
  import Ecto.Changeset
  alias Bao.Events.Event

  schema "event_pubkeys" do
    field :pubkey, :string
    field :signature, :string
    field :signed, :boolean, default: false
    belongs_to :event, Event

    timestamps()
  end

  @doc false
  def changeset(event_pubkey, attrs) do
    event_pubkey
    # TODO ensure on updates we are not overwriting pubkey?
    # I guess since its an update, the whole row is rewritten anyway?
    |> cast(attrs, [:pubkey, :signature, :signed])

    # |> validate_required([:pubkey])
  end
end

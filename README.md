# Bao

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix


## Cryptography & Security

The cryptography used here is implemented in [Bitcoinex](https://github.com/SachinMeier/bitcoinex). It uses Schnorr signatures as defined in [BIP-340](https://github.com/bitcoin/bips/blob/master/bip-0340.mediawiki), Deterministic Nonce generation, as defined in [RFC6979 Section 3.2](https://www.rfc-editor.org/rfc/rfc6979#section-3.2). 

### Event Hash

NOTE: The Event Hash is currently what is signed by the parties to unlock the Scalar. We are, however, considering the tradeoffs between having participants sign the Event Hash or the Event Point. Follow the discussion [here](https://github.com/ExFacto/bao/discussions/1)

The Bao (this server), receives Commit requests comprising of a list of pubkeys. Based on those pubkeys, Bao deterministically generates an event hash. The event hash is hash256 (double sha256) digest of the concatenated x_bytes of the BIP-67-sorted pubkeys.

```python
sorted_pubkeys = lexicographical_sort_pubkeys(pubkeys)
pubkeys_x_bytes = [pk.x.to_bytes(32, 'big') for pk in sorted_pubkeys]
preimage = b' '.join(x_bytes)
hashlib.sha256(hashlib.sha256(preimage)).digest()
```

Thus, for a given set of pubkeys, Bao users should be able to calculate the event hash before making the Commit request to Bao. 

### Event Point & Scalar

The event point is the point the users will use to `encrypted_sign` their data. It is otherwise known as the tweak point for adaptor signatures. The event point will be returned in response to Commit requests.

```code
k = deterministic_k(sk, event_hash)
N = k * G                                   <--- Nonce point 
S = calculate_sigpoint(N, event_hash)       <--- Event Point
(N, s) = sign_with_nonce(sk, k, event_hash)          
s                                           <--- Event Scalar
```

The `event scalar` is the scalar (private key) associated with the `event point`. It will be made available by Bao when a signature from each pubkey listed in the Commit request is received. In the future, we hope to implement callbacks to minimize latency and reduce the need to poll the Bao server. 

### Privacy



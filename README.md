# Bao API


## Using the Bao Server

An instance of Bao is going to be set up soon. However, this project is Open Sourced to allow for many instances of Barrier Oracles to exist.

## Bao Client

A rudimentary client library can be found [here](https://github.com/ExFacto/bao_client). The client actually contains an integration test to run against the server.

Until a full client is built, there is a Postman collection in [/docs](/docs/Bao.postman_collection.json)

## Run a Bao Server

If you have any trouble running this app locally, email Sachin Meier at firstname dot lastname at gmail.com. 

You will need elixir & Phoenix installed. Bao uses the versions in `.tool-versions`. We recommend using `asdf` to install erlang & elixir.

Start a Postgres server in Docker using docker-compose.

```bash
docker-compose up bao_postgres
```

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser. This is an API server. The only browsable page is `/docs` and the only API endpoint is `/api/event`. 

## Cryptography & Security

The cryptography used here is implemented in [Bitcoinex](https://github.com/SachinMeier/bitcoinex). It uses Schnorr signatures as defined in [BIP-340](https://github.com/bitcoin/bips/blob/master/bip-0340.mediawiki), Deterministic Nonce generation, as defined in [RFC6979 Section 3.2](https://www.rfc-editor.org/rfc/rfc6979#section-3.2). 

The Bitcoinex library is a fork owned by Sachin Meier and is not maintained or reviewed by, or affiliated with River Financial. There is a significant amount of unreviewed code in [SachinMeier/bitcoinex](https://github.com/SachinMeier/bitcoinex). Use this service with caution and for non-security critical activities.

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

### Event Signature

The Bao must sign the Event Point so that all parties are prevent MITM attacks. See this [discussion](https://github.com/ExFacto/bao/discussions/2) for an example attack.

While the Event Hash is deterministic for a set of pubkeys, the Event Point relies of an Oracle's entropy, so it is not pre-computable by the parties.

The Event Signature will be Schnorr signature of the Hash256 (double SHA256) of the 33-byte SEC compressed Event Point.

### Privacy



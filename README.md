FsBert
======

FsBert is a Julia library for encoding / decoding binary Erlang terms. It follows the Erlang external term format as closely as possible.

The API is minimal: encode, encode_message and decode, decode_message.

An example use of this library would be to encode a Julia value and send it across to an Erlang node or to decode a message received from an Erlang node.

```
packet, nbytes = FsBert.encode(uint8([1,2,3,4]))

send_to_erlang(packet)
reply, nbytes = recv_from_erlang()

message, nbytes = FsBert.decode(reply)
```


#------------------------------------------------------------------------------
# Author: Edward Tate <edward.tate@erlang-solutions.com>
#------------------------------------------------------------------------------

export decode, decode_message
export decode_integer

#------------------------------------------------------------------------------
# External API
#------------------------------------------------------------------------------

function decode_message (bytes::Array{Uint8})
    arity = decode_integer(bytes[1:4])
    # Skip byte 5 as this is the magic number 131
    bytes = bytes[6:end]
    pkt, nbytes = decode(bytes)
    pkt, nbytes + 5
end

#------------------------------------------------------------------------------
# Decoding Functions
#------------------------------------------------------------------------------

function decode (bytes::Array{Uint8})
    decoded, nbytes = decode(bytes[1], bytes[2:end])
    decoded, nbytes + 1
end

function decode (tag::Uint8, rest::Array{Uint8})
    tag == 70 ? decode(ErlFloat, rest) :
    tag == 97 ? decode(ErlSmallInteger, rest) :    
    tag == 98 ? decode(ErlInteger, rest) :
    tag == 100 ? decode(ErlAtom, rest) :
    tag == 104 ? decode(ErlSmallTuple, rest) :
    tag == 105 ? decode(ErlLargeTuple, rest) :
    tag == 106 ? decode(ErlNil, rest) :
    tag == 107 ? decode(ErlString, rest) :
    tag == 108 ? decode(ErlList, rest) :
    tag == 109 ? decode(ErlBinary, rest) :
    tag == 110 ? decode(ErlSmallBigInt, rest) :
    tag == 111 ? decode(ErlLargeBigInt, rest) :
    error("Decoding tag not recognized")
end

function decode (::Type{ErlFloat}, bytes::Array{Uint8})
    hex2num(bytes2hex(bytes[1:8])), 8
end

function decode (::Type{ErlSmallInteger}, bytes::Array{Uint8})
    bytes[1], 1
end

function decode (::Type{ErlInteger}, bytes::Array{Uint8})
    decode_integer(bytes[1:4]), 4
end

function decode (::Type{ErlAtom}, bytes::Array{Uint8})
    arity = decode_integer(bytes[1:2])
    atom = bytes[3:arity+2]
    symbol(ascii(atom)), arity + 2
end

function decode (::Type{ErlSmallTuple}, bytes::Array{Uint8})
    arity = bytes[1]
    seq, nbytes, rest = decode_sequence(bytes[2:end], arity)
    tuple(seq...), nbytes + 1
end

function decode (::Type{ErlLargeTuple}, bytes::Array{Uint8})
    arity = decode_integer(bytes[1:4])
    seq, nbytes, rest = decode_sequence(bytes[5:end], arity)
    tuple(seq...), nbytes + 4
end

function decode (::Type{ErlNil}, bytes::Array{Uint8})
    [], 1
end

function decode (::Type{ErlString}, bytes::Array{Uint8})
    arity = decode_integer(bytes[1:2])
    ascii(bytes[3:arity+2]), arity + 2
end

function decode (::Type{ErlList}, bytes::Array{Uint8})
    arity = decode_integer(bytes[1:4])
    seq, nbytes, rest = decode_sequence(bytes[5:end], arity)
    seq, nbytes + 4
end

function decode (::Type{ErlBinary}, bytes::Array{Uint8})
    arity = decode_integer(bytes[1:4])
    bytes[5:arity+4], arity + 4
end

function decode (::Type{ErlSmallBigInt}, bytes::Array{Uint8})
    const b = 256
    arity = bytes[1]
    sign = bytes[2]
    digits = bytes[3:arity+2]

    n = 0
    for i = 1:arity
        n += digits[i] * (b ^ (i - 1))
    end

    BigInt(n), arity + 2
end

function decode (::Type{ErlLargeBigInt}, bytes::Array{Uint8})
    error("Not Implemented")
end

#------------------------------------------------------------------------------
# Utility
#------------------------------------------------------------------------------

function decode_next (bytes::Array{Uint8})
    decoded, nbytes = decode(bytes)
    decoded, bytes[nbytes+1:end], nbytes
end

function decode_sequence (bytes::Array{Uint8}, arity::Integer)
    seq = cell(arity)
    byte_count = 0
    for i = 1:arity
        decoded, next, nbytes = decode_next(bytes)
        bytes = next
        seq[i] = decoded
        byte_count += nbytes
    end
    seq, byte_count, bytes
end

function decode_integer (bytes::Array{Uint8})
    arity = length(bytes)
    bytes = reverse(bytes)
    arity == 1 ? reinterpret(Uint8, bytes)[1] :
    arity == 2 ? reinterpret(Uint16, bytes)[1] :
    arity == 4 ? reinterpret(Uint32, bytes)[1] :
    arity == 8 ? reinterpret(Uint64, bytes)[1] :
    reinterpret(Uint32, bytes)[1]
end

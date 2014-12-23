#------------------------------------------------------------------------------
# Author: Edward Tate <edward.tate@erlang-solutions.com>
#------------------------------------------------------------------------------

export encode, encode_message
export encode_integer

#------------------------------------------------------------------------------
# External API
#------------------------------------------------------------------------------

function encode_message (x)
    encoded, nbytes = encode(x)
    # Add 1 to arity due to magic number
    length_header = encode_integer(uint32(nbytes + 1))
    pkt = [length_header, 131, encoded]
    uint8(pkt), length(pkt)
end

#------------------------------------------------------------------------------
# Encoding Functions
#------------------------------------------------------------------------------

function encode (n::Integer)
    if n < 256
        pkt = [97, n]
    else
        pkt = [98, encode_integer(n)]
    end
    pkt, length(pkt)
end

function encode (n::Real)
    bytes = hex2bytes(num2hex(n))
    pkt = [70, bytes]
    pkt, length(pkt)
end

function encode (n::BigInt)
    sign = n > 0 ? 0 : 1
    size = sizeof(n)
    bytes = zeros(Uint8, sizeof(n))
    for i = 1:size
        bytes[i] = n & 0xFF
        n >>= 8
    end
    arity = length(bytes)
    pkt = [110, arity, sign, bytes]
    pkt, length(pkt)
end

function encode (sym::Symbol)
    bytes = map(uint8, collect(string(sym)))
    arity = encode_integer(uint16(length(bytes)))
    pkt = [100, arity, bytes]
    pkt, length(pkt)
end

function encode (tup::Tuple)
    encoded = Array(Uint8, 0)
    for elt in tup
        pkt, nbytes = encode(elt)
        encoded = vcat(encoded, pkt)
    end

    if length(tup) < 256
        arity = length(tup)
        pkt = [104, arity, encoded]
        pkt, length(pkt)
    else
        arity = encode_integer(uint32(length(tup)))
        pkt = [105, arity, encoded]
        pkt, length(pkt)
    end
end

function encode (str::String)
    if isempty(str)
        pkt = [106]
        pkt, length(pkt)
    else
        arity = encode_integer(uint16(length(str)))
        pkt = [107, arity, collect(str)]
        pkt, length(pkt)
    end
end

function encode (arr::Array)
    if isempty(arr)
        pkt = [106]
        pkt, length(pkt)
    else
        xs = Array(Uint8, 0)
        for i = 1:length(arr)
            bytes, nbytes = encode(arr[i])
            xs = vcat(xs, bytes)
        end

        arity = encode_integer(uint32(length(arr)))
        pkt = [108, arity, xs, 106]
        pkt, length(pkt)
    end
end

function encode (bin::Array{Uint8})
    arity = encode_integer(uint32(length(bin)))
    pkt = [109, arity, bin]
    pkt, length(pkt)
end

#------------------------------------------------------------------------------
# Internal Encoding Functions
#------------------------------------------------------------------------------

function encode_integer (n::Integer)
    sz = sizeof(n)
    bs = Array(Uint8, sz)
    ms = zero(n) | 0xFF
    for i = sz:-1:1
        bs[i] = n & ms
        n >>= 8
    end
    bs
end

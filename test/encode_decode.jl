
function encode_decode (x)
    e, n = encode(x)
    d, m = decode(uint8(e))
    @assert n == m
    d, m
end

x, nbytes = encode_decode(uint8(255))
@test x == uint8(255)

x, nbytes = encode_decode(uint32(256))
@test x == uint32(256)

x, nbytes = encode_decode(float(1.0))
@test x == float(1.0)

x, nbytes = encode_decode(big(256256256256))
@test x == big(256256256256)

x, nbytes = encode_decode(:symbol)
@test x == :symbol

x, nbytes = encode_decode(tuple())
@test x == tuple()

x, nbytes = encode_decode((:a, uint8(255), float(1.0)))
@test x == (:a, uint8(255), float(1.0))

x, nbytes = encode_decode("a_string")
@test x == "a_string"

#x, nbytes = encode_decode([:a, :b, :c])
#@test x == [:a, :b, :c]

x, nbytes = encode_decode(uint8([1, 2, 3, 4]))
@test x == uint8([1, 2, 3, 4])



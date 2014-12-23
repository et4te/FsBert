
function next_request (s::TCPSocket)
    bytes = read_erlang_term(s)
    msg, nbytes = decode_message(bytes)
    is(msg[1], :call) ? CallRequest(msg[2:end]...) :
    is(msg[1], :cast) ? CastRequest(msg[2:end]...) :
    is(msg[1], :info) ? InfoRequest(msg[2:end]...) :
    is(msg[1], :error) ? ErrorRequest(msg[2:end]...) :
    error("Message does not conform to protocol.")
end

function form_request (s::TCPSocket, r::Union(Request,Nothing))
    if r == nothing
        next_request(s)
    else
        next = next_request(s)
        modify(next, r)
    end
end

function handle_request (s::TCPSocket)
    r = nothing

    while isopen(s)
        r = form_request(s, r)
        handle_request(r)
    end
end

function modify(r1::InfoRequest, r2::InfoRequest)
    InfoRequest(r2)
end

function modify(r1::CallRequest, r2::InfoRequest)
    if is(r2.command, :stream)
        StreamingCallRequest(r2)
    else
        r1
    end
end

function modify(r1::CastRequest, r2::InfoRequest)
    if is(r2.command, :callback)
        CallbackCastRequest(r2)
    else
        r1
    end
end

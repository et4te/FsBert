fatal = length(ARGS) > 0 && ARGS[1] == "-f"
quiet = length(ARGS) > 0 && ARGS[1] == "-q"
any_errors = false

push!(LOAD_PATH, "../src")

using FsBert
using Base.Test

tests = [ "encode_decode.jl" ]

println("Running tests ...")

for test in tests
    try
        include(test)
        println("\t\033[1m\033[32mPASSED\033[0m: $(test)")
    catch e
        any_errors = true
        println("\t\033[1m\033[31mFAILED\033[0m: $(test)")
        if fatal
            rethrow(e)
        elseif !quiet
            showerror(STDOUT, e, backtrace())
            println()
        end
    end
end

if any_errors
    throw("Tests failed")
end

stdin = joinpath(dirname(@__FILE__), "stdin.sh")
ENV2 = copy(ENV)
ENV2["JULIA_HOME"] = JULIA_HOME
run(setenv(`bash $stdin`, ENV2))

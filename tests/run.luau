local native = require("@native_example")

assert(native.add(20, 22) == 42, "native add returned the wrong value")
assert(native.identity("Lode") == "Lode", "native identity returned the wrong value")

if native.sha256 then
    assert(native.sha256("Lode") == "79ae5999c7bb92e1c1f8a4156acc757939cf64226ec5cf0696cb9db1ec41d347",
        "OpenSSL SHA-256 returned the wrong value")
end

print("native_example: all checks passed")

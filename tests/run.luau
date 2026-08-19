local native = require("@native_example")

assert(native.add(20, 22) == 42, "native add returned the wrong value")
assert(native.identity("Lode") == "Lode", "native identity returned the wrong value")

print("native_example: all checks passed")

#include "Lode/Module.hpp"
#include "Lode/State.hpp"
#include "Lode/Table.hpp"
#include "Lode/Value.hpp"

#ifdef LODE_NATIVE_EXAMPLE_WITH_OPENSSL
#include <openssl/sha.h>
#endif

#include <iomanip>
#include <sstream>

LODE_MODULE(vm)
{
    Lode::Table exports = vm.CreateTable();

    exports.Set("add", vm.CreateFunction([](Lode::State&, const std::vector<Lode::Value>& args) -> Lode::Value {
        const double left = args.size() > 0 && args[0].IsNumber() ? args[0].AsNumber() : 0.0;
        const double right = args.size() > 1 && args[1].IsNumber() ? args[1].AsNumber() : 0.0;
        return Lode::Value(left + right);
    }));

    exports.Set("identity", vm.CreateFunction([](Lode::State&, const std::vector<Lode::Value>& args) -> Lode::Value {
        return args.empty() ? Lode::Value() : args[0];
    }));

#ifdef LODE_NATIVE_EXAMPLE_WITH_OPENSSL
    exports.Set("sha256", vm.CreateFunction([](Lode::State& vm, const std::vector<Lode::Value>& args) -> Lode::Value {
        if (args.empty() || !args[0].IsString())
        {
            vm.RaiseError("sha256 expects a string");
            return Lode::Value();
        }

        const std::string input = args[0].AsString();
        unsigned char digest[SHA256_DIGEST_LENGTH];
        SHA256(reinterpret_cast<const unsigned char*>(input.data()), input.size(), digest);

        std::ostringstream hex;
        hex << std::hex << std::setfill('0');
        for (unsigned char byte : digest)
            hex << std::setw(2) << static_cast<unsigned int>(byte);
        return Lode::Value(hex.str());
    }));
#endif

    return exports;
}

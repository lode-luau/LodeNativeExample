#include "Lode/Module.hpp"
#include "Lode/State.hpp"
#include "Lode/Table.hpp"
#include "Lode/Value.hpp"

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

    return exports;
}

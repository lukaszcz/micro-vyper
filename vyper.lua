VERSION = "0.1.0"

local config = import("micro/config")

function preinit()
    config.AddRuntimeFile("vyper", config.RTSyntax, "syntax/vyper.yaml")
    config.AddRuntimeFile("vyper", config.RTHelp, "help/vyper.md")
end

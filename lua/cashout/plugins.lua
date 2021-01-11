local pcount, cmdcount = 0, 0
local ccadd, inc, ccv, cccv = concommand.Add, include, CreateConVar, CreateClientConVar
Cashout.Plugins = {}

local disabled = {
    --example = true
}

menup = {} -- Compatability with  glua/gmod-menu-plugins
menup.options = {}
local options = {}

function menup.include(path)
    return include("cashout/plugins/" .. path)
end

function menup.options.addOption(plugin, option, default)
    options[plugin] = options[plugin] or {}
    options[plugin][option] = {}

    if menup.options.getOption(plugin, option) == "unset" then
        menup.options.setOption(plugin, option, default)
    end
end

function menup.options.setOption(plugin, option, value)
    cookie.Set("menup_" .. plugin .. "_" .. option, value)
end

function menup.options.getOption(plugin, option)
    return cookie.GetString("menup_" .. plugin .. "_" .. option, "unset")
end

function menup.options.getTable() return options end

local function spewOptions()
    for plugin, tab in pairs(options) do
        print(plugin .. ": ")
        for option, _ in pairs(tab) do
            print("\t" .. option .. ":\t" .. menup.options.getOption(plugin, option))
        end
    end
end
concommand.Add("menup_setOption", function(...) menup.options.setOption(select(1, ...), select(2, ...), select(3, ...)) end, nil, "Set a menu state option; Format: <plugin> <option> <value>")
concommand.Add("menup_spewOptions", spewOptions, nil, "Spew all menu state options")

function concommand.Add(...)
    Cashout.Plugins[select(1, ...)] = "cmd"
    cmdcount = cmdcount + 1
    return ccadd(...)
end

function include(path) -- for those who didn't get the memo they should use menup.include()
    if string.sub(path, 1, 13) == "menu_plugins/" then
        return inc("cashout/plugins/" .. string.sub(path, 14, #path))
    else
        return inc(path)
    end
end

function CreateConVar(...)
    Cashout.Plugins[select(1, ...)] = "cvar"
    cmdcount = cmdcount + 1
    return ccv(...)
end

function CreateClientConVar(...)
    Cashout.Plugins[select(1, ...)] = "cvar"
    cmdcount = cmdcount + 1
    return cccv(...)
end

print("[Cashout] Loading plugins...")

for _,f in pairs(file.Find("lua/cashout/plugins/*","GAME")) do
    if disabled[f:gsub(".lua","")] then continue end
    include("cashout/plugins/" .. f)
    pcount = pcount + 1
end

concommand.Add, include, CreateConVar, CreateClientConVar = ccadd, inc, ccv, cccv

print("[Cashout] Loaded " .. pcount .. " plugins with " .. cmdcount .. " commands/convars.")
PrintTable(Cashout.Plugins)
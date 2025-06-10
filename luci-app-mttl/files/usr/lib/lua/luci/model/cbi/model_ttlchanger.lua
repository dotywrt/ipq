
local fs = require "nixio.fs"
local uci = require "luci.model.uci".cursor()
local sys = require "luci.sys"

local config_dir = "/etc/nftables.d"
local config_file = nil

for file in fs.dir(config_dir) or {} do
    if file:match("%.nft$") then
        config_file = config_dir .. "/" .. file
        break
    end
end

if not config_file then
    fs.mkdirr(config_dir)
    config_file = config_dir .. "/ttlchanger.nft"
    fs.writefile(config_file, "# TTLChanger rules will go here\n")
end

local main_nft_conf = "/etc/nftables.conf"
local include_line = 'include "' .. config_file .. '"'
local nft_conf_data = fs.readfile(main_nft_conf) or ""

local seen = {}
local cleaned_lines = {}

for line in nft_conf_data:gmatch("[^\r\n]+") do
    if not seen[line] then
        table.insert(cleaned_lines, line)
        seen[line] = true
    end
end

if not seen[include_line] then
    table.insert(cleaned_lines, include_line)
end

fs.writefile(main_nft_conf, table.concat(cleaned_lines, "\n") .. "\n")

local m = Map("ttlchanger", "TTL Changer", [[
<p style="display: flex; align-items: center;">
    If you like my work, please consider supporting me:
    <img id="star" 
         src="/luci-static/resources/TTLcontrol/Star.svg?654407727g" 
         loading="lazy" 
         alt="Star" 
         width="50px" 
         height="20px" 
         style="margin-left: 10px;" 
         onerror="return imgerrorfuns(this,'https://img.shields.io/badge/Star--lightgrey?logo=github&amp;style=social')" 
         onclick="window.open('https://github.com/dotywrt', '_blank')">
    <img id="sponsor" 
         src="/luci-static/resources/TTLcontrol/Sponsor.svg?308407727" 
         loading="lazy" 
         alt="Sponsor" 
         width="73px" 
         height="20px" 
         style="margin-left: 10px;" 
         onerror="return imgerrorfuns(this,'https://img.shields.io/badge/Sponsor--lightgrey?logo=ko-fi&amp;style=social')" 
         onclick="window.open('https://buymeacoffee.com/dotywrt', '_blank')">
    <img id="telegram" 
         src="/luci-static/resources/TTLcontrol/Telegram.svg?308407727" 
         loading="lazy" 
         alt="Telegram" 
         style="margin-left: 10px;" 
         onerror="return imgerrorfuns(this,'https://img.shields.io/badge/Telegram--lightgrey?logo=Telegram&amp;style=social')" 
         onclick="window.open('https://t.me/dotycat', '_blank')">
</p> 
]])


if not uci:get_first("ttlchanger", "ttl") then
    uci:section("ttlchanger", "ttl", nil, { mode = "off", custom_value = "64" })
    uci:commit("ttlchanger")
end

local s = m:section(TypedSection, "ttl", "")
s.anonymous = true

local mode = s:option(ListValue, "mode", "<b>TTL Mode</b>")
mode.default = "off"
mode:value("off", "Off")
mode:value("64", "Force TTL to 64")
mode:value("custom", "Set Custom TTL")

local custom = s:option(Value, "custom_value", "<b>Custom TTL Value</b>")
custom.datatype = "uinteger"
custom.default = "65"
custom:depends("mode", "custom")
custom.description = "Enter a custom TTL/Hop Limit value (e.g., 64 or 65)"

local author = s:option(DummyValue, "_author", "<b>TTL Changer</b>")
author.rawhtml = true
author.value = [[* Configure TTL or Hop Limit values for outgoing packets.
<br/>* Changing TTL may help bypass certain ISP restrictions.
<br/>* <b>TTL OFF</b> - Enables IPv6 support..
<br/>* <b>TTL 64</b> - Bypasses host port data.
<br/>* <b>Note</b> If you lose internet connection after setting TTL, please reboot your modem.
]]

function m.on_commit(map)
    local mode_val = uci:get("ttlchanger", "@ttl[0]", "mode") or "off"
    local custom_val = tonumber(uci:get("ttlchanger", "@ttl[0]", "custom_value")) or 64
    local ttl = (mode_val == "custom") and custom_val or 64
    local comment = (mode_val == "off")

    local function get_chain(name, rule)
        local lines = {
            string.format("chain %s {", name),
            string.format("  type filter hook %s priority 300; policy accept;", name:match("prerouting") and "prerouting" or "postrouting"),
            "  counter",
            "  " .. rule,
            "}"
        }
        if comment then
            for i, l in ipairs(lines) do lines[i] = "# " .. l end
        end
        return table.concat(lines, "\n")
    end

    local ttl_rule = "ip ttl set " .. ttl
    local hop_rule = "ip6 hoplimit set " .. ttl

    local new_rules = table.concat({
        get_chain("mangle_prerouting_ttl64", ttl_rule),
        get_chain("mangle_postrouting_ttl64", ttl_rule),
        get_chain("mangle_prerouting_hoplimit64", hop_rule),
        get_chain("mangle_postrouting_hoplimit64", hop_rule)
    }, "\n")

    local original = fs.readfile(config_file) or ""
    local result, skip = {}, false
    for line in original:gmatch("[^\r\n]+") do
        if line:match("^#?%s*chain mangle_.*ttl") or line:match("^#?%s*chain mangle_.*hoplimit") then
            skip = true
        elseif skip and line:match("^#?%s*}") then
            skip = false
        elseif not skip then
            table.insert(result, line)
        end
    end

    local updated = table.concat(result, "\n")
    if updated ~= "" and not updated:match("\n$") then
        updated = updated .. "\n"
    end

    -- Save updated nftables rules
    fs.writefile(config_file, updated .. "\n" .. new_rules .. "\n")
    sys.call("sleep 10")
    sys.call("/etc/init.d/firewall restart")
    sys.call("/etc/init.d/network restart")
    sys.call('echo "AT+CFUN=1" > /dev/ttyUSB3')
end

return m

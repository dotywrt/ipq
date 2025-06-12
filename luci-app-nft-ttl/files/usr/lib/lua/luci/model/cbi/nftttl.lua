local fs = require "nixio.fs"
local uci = require "luci.model.uci".cursor()

local m = Map("nftttl", translate("TTL Settings"))

local support = m:section(SimpleSection)
support.template = "admin_support_info"

local s = m:section(NamedSection, "ttl", "ttl", translate("Settings"))
s.addremove = false
s:option(Flag, "enabled", translate("Enable"))

local val = s:option(Value, "value", translate("TTL / HopLimit Value"))
val.datatype = "uinteger"
val.default = 64
val.description = translate("Set the TTL (IPv4) / HopLimit (IPv6) value. Default is 64. " ..
    "Enabling this setting will modify all packet TTL values. " ..
    "After setting, click 'Save & Apply' — the firewall will auto-reload the rule.")


function m.on_commit(map)
    local enabled = uci:get("nftttl", "ttl", "enabled")
    local value = uci:get("nftttl", "ttl", "value") or "64"
    local nft_dir = "/etc/nftables.d/"
    local outfile = nft_dir .. "ttl64.nft"

    for f in fs.dir(nft_dir) do
        if f:match("%.nft$") and f ~= "ttl64.nft" and f ~= "README" then
            fs.remove(nft_dir .. f)
        end
    end

    local function write_rule()
        local f = io.open(outfile, "w")
        if not f then return end

        local comment = function(line)
            return (enabled == "1") and line or ("# " .. line)
        end

        f:write(comment("chain mangle_prerouting_ttl64 {\n"))
        f:write(comment("  type filter hook prerouting priority 300; policy accept;\n"))
        f:write(comment("  counter\n"))
        f:write(comment("  ip ttl set " .. value .. "\n"))
        f:write(comment("}\n\n"))

        f:write(comment("chain mangle_postrouting_ttl64 {\n"))
        f:write(comment("  type filter hook postrouting priority 300; policy accept;\n"))
        f:write(comment("  counter\n"))
        f:write(comment("  ip ttl set " .. value .. "\n"))
        f:write(comment("}\n\n"))

        f:write(comment("chain mangle_prerouting_hoplimit64 {\n"))
        f:write(comment("  type filter hook prerouting priority 300; policy accept;\n"))
        f:write(comment("  counter\n"))
        f:write(comment("  ip6 hoplimit set " .. value .. "\n"))
        f:write(comment("  iifname "wwan0" ip6 hoplimit set  .. value .. "\n"))
        f:write(comment("  iifname "wwan0_1" ip6 hoplimit set  .. value .. "\n"))
        f:write(comment("}\n\n"))

        f:write(comment("chain mangle_postrouting_hoplimit64 {\n"))
        f:write(comment("  type filter hook postrouting priority 300; policy accept;\n"))
        f:write(comment("  counter\n"))
        f:write(comment("  ip6 hoplimit set " .. value .. "\n"))
        f:write(comment("  oifname "wwan0" ip6 hoplimit set  .. value .. "\n"))
        f:write(comment("  oifname "wwan0_1" ip6 hoplimit set  .. value .. "\n"))
        f:write(comment("}\n"))

        f:close()
    end

    write_rule()
    os.execute("sleep 1; /etc/init.d/firewall restart &")
end

return m

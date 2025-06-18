local uci = require("luci.model.uci").cursor()

m = Map("ipt_ttl", translate("TTL Settings"))

local info = m:section(SimpleSection)
info.template = "ipt_ttl/info"

s = m:section(NamedSection, "config", "ipt_ttl", translate("Settings"))

enable = s:option(Flag, "enabled", translate("Enable TTL"))
enable.default = "1"
enable.rmempty = false
enable.description = translate("Disable this setting when using a VPN to prevent TTL conflicts.")

ttl = s:option(Value, "ttl", translate("TTL / HopLimit Value"))
ttl.datatype = "uinteger"
ttl.default = "64"
ttl.rmempty = false
ttl.description = translate("Set a TTL (IPv4) / HopLimit (IPv6) value via iptables/ip6tables rules. Default value is 64. Enabling this setting will modify all packet TTL values. After setting, click 'Save & Apply' — the firewall will auto-reload the rule.")

function m.on_after_commit(self)
    luci.sys.call("/usr/libexec/ipt_ttl.sh apply &")
    luci.sys.call("/etc/init.d/firewall restart")
end

return m

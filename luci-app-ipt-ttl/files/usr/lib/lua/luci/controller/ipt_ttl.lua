module("luci.controller.ipt_ttl", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/ipt_ttl") then
        return
    end

    entry({"admin", "modem", "ipt_ttl"}, cbi("ipt_ttl"), _("TTL Settings"), 90)
end

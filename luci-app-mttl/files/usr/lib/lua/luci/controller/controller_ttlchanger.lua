module("luci.controller.controller_ttlchanger", package.seeall)

function index()
    entry({"admin", "modem", "ttlchanger"}, cbi("model_ttlchanger"), _("TTL Control"), 100)
end


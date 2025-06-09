**Package Name**: `luci-app-mttl`

**Version**: `1.0`

**Description**:
The `luci-app-mttl` is a LuCI application for OpenWRT that allows users to modify the TTL (Time-To-Live) of outgoing packets using `nftables`. This package provides a web interface for managing TTL values for network traffic, giving administrators the ability to set a custom TTL on packets passing through the router.

### Features:

* **Change TTL**: Modify the TTL value for outgoing network traffic.
* **Web Interface**: Easy-to-use graphical interface through LuCI to manage TTL settings.
* **nftables Integration**: Uses `nftables` to apply TTL changes to network traffic efficiently.

### Dependencies:

* `luci`: The LuCI framework for the OpenWRT web interface.
* `nftables`: A user-space utility for managing `nftables` (netfilter) configurations.

### Developed by:

* **DotyCat**
  Website: [dotycat.com](https://dotycat.com)

### Usage:

1. Install the package through the OpenWRT interface or using the command line.
2. Access the TTL Changer application in the `Applications` section of LuCI.
3. Set the desired TTL value for your network traffic.
4. Apply the settings to modify the TTL for packets passing through the router.

## 📄 Changelog: **TTL Changer v1.2**

**Release Date:** 2025-06-04

### ✨ New Features

* **🔍 Auto-Detection of Config File:**
  Now automatically detects the appropriate `.nft` configuration file path under `/etc/nftables.d/`, eliminating the need to hardcode `10-custom-filter-chains.nft`. Falls back gracefully if multiple files are found or none exist.

* **🧠 Smarter Rule Generation:**

  * Generates and applies `nftables` rules based on mode: `off`, `64`, or `custom`.
  * Adds or comments out chains dynamically according to user selection.
  * Supports both IPv4 (`ip ttl set`) and IPv6 (`ip6 hoplimit set`) in `prerouting` and `postrouting` chains.

* **💬 Improved LuCI UI Guidance:**

  * Instructions and reboot button included in the UI.
  * Links to developer Telegram and website for easy support access.

### 🛠 Improvements

* **Code Cleanup & Refactoring:**

  * Modular `get_chain()` function now auto-handles both rule application and comment toggling.
  * More robust UCI defaults initialization on first run.

* **Reliability Boost:**

  * Auto-restarts `nftables` only after cleanly updating rule file.
  * Ensures newline formatting to prevent config corruption.

### 🐛 Bug Fixes

* Fixed an issue where previously written rules were not being properly removed.
* Corrected rule logic that could incorrectly trigger skips during parsing of the config file.



# Account Settings Module

The `AccountSettings` module provides account-wide settings functionality, allowing developers to manage settings shared across all characters on a single account. This module is particularly useful for features like account-wide services, preferences, or progress tracking.

---

## Features

- **Account-Wide Settings**: Share settings across all characters on the same account.
- **Easy Integration**: Minimal setup required to use the module in your scripts.
- **Automatic Database Setup**: Creates the necessary database and tables if they do not exist.
- **Flexible API**: Simple `Set` and `Get` methods for managing settings.
- **Event-Driven**: Works seamlessly with Eluna events like player login and commands.

---

## Installation

1. Clone or download the repository:
   ```bash
   git clone https://github.com/blkht01/mod-account-settings.git
2. Place the AccountSettings.lua file in your server's Lua script directory.
3. (Optional) Include OnLogin_UpdateAccWideServices.lua to automatically initialize account-wide settings for certain features.

## Usage
Including the Module

Use the require function to include the module in your script:
```lua
local AccountSettings = require("AccountSettings")
```

## Example Usage
Setting a Value
```lua
local accountId = 12345  -- Example account ID
local source = "my_feature"
local index = 1
local value = 42

AccountSettings.Set(accountId, source, index, value)
print("Account-wide setting updated.")
```

## Getting a Value
```lua
local accountId = 12345  -- Example account ID
local source = "my_feature"
local index = 1

local value = AccountSettings.Get(accountId, source, index)
print(string.format("Retrieved value for account-wide setting: %d", value))
```
 
## Full Example
Here's a practical example using player events:
```lua
local AccountSettings = require("AccountSettings")

-- Initialize default settings on first login
local function OnFirstLogin(event, player)
    local accountId = player:GetAccountId()
    AccountSettings.Set(accountId, "default_preferences", 1, 1)
    AccountSettings.Set(accountId, "default_preferences", 2, 1)
    print(string.format("Initialized account-wide settings for Account ID: %d", accountId))
end

-- Retrieve a setting using a command
local function OnPlayerCommand(event, player, command)
    local args = {strsplit(" ", command)}
    if args[1] == "getsetting" and tonumber(args[2]) then
        local accountId = player:GetAccountId()
        local index = tonumber(args[2])
        local value = AccountSettings.Get(accountId, "default_preferences", index)
        player:SendBroadcastMessage(string.format("Setting %d: %d", index, value))
    end
end

Global:RegisterPlayerEvent(PlayerEvents.PLAYER_EVENT_ON_FIRST_LOGIN, OnFirstLogin)
Global:RegisterPlayerEvent(PlayerEvents.PLAYER_EVENT_ON_COMMAND, OnPlayerCommand)
```

## Scripts Included
1. AccountSettings.lua:

    Core module for managing account-wide settings.
    Provides Set and Get methods for interacting with settings.

2. OnLogin_UpdateAccWideServices.lua:

    Optional script that automatically initializes store settings as account-wide settings.
    Designed for use with Foe's store services.
    
## API Reference
Methods
AccountSettings.Set(accountId, source, index, value)
- **accountId (number): The unique ID of the account.
- **source (string): The source or feature name for the setting.
- **index (number): The index of the value in the settings array.
- **value (number): The value to set.

AccountSettings.Get(accountId, source, index)
- **accountId (number): The unique ID of the account.
- **source (string): The source or feature name for the setting.
- **index (number): The index of the value in the settings array.
- **Returns (number|nil): The value at the specified index or nil if not found.

## Contributing
Pull requests are welcome! For significant changes, please open an issue to discuss your ideas first. If you encounter any bugs or have feature requests, feel free to open an issue.

## License
This project is licensed under the MIT License. See the LICENSE file for details.
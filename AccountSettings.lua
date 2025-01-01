local AccountSettings = {}

-- User-configurable settings
local DATABASE_NAME = "ac_eluna"        -- Default database name
local TABLE_NAME = "account_settings"   -- Default table name
local ENABLED = true                    -- Set to false to disable this script

local function CreateAccountSettingsTable()
    -- Create the database if it does not exist
    local db_query = string.format(
        "CREATE DATABASE IF NOT EXISTS %s;",
        DATABASE_NAME
    )
    local db_result = WorldDBQuery(db_query)
    if not db_result then
        PrintError(string.format("Failed to create or access database '%s'.", DATABASE_NAME))
        return
    end

    -- Create the table if it does not exist
    local table_query = string.format([[
        CREATE TABLE IF NOT EXISTS %s.%s (
            account_id INT UNSIGNED NOT NULL,
            source VARCHAR(255) NOT NULL,
            data TEXT NOT NULL,
            PRIMARY KEY (account_id, source)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
    ]], DATABASE_NAME, TABLE_NAME)

    local table_result = WorldDBQuery(table_query)
    if not table_result then
        PrintError(string.format("Failed to create or access table '%s' in database '%s'.", TABLE_NAME, DATABASE_NAME))
        return
    end

    print("Database and table initialization complete.")
end
CreateAccountSettingsTable()

---Update an account setting value for a specific account and source.
---@param accountId number  # The unique ID of the account.
---@param source string     # The source of the setting (e.g., feature or module name).
---@param index number      # The index of the value in the data array to update.
---@param value number      # The new value to set at the specified index.
function AccountSettings.Set(accountId, source, index, value)
    if not ENABLED then
        print("Tried to set account setting while script is disabled. Please enable the script.")
        PrintError("Tried to set account setting while script is disabled. Please enable the script.")
    return end
    -- Ensure input types are correct
    assert(type(accountId) == "number", "accountId must be a number")
    assert(type(source) == "string", "source must be a string")
    assert(type(index) == "number", "index must be a number")
    assert(type(value) == "number", "value must be a number")

    -- Query to get the current data
    local query = string.format(
        "SELECT data FROM %s.%s WHERE account_id = %d AND source = '%s'",
        DATABASE_NAME, TABLE_NAME, accountId, source
    )
    local result = WorldDBQuery(query)

    local data = {}
    if result == nil then
        -- If there's no existing data, initialize it with zeros
        for i = 1, index do
            data[i] = "0"
        end
        data[index] = tostring(value)
    else
        -- Get the current data and split it into a table
        for val in result:GetString(0):gmatch("%S+") do
            table.insert(data, val)
        end

        -- Ensure the data array is large enough
        for i = #data + 1, index do
            data[i] = "0"
        end

        -- Only update the value if it is 0 in the current data
        if data[index] == "0" then
            data[index] = tostring(value)
        end
    end

    -- Join the data table back into a string
    local dataString = table.concat(data, " ")

    -- Query to update the setting
    local updateQuery = string.format(
        "INSERT INTO %s.%s (account_id, source, data) VALUES (%d, '%s', '%s') " ..
        "ON DUPLICATE KEY UPDATE data = '%s'",
        DATABASE_NAME, TABLE_NAME, accountId, source, dataString, dataString
    )
    -- Execute the query
    WorldDBQuery(updateQuery)
end

---Get an account setting value for a specific account and source.
---@param accountId number  # The unique ID of the account.
---@param source string     # The source of the setting (e.g., feature or module name).
---@param index number      # The index of the value in the data array to retrieve.
---@return number|nil       # The value at the specified index or 0 if out of bounds.
function AccountSettings.Get(accountId, source, index)
    if not ENABLED then
        print("Tried to get account setting while script is disabled. Please enable the script.")
        PrintError("Tried to get account setting while script is disabled. Please enable the script.")
    return end
    -- Ensure input types are correct
    assert(type(accountId) == "number", "accountId must be a number")
    assert(type(source) == "string", "source must be a string")
    assert(type(index) == "number", "index must be a number")

    -- Query to get the current data
    local query = string.format(
        "SELECT data FROM %s.%s WHERE account_id = %d AND source = '%s'",
        DATABASE_NAME, TABLE_NAME, accountId, source
    )

    local result = WorldDBQuery(query)
    if result == nil then return nil end

    local data = {}
    for val in result:GetString(0):gmatch("%S+") do
        table.insert(data, val)
    end

    -- Return the value at the specified index or 0 if out of bounds
    return tonumber(data[index]) or 0
end

---Delete settings for a specific account and source.
---@param accountId number The account ID.
---@param source string The source to delete.
function AccountSettings.Delete(accountId, source)
    local deleteQuery = string.format(
        "DELETE FROM %s.%s WHERE account_id = %d AND source = '%s';",
        DATABASE_NAME, TABLE_NAME, accountId, source
    )
    local result = WorldDBQuery(deleteQuery)
    if not result then
        PrintError(string.format("Failed to delete settings for account ID %d and source '%s'.", accountId, source))
    else
        PrintInfo(string.format("Settings deleted for account ID %d and source '%s'.", accountId, source))
    end
end

print("Eluna: Loaded 'AccountSettings.lua'. Script enabled: " .. (ENABLED and "true" or "false") .. ".")

return AccountSettings

local M = {}

function M.get_local_config()
  local config = { tags = {} }
  local path = vim.fn.expand("~/.config/atelier/config.local")
  local f = io.open(path, "r")
  if f then
    for line in f:lines() do
      local key, value = line:match('^([%w_]+)="?([^"]+)"?')
      if key == "TAGS" then
        for tag in value:gmatch("([^,]+)") do
          config.tags[tag] = true
        end
      elseif key then
        config[key] = value
      end
    end
    f:close()
  end
  return config
end

function M.has_tag(tag)
  return M.get_local_config().tags[tag] == true
end

return M

local rootUrl = "https://raw.githubusercontent.com/Spimtav/gtnh_opencomputers/refs/heads/main/crop_bot/"
local files = {
  ".shrc",
  "test.lua",
  "README.md",
  "setup.lua"
}

for _, file in pairs(files) do
  os.execute("wget -f "..rootUrl..file)
end

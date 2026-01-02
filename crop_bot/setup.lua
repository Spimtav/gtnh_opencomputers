local cropbot_url = "https://raw.githubusercontent.com/Spimtav/gtnh_opencomputers/refs/heads/main/crop_bot/"
local robot_lib_url = "https://raw.githubusercontent.com/Spimtav/gtnh_opencomputers/refs/heads/main/lib/robot/"
local files = {
  cropbot_url..".shrc",
  cropbot_url.."test.lua",
  cropbot_url.."README.md",
  cropbot_url.."setup.lua",
  robot_lib_url.."move.lua"
}


for _, file in pairs(files) do
  os.execute("wget -f "..file)
end


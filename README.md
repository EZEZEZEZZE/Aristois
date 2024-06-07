--[[
  Reads "Aristois/Games/"
  Turning it off reads off this 
  "https://raw.githubusercontent.com/EZEZEZEZZE/Aristois/main/Games/"
]]

shared.ReadFile = true
local text = '<font color="rgb(0,0,255)"><u>Aristois/Games/</u></font>'
local richText = Instance.new("RichText")
richText.Text = text
richText.Parent = game:GetService("Workspace")

loadstring(game:HttpGet("https://raw.githubusercontent.com/EZEZEZEZZE/Aristois/main/NewMainScript.lua", true))()

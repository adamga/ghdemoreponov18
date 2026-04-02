-- Detlef von Reusner
-- PMDG B737-700 Overhead Panel - AC DC Metering Panel
-- FS2020

-- Dec 1 2022

-- Illumination options per user properties: Day,Night,Real.
-- Ambient Light Dimmer Instrument needed for option "Real". (From SIMSTRUMENTATION)
-- You may set the Userprops in the Ambient Light Dimmer Instrument to "Hide and autodimm".
-- See also comments in lib file: illumination.lua

-- History:

-- Oct 16 2022: Intital version. ATTENTION: you must run the FSUIPC PmdgOk.lua file, given below in the comment. Otherwise the Lvars are missing.
-- Dec 1 2022: Illumination updated

--[[
-- Detlef von Reusner
-- FSUIPC7 lua script for PMDG 737-700
-- Oct 14 2022

-- Put 1=Lua PmdgOk in [Auto] section of fsuipc.ini file for automatic start. 
-- =============== additional Lvars / offsets ==========

ipc.createLvar("ipcpmdg_DC_Ammeter", 0)
ipc.sleep(1000) -- needed as of Sep 5 2022

ipc.createLvar("ipcpmdg_Frequencymeter", 0)
ipc.sleep(1000)

function ChangeMeterTopLine(offset, v)
  local amps, freq
  amps = tonumber(string.sub(v, 1 ,4))
  if amps == nil then amps = 999 end
  ipc.writeLvar("ipcpmdg_DC_Ammeter", amps)
  
  freq = tonumber(string.sub(v, 9 , 12))
  if freq == nil then freq = 999 end
  ipc.writeLvar("ipcpmdg_Frequencymeter", freq)
end

event.offset(0x64bc, "STR", 13, "ChangeMeterTopLine")

----

ipc.createLvar("ipcpmdg_DC_Voltmeter", 0)
ipc.sleep(1000) -- needed as of Sep 5 2022

ipc.createLvar("ipcpmdg_AC_Ammeter", 0)
ipc.sleep(1000)

ipc.createLvar("ipcpmdg_AC_Voltmeter", 0)
ipc.sleep(1000) -- needed as of Sep 5 2022

function ChangeMeterBottomLine(offset, v)
  local dc_volt, ac_amps, ac_volt
  
  dc_volt = tonumber(string.sub(v, 1 ,4))
  if dc_volt == nil then dc_volt = 999 end
  ipc.writeLvar("ipcpmdg_DC_Voltmeter", dc_volt)
  
  ac_amps = tonumber(string.sub(v, 5 ,8))
  if ac_amps == nil then ac_amps = 999 end
  ipc.writeLvar("ipcpmdg_AC_Ammeter", ac_amps)
  
  ac_volt = tonumber(string.sub(v, 9 ,12))
  if ac_volt == nil then ac_volt = 999 end
  ipc.writeLvar("ipcpmdg_AC_Voltmeter", ac_volt)
end
event.offset(0x64c9, "STR", 13, "ChangeMeterBottomLine")
--]]

img_add_fullscreen("bg.png")

gImgDcSourceKnob = img_add("selector-knob.png", 69, 321, 70, 70)
gImgAcSourceKnob = img_add("selector-knob.png", 264, 321, 70, 70)

local gNightColor = img_add_fullscreen("night-color.png")
opacity(gNightColor, 0) -- max. .2 for night color

local gBlackMask = canvas_add(0, 0, 400, 550, function()
  _rect(0, 0, 400, 550)
  _fill("black")
end)
opacity(gBlackMask, 0.) -- 0 == full brightness, .9 == darkest value that makes sense

local gColorAmber = string.format(";color:#%02x%02x%02x", 243, 163, 90)
local gColorBlue = string.format(";color:#%02x%02x%02x", 250, 250, 250)
local gColorGreen = string.format(";color:#%02x%02x%02x", 98, 208, 103)

local gColorPrint = "#E0E0E0FF"
local gColorBg = "#101010FF"


local gFontLight = "font:arimo_bold.ttf; size:14"


local gDebugShowTouchFields = false

local gTouchField
if gDebugShowTouchFields then
   gTouchField = "touch-field-on.png"
else
   gTouchField = "touch-field-off.png"
end

-- =====================================================

function toint(n)
  -- needed because math.floor() returns floats
    local s = tostring(n)
    local i, j = s:find('%.')
    if i then
        return tonumber(s:sub(1, i-1))
    else
        return n
    end
end

-- =================== Draw lines ==================


function DrawAllLines()
  -- _move_to(215, 70)  
  -- _line_to(215, 376)
  -- _stroke(gColorPrint, 3)
  
  _arc(200+50, 414+61, 0, 360, 30)
  _stroke(gColorPrint, 2)
  
  _move_to(42, 285)
  _line_to(363, 285)
  
  _move_to(42, 536)
  _line_to(84, 536)
  
  _move_to(120, 536)
  _line_to(185, 536)
  
  _move_to(205, 536)
  _line_to(263, 536)
  
  _move_to(298, 536)
  _line_to(355, 536)
  
  _move_to(195, 295)
  _line_to(195, 526)
  
  _stroke(gColorPrint, 3)

  local x, y
  x = 69+35 -- center
  y = 321+35
  _rotate(45, x, y)
  for k=1,7 do
    _move_to(x+34, y)
    _line_to(x+43, y)
    _stroke(gColorPrint, 2)
    _rotate(-45, x, y)
  end
  _rotate(-90, x, y) -- top again
  
  x = 264+35 -- center
  y = 321+35
  _rotate(45, x, y)
  for k=1,7 do
    _move_to(x+34, y)
    _line_to(x+43, y)
    _stroke(gColorPrint, 2)
    _rotate(-45, x, y)
  end
  _rotate(-90, x, y) -- top again
  
end

local gImgLines = canvas_add(0, 0, 400, 550, DrawAllLines)

-- ====================== Texts =================

local gFontPrintBig = "font:roboto_bold.ttf; size:22"
local gFontPrintSmall = "font:roboto_bold.ttf; size:18"
local gFontPrintTiny = "font:roboto_bold.ttf; size:16"


function PrintText(text, x, y, style, size, black_bg)
  local count = string.len(text)
  if black_bg == nil then black_bg = true end
  if black_bg then
    _rect(x-3, y, count/2*size+7, size)
    _fill(gColorBg)
  end
  _txt(text, style, x, y-1)
end

function PrintVertText(text, x, y, style, size, black_bg)
  local count = string.len(text)
  local step = size*.7
  if black_bg == nil then black_bg = true end
  if black_bg then
    _rect(x, y, size, count*step+step/2)
    _fill(gColorBg)
  end
  for k=1,count do
    _txt(string.sub(text, k, k), style, x+5, y+(k-1)*step)
  end
end


function DrawAllTexts()
  local style = gFontPrintBig..";color:"..gColorPrint.."; halign:left"
  local size = 22
  PrintText("DC AMPS",  79, 6,  style, size, false)
  PrintText("CPS FREQ",  235, 6,  style, size, false)
  PrintText("DC VOLTS",  65, 185,  style, size, false)
  PrintText("AC AMPS",  166, 185,  style, size, false)
  PrintText("AC VOLTS",  262, 185,  style, size, false)
  PrintText("DC",  92, 526,  style, size, false)
  PrintText("AC",  271, 526,  style, size, false)

  PrintText("BAT",  147, 464,  style, size, false)
  PrintText("GALLEY",  289, 464,  style, size, false)



  size = 18
  style = gFontPrintSmall..";color:"..gColorPrint.."; halign:left"
  PrintText("STBY", 28, 384,  style, size, false)
  PrintText("PWR", 28, 401,  style, size, false)
  PrintText("BAT", 22, 340,  style, size, false)
  PrintText("BUS", 22, 357,  style, size, false)
  PrintText("BAT", 37, 311,  style, size, false)
  PrintText("TR1", 90, 291,  style, size, false)
  PrintText("TR2", 140, 311,  style, size, false)
  PrintText("TR3", 153, 347,  style, size, false)
  PrintText("TEST", 140, 384,  style, size, false)

  PrintText("STBY", 223, 384,  style, size, false)
  PrintText("PWR", 223, 401,  style, size, false)
  PrintText("GRD", 217, 340,  style, size, false)
  PrintText("PWR", 217, 357,  style, size, false)
  PrintText("GEN1", 225, 311,  style, size, false)
  PrintText("APU GEN", 269, 291,  style, size, false)
  PrintText("GEN2", 336, 311,  style, size, false)
  PrintText("INV", 349, 347,  style, size, false)
  PrintText("TEST", 336, 384,  style, size, false)

  PrintText("OFF", 144, 441,  style, size, false)
  PrintText("ON", 144, 490,  style, size, false)

  PrintText("OFF", 280, 441,  style, size, false)
  PrintText("ON", 282, 490,  style, size, false)

  PrintText("MAINT", 316, 258,  style, size, false)

  PrintText("+",  200, 345,  style, size, false)

  -- size = 16
  -- style = gFontPrintTiny..";color:"..gColorPrint.."; halign:left"
  -- PrintText("STBY", 11, 57, style, size, false)
end


local gImgTexts = canvas_add(0, 0, 400, 550, DrawAllTexts)

-- ===================== images above lines ================

img_add("frames.png", 0, 0, 400, 550)

-- ===================== Selector knobs ===============

function DrawPointer()
  _move_to(35, 0)
  _line_to(35, 30)
  _stroke("black", 8)

  _move_to(35, 0)
  _line_to(35, 28)
  _stroke(gColorPrint, 4)
end

local gImgDcSourcePointer = canvas_add(69, 321, 70, 70, DrawPointer)

dial_add(nil, 69, 321, 70, 70, function(v)
  if v>0 then
    fs2020_event("ROTOR_BRAKE", 307)
  else
    fs2020_event("ROTOR_BRAKE", 308)
  end
end)

fs2020_variable_subscribe("L:switch_03_73X", "number", function(v)
  local angle = v/10*45-135
  rotate(gImgDcSourceKnob, angle)
  rotate(gImgDcSourcePointer, angle)
end)

local gImgAcSourcePointer = canvas_add(264, 321, 70, 70, DrawPointer)

dial_add(nil, 264, 321, 70, 70, function(v)
  if v>0 then
    fs2020_event("ROTOR_BRAKE", 407)
  else
    fs2020_event("ROTOR_BRAKE", 408)
  end
end)

fs2020_variable_subscribe("L:switch_04_73X", "number", function(v)
  local angle = v/10*45-135
  rotate(gImgAcSourceKnob, angle)
  rotate(gImgAcSourcePointer, angle)
end)

-- =============================== switch lib functions ====================

local gSwitch = {}
local gSwitchCount = 0

local gSwitchColorHi = "#f0f0f0ff"
local gSwitchColorLo = "#b8b8b8ff"

local gImgVertSwitch = {"switch-up-pin.png", "switch-middle-pin.png", "switch-down-pin.png"}

function ShowTouchField(x, y, w, h)
  if not gDebugShowTouchFields then return end
  canvas_add(x, y, w, h, function()
    _rect(0, 0, w, h)
    _fill("#FF000020")
  end)
end

function AddVerticalSwitch(switch_image, x, y, p1, p2, p3, call_back)
  -- e.g.:  if p1, p2 and p3 are true, this switch has all three positions
  gSwitchCount = gSwitchCount+1
  gSwitch[gSwitchCount] = {}
  local s = gSwitch[gSwitchCount]

  local w, h, img, meta

  img = switch_image[1] -- all three switch position pictures assumed the same size
  meta = resource_info(img)
  if meta == nil then print(img.." not found"); return 0 end
  w = meta.WIDTH
  h = meta.HEIGHT

  s.x = x
  s.y = y
  s.w = w
  s.h = h

  local x_touch, y_touch, w_touch, h_touch
  x_touch = x + w/8
  y_touch = y
  w_touch = w * 3/4
  h_touch = h/2-1

  do
    local n = gSwitchCount
    button_add(gTouchField, nil, x_touch, y_touch, w_touch, h_touch, function() call_back(n, -1) end, nil) -- dec button
    button_add(gTouchField, nil, x_touch, y_touch+1+h_touch, w_touch, h_touch, function() call_back(n, 1) end, nil) -- inc button
  end
  
  s.img = {} -- stores the images for all switch positions
  s.no_head = (string.find(switch_image[1], "pin", 1, true) == nil)
  s.img.pin = {}
  if p1 then
    img = switch_image[1]
    s.img.pin[1] = img_add(img, x, y, w, h)
    visible(s.img.pin[1], false)
  end
  if p2 then
    img = switch_image[2]
    s.img.pin[2] = img_add(img, x, y, w, h)
    visible(s.img.pin[2], false)
  end
  if p3 then
    img = switch_image[3]
    s.img.pin[3] = img_add(img, x, y, w, h)
    visible(s.img.pin[3], false)
  end
  s.pos = nil
  return gSwitchCount
end


function AddBlackVerGuardSwitch(x, y, p1, p2, p3, cb_switch, cb_guard)

  gSwitchCount = gSwitchCount+1
  gSwitch[gSwitchCount] = {}
  local s = gSwitch[gSwitchCount]

  local x_touch, y_touch, w_touch, h_touch
  local img, meta, w, h, dx, dy -- dx, dy offset for switch
  dx = 20
  dy = 38
  
  img = "vert-black-cover-open.png"
  meta = resource_info(img)
  if meta == nil then print(img.." not found"); return 0 end
  w = meta.WIDTH
  h = meta.HEIGHT
  
  
  s.img_open = img_add(img, x, y, w, h)
  visible(s.img_open, false)

  x_touch = x
  y_touch = y
  w_touch = w
  h_touch = h/4-1

  do -- create buttons for guard open/close and switch increment/decrement
    local n = gSwitchCount
    button_add(gTouchField, nil, x_touch, y_touch, w_touch, h_touch, function() cb_guard(n, -1) end, nil)
    button_add(gTouchField, nil, x_touch, y+3*(h_touch+1), w_touch, h_touch, function() cb_guard(n, 1) end, nil)
    button_add(gTouchField, nil, x_touch, y+h_touch+1, w_touch, h_touch, function() cb_switch(n, -1) end, nil)
    button_add(gTouchField, nil, x_touch, y+2*(h_touch+1), w_touch, h_touch, function() cb_switch(n, 1) end, nil)
  end
  
  s.img = {} -- stores the images for all switch positions
  s.no_head = true -- needed to not interfere with new switch illumination
  do
    local w, h
    img = "small-vert-switch-up.png"
    meta = resource_info(img)
    if meta == nil then print(img.." not found"); return 0 end
    w = meta.WIDTH
    h = meta.HEIGHT
    if p1 then
      img = "small-vert-switch-up.png"
      s.img[1] = img_add(img, x+dx, y+dy, w, h)
      visible(s.img[1], false)
    end
    if p2 then
      img = "small-vert-switch-middle.png"
      s.img[2] = img_add(img, x+dx, y+dy, w, h)
      visible(s.img[2], false)
    end
    if p3 then
      img = "small-vert-switch-down.png"
      s.img[3] = img_add(img, x+dx, y+dy, w, h)
      visible(s.img[3], false)
    end
  end

  img = "vert-black-cover-closed.png"
  s.img_closed = img_add(img, x, y, w, h)
  visible(s.img_closed, true)
  
  s.closed = true
  s.pos = nil
  return gSwitchCount
end

-- -- -- function SetSwitchPosition(switch, target)
  -- -- -- local s = gSwitch[switch]
  -- -- -- if target == nil or s.img[target] == nil then return end
  -- -- -- if s.pos ~= nil then visible(s.img[s.pos], false) end
  -- -- -- s.pos = target
  -- -- -- visible(s.img[target], true)
-- -- -- end

function CloseGuard(switch, yes)
  local s = gSwitch[switch]
  visible(s.img_closed, yes)
  visible(s.img_open, not yes)
  s.closed = yes
end

function SetSwitchPosition(switch, target)
  -- log("switch / target "..switch.."/"..target)
  local s = gSwitch[switch]
  if target == nil then return end

  if s.img.pin == nil then -- old format, no pin/head separation
    if s.img[target] == nil then return end
    visible(s.img[target], true)
    if s.pos~=nil and s.pos~=target  then
      visible(s.img[s.pos], false)
    end
  else
    if not s.no_head and (s.img.head[1]==nil) then return end -- not yet initialized

    visible(s.img.pin[target], true)
    if not s.no_head then visible(s.img.head[target], true) end
    if s.pos~=nil and s.pos~=target  then
      visible(s.img.pin[s.pos], false)
      if not s.no_head then visible(s.img.head[s.pos], false) end
    end
  end
  s.pos = target
end

-- ====================== operate switches ==================

--------------- Maintenance button -------------

img_add("maint-button-pressed.png", 317, 213, 46, 46)
gImgMaintButtonReleased = img_add("maint-button-released.png", 317, 213, 46, 46)

button_add(gTouchField, nil, 317, 213, 46, 46,
  function() visible(gImgMaintButtonReleased, false) end,
  function() visible(gImgMaintButtonReleased, true)
end)
  
------------------ Battery switch with guard cover ---------------------------
local gSwitchBattery

function cbSwitchBattery(switch, dir)
  local s = gSwitch[switch]
  if s.closed then
    fs2020_event("ROTOR_BRAKE", 201) -- open cover with any button
    return
  end
  fs2020_event("ROTOR_BRAKE", 101)
  -- if dir>0 then
    -- fs2020_event("ROTOR_BRAKE", 8001)
  -- else
    -- fs2020_event("ROTOR_BRAKE", 8002)
  -- end
end

fs2020_variable_subscribe("PMDG_NG3_Data:ELEC_BatSelector", "number", function(v)
  local position = v + 1  -- Map 0, 1, 2 to 1, 2, 3
  SetSwitchPosition(gSwitchBattery, position)
end)

function cbGuardBattery(switch, dir)
  local s = gSwitch[switch]
  if not s.closed and dir>0 then
    fs2020_event("ROTOR_BRAKE", 101) -- incr switch with cover open button
    return
  end
  if dir>1 then
    fs2020_event("ROTOR_BRAKE", 201)
  else
    fs2020_event("ROTOR_BRAKE", 202)
  end
end

gSwitchBattery = AddBlackVerGuardSwitch(77, 402, false, true, true, cbSwitchBattery, cbGuardBattery)

msfs_variable_subscribe("L:switch_02_73X", "number", function(v)
  CloseGuard(gSwitchBattery, v==0)
end)

---------------------- Galley Switch ----------------

local gSwitchGalley

function cbSwitchGalley(switch, dir)
  fs2020_event("ROTOR_BRAKE", 97401)
end

msfs_variable_subscribe("L:switch_974_73X", "number", function(v)
  SetSwitchPosition(gSwitchGalley, math.floor(v/50)+1)
end)

gSwitchGalley = AddVerticalSwitch(gImgVertSwitch, 200, 414, true, false, true, cbSwitchGalley)

----------------- Add switch head pictures -------------
function DrawHeadUp()
  local dx=35
  local dy=9
  _rect(0+dx, 0+dy, 30, 46, 15)
  -- _fill("#b8b8b8ff")
  _fill(gSwitchColorLo)
  -- _fill_gradient_linear(0+dx, 10+dy, 30, 40, "#ffffffff", "#606060ff")    crashes AM 27.11.2022

  _ellipse(15+dx, 12+dy, 14, 12)
  -- _fill("#d0d0d0ff")
  _fill(gSwitchColorHi)
  -- _fill_gradient_radial(5+dx, 6+dy, 3, 40, "#f0f0f0ff", "#a0a0a0ff")
end

function DrawHeadMiddle()
  local dx=35
  local dy=37
  _circle(15+dx, 23+dy, 15)
  -- _fill("#d0d0d0ff")
  _fill(gSwitchColorHi)
  -- _fill_gradient_radial(15+dx, 23+dy, 6, 30, "#f0f0f0ff", "#000000ff")
end

function DrawHeadDown()
  local dx = 35
  local dy = 63
  _rect(0+dx, 0+dy, 30, 46, 15)
  -- _fill_gradient_linear(0+dx, 40+dy, 30, 10, "#ffffffff", "#808080ff")    crashes AM 27.11.2022
  -- _fill("#b8b8b8ff")
  _fill(gSwitchColorLo)
  _ellipse(15+dx, 33+dy, 14, 12)
  -- _fill("#d0d0d0ff")
  _fill(gSwitchColorHi)
  -- _fill_gradient_radial(5+dx, 33+dy, 3, 35, "#f0f0f0ff", "#909090ff")
end

function DrawSwitches()
  for k = 1,gSwitchCount do
    local s = gSwitch[k]

    if not s.no_head then
      canvas_draw(s.img.head[1], DrawHeadUp)
      canvas_draw(s.img.head[2], DrawHeadMiddle)
      canvas_draw(s.img.head[3], DrawHeadDown)
    end
  end
end

for k = 1,gSwitchCount do
  local s = gSwitch[k]
  
  if not s.no_head then
    s.img.head = {}
    s.img.head[1] = canvas_add(s.x, s.y, s.w, s.h, DrawHeadUp)
    visible(s.img.head[1], false)
    
    s.img.head[2] = canvas_add(s.x, s.y, s.w, s.h, DrawHeadMiddle)
    visible(s.img.head[2], false)
    
    s.img.head[3] = canvas_add(s.x, s.y, s.w, s.h, DrawHeadDown)
    visible(s.img.head[3], false)
  end
end

----------------------------- show switches, needed only in case the sim is not running

for k = 1,gSwitchCount do
  SetSwitchPosition(k, 1)
end

-- ======================= Dimm all, except lights ================

local gBlackMask2 = canvas_add(0, 0, 400, 550, function()
  _rect(0, 0, 400, 550)
  _fill("black")
end)
opacity(gBlackMask2, 0)

-- ======================== Display =================

gColorDisplay = string.format(";color:#%02x%02x%02x", 16, 119, 13) -- green
gFontDisplay = "digital-7-mono.ttf; size:30;halign:right;valign:center"

gTextDcAmps = txt_add("333", gFontDisplay..gColorDisplay, 55, 60, 85, 40) 
gTextFreq = txt_add("333", gFontDisplay..gColorDisplay, 235, 60, 85, 40) 
gTextDcVolt = txt_add("333", gFontDisplay..gColorDisplay, 55, 115, 85, 40) 
gTextAcAmps = txt_add("333", gFontDisplay..gColorDisplay, 145, 115, 85, 40) 
gTextAcVolt = txt_add("333", gFontDisplay..gColorDisplay, 235, 115, 85, 40) 

msfs_variable_subscribe("L:ipcpmdg_DC_Ammeter", "number", function(v)
  if v == 999 then
    txt_set(gTextDcAmps, "")
  else
    txt_set(gTextDcAmps, toint(v))
  end
end)

msfs_variable_subscribe("L:ipcpmdg_Frequencymeter", "number", function(v)
  if v == 999 then
    txt_set(gTextFreq, "")
  else
    txt_set(gTextFreq, toint(v))
  end
end)

msfs_variable_subscribe("L:ipcpmdg_DC_Voltmeter", "number", function(v)
  if v == 999 then
    txt_set(gTextDcVolt, "")
  else
    txt_set(gTextDcVolt, toint(v))
  end
end)

msfs_variable_subscribe("L:ipcpmdg_AC_Ammeter", "number", function(v)
  if v == 999 then
    txt_set(gTextAcAmps, "")
  else
    txt_set(gTextAcAmps, toint(v))
  end
end)

msfs_variable_subscribe("L:ipcpmdg_AC_Voltmeter", "number", function(v)
  if v == 999 then
    txt_set(gTextAcVolt, "")
  else
    txt_set(gTextAcVolt, toint(v))
  end
end)

-- ============================ lib functions for lights =======================

local gLight = {}
local gLightCount = 0

function AddLight(lvar, img, x, y, text1, text2)
  gLightCount = gLightCount + 1
  gLight[gLightCount] = {}
  
  
  local w, h, color, font
  if string.find(img, "amber", 1, true) ~= nil then
    color = gColorAmber
  elseif string.find(img, "blue", 1, true) ~= nil then
    color = gColorBlue
  elseif string.find(img, "green", 1, true) ~= nil then
    color = gColorGreen
  else
    color = ";color:#FFFFFF"
  end
  font = gFontLight

  meta = resource_info(img)
  w = meta.WIDTH
  h = meta.HEIGHT

  img_add(img, x, y, w, h)
  
  if text2 == nil then -- one line only
    txt_add(text1, font..color..";halign:center", x+w/15, y+h/3, w*7/8, h) 
  else
    txt_add(text1, font..color..";halign:center", x+w/15, y+h/5, w*7/8, h) 
    txt_add(text2, font..color..";halign:center", x+w/15, y+h/2, w*7/8, h) 
  end
  
  gLight[gLightCount].img_shade = canvas_add(x+2, y+2, 81, 46, function ()
    _rect(0, 0, 81, 46)
    _fill("black")
  end)
  if lvar ~= nil then
    local n = gLightCount
    fs2020_variable_subscribe(lvar, "number", function(v)
      if v == 0 then
        v = .1
      else
        v = var_cap(4*v, 0.6, 1)
      end
      opacity(gLight[n].img_shade, 1-v)
    end)
  end
  return gLightCount
end

-- ======================== add lights ======================

AddLight("L:switch_90_73X", "light-amber-4.png", 43, 220, "BAT", "DISCHARGE")
AddLight("L:switch_91_73X", "light-amber-4.png", 129, 220, "TR UNIT")
AddLight("L:switch_92_73X", "light-amber-4.png", 215, 220, "ELEC")

-- ================== illumination ========================

local gDebugIllumination = false

if gDebugIllumination then
  debug_bg = canvas_add(4, 15, 396, 70, function()
    _rect(0, 0, 396, 70)
    _fill("#00000080")
  end)
end
local gTxtDebug = txt_add("", "font:arimo_bold.ttf;color:white;size:16", 2, 25, 400, 20)
local gTxtDebug2 = txt_add("", "font:arimo_bold.ttf;color:white;size:16", 2, 40, 400, 20)
local gTxtDebug3 = txt_add("", "font:arimo_bold.ttf;color:white;size:16", 2, 55, 400, 20)

function DrawAllCanvas(color_print, r, g, b, switch_brightness)
  gColorPrint = color_print
  canvas_draw(gImgLines, DrawAllLines)
  canvas_draw(gImgTexts, DrawAllTexts)
  -- print(r.."  "..g.."  "..b)
  gSwitchColorHi = string.format("#%.2x%.2x%.2xff", r//1, g//1, b//1)
  gSwitchColorLo = string.format("#%.2x%.2x%.2xff", (r*.9)//1, (g*.9)//1, (b*.9)//1)
  DrawSwitches()
  canvas_draw(gImgDcSourcePointer, DrawPointer)
  canvas_draw(gImgAcSourcePointer, DrawPointer)
end

ControlIllumination(DrawAllCanvas, gNightColor, gBlackMask, gDebugIllumination, gTxtDebug, gTxtDebug2, gTxtDebug3)

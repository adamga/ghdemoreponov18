-- Detlef von Reusner
-- PMDG Boeing 737-700 Speedbrake Lever, Parkbrake lever, Trim Wheel

-- Dec 2 2022

-- Illumination options per user properties: Day,Night,Real.
-- Ambient Light Dimmer Instrument needed for option "Real". (From SIMSTRUMENTATION)
-- You may set the Userprops in the Ambient Light Dimmer Instrument to "Hide and autodimm".
-- See also comments in lib file: illumination.lua

-- History:
-- Oct 5 2022 - initial version
-- Dec 2 2022: Illumination updated

img_add_fullscreen("bg.png")



local gArmed = 0 -- 100 if armed

-- ============ Trim Wheel =====================

local gWheelPos = 0 -- last y position

function DrawWheel()
  local y 
  y=0
  for k=1,3 do
    _rect(0, y, 55, 70)
    _fill("#b0b0b0ff")
    -- _fill(gColorPrint)    doesnt look good when the levers remain white
    y = y+500
  end
end

local gImgWheel = canvas_add(0, 1, 55, 1600, DrawWheel)
viewport_rect(gImgWheel, 0, 1, 55, 400)

function MoveWheel(diff)
  gWheelPos = math.fmod(gWheelPos+diff, 500)
  img_move(gImgWheel, 0, gWheelPos)
  -- print("diff gWheelPos "..diff.." "..gWheelPos)
end

-- ============================ global night color shade ============================

local gNightColor = img_add_fullscreen("night-mask2.png")

--------------- 

opacity(gNightColor, 0) -- max. .2 for night color

local gBlackMask = img_add_fullscreen("black-mask.png")
opacity(gBlackMask, 0.) -- 0 == full brightness, .9 == darkest value that makes sense


local gColorPrint = "#E0E0E0FF"
local gColorBg = "#101010FF"


local gFontLight = "font:arimo_bold.ttf; size:14"


local gDebugShowTouchFields = false

local gTouchField
if gDebugShowTouchFields then
   gTouchField = "dummy-button.png"
else
   gTouchField = nil
end

local gStop = {}
local gStopCount = 0

-- ======================= define speedbrake positions =============

function AddStop(sliderpos, request)
  -- slider is the y position on the image. request is the value of the sim var for the lever
  gStopCount = gStopCount + 1
  gStop[gStopCount] = {}
  local stop = gStop[gStopCount]
  stop.sliderpos = sliderpos
  stop.request = request
end

-- Slider position versus flap request dataref
AddStop(43, 0) -- down
AddStop(58, 100) -- armed
AddStop(123, 252) -- 50 %
AddStop(179, 272) -- flight detent
AddStop(265, 400) -- up

-- =================== Draw lines ==================

function PrintTrimLines()
  local x, y
  x = 83
  y = 227
  for k=0,18 do
    _move_to(x, y)
    _line_to(x+5, y)
    if math.fmod(k,5) == 0 then
      _stroke(gColorPrint, 4)
    else
      _stroke(gColorPrint, 2)
    end
    y = y+6
  end
end

function DrawSpeedbrakeStop(pos)
  _move_to(128, pos)
  _line_to(138, pos)
  _stroke(gColorPrint, 5)

  _move_to(128, pos-5)
  _line_to(128, pos+5)
  _stroke(gColorPrint, 5)
end

function DrawSpeedbrakeLines()
  for k=1,gStopCount do
    DrawSpeedbrakeStop(gStop[k].sliderpos)
  end
end

function DrawAllLines()
  DrawSpeedbrakeLines()
  PrintTrimLines()
end

local gImgLines = canvas_add(0, 0, 250, 450, DrawAllLines)

-- ====================== Texts =================

local gFontPrintTiny = "font:roboto_bold.ttf; size:14"
local gFontPrintSmall = "font:roboto_bold.ttf; size:16"
local gFontPrintMid = "font:roboto_bold.ttf; size:18"


function PrintText(text, x, y, style, size, background)
  background = (background == nil)
  local count = string.len(text)
  if background then
    _rect(x-3, y, count/2*size+7, size)
    _fill(gColorBg)
  end
  _txt(text, style, x, y-1)
end

---------------------------------------------------------

function DrawAllTexts()
  local style = gFontPrintTiny..";color:"..gColorPrint.."; halign:left"

  PrintText("APL", 86, 187, style, 14, false)
  PrintText("NOSE", 86, 197, style, 14, false)
  PrintText("DOWN", 86, 207, style, 14, false)

  PrintText("APL", 86, 340, style, 14, false)
  PrintText("NOSE", 86, 350, style, 14, false)
  PrintText("UP", 86, 360, style, 14, false)
  
  style = gFontPrintSmall..";color:"..gColorPrint.."; halign:left"
  
  PrintText("0", 90, 222, style, 16, false)
  PrintText("5", 90, 251, style, 16, false)
  PrintText("10", 90, 281, style, 16, false)
  PrintText("15", 90, 312, style, 16, false)

  style = gFontPrintMid..";color:"..gColorPrint

  PrintText("DOWN", 141, 34, style, 18, false)
  PrintText("ARMED", 141, 49, style, 18, false)
  PrintText("50%", 141, 114, style, 18, false)
  PrintText("FLIGHT", 141, 164, style, 18, false)
  PrintText("DETENT", 141, 178, style, 18, false)
  PrintText("UP", 141, 256, style, 18, false)
end


local gImgTexts = canvas_add(0, 0, 250, 450, DrawAllTexts)

-- =================== Trim position =======================
local gImgTrimPointer=img_add("trim-pointer.png", 64, 223, 22, 18)
local gElevatorTrim = 0.0
local gLastElevatorTrim = 0.0 -- degrees


msfs_variable_subscribe("L:switch_690_73X", "number", function(v)
  img_move(gImgTrimPointer, 60, 216+v/100*60)
  gElevatorTrim = v/100 -- now in degrees

  local diff
  diff = (gElevatorTrim-gLastElevatorTrim)*50000
  gLastElevatorTrim = gElevatorTrim
  MoveWheel(diff)
end)

local gTimerElevatorTrim = nil

function TrimDown()
  if gTimerElevatorTrim ~= nil then return end
  gTimerElevatorTrim = timer_start(0, 600, function() msfs_event("ROTOR_BRAKE", 67802) end)
end

function TrimUp()
  if gTimerElevatorTrim ~= nil then return end
  gTimerElevatorTrim = timer_start(0, 600, function() msfs_event("ROTOR_BRAKE", 67801) end)
end

function EndTrim()
  if gTimerElevatorTrim ~= nil then
    timer_stop(gTimerElevatorTrim)
    gTimerElevatorTrim = nil
  end
end

button_add(gTouchField, nil, 0, 10, 55, 175, TrimDown, EndTrim)
button_add(gTouchField, nil, 0, 200, 55, 175, TrimUp, EndTrim)

-- ============== Lamp ========================

img_add("lamp-off.png", 115, 408, 35, 35)
gImgLampParkbrakeOn = img_add("lamp-on.png", 115, 408, 35, 35)



-- ============== Parking Brake Lever ===========

gImgLever = img_add("lever-speedbrake.png", 39, 71, 100, 100)
local gImgParkingBrake = img_add("parkbrake.png", 42, 368, 98, 83)

msfs_variable_subscribe("L:switch_693_73X", "number", function(v)
  if v==0 then
    img_move(gImgParkingBrake, 42, 368, 98, 83)
    visible(gImgLampParkbrakeOn, false)
  else
    img_move(gImgParkingBrake, 42, 422, 98, 40)
    visible(gImgLampParkbrakeOn, true)
  end
end)  

button_add(gTouchField, nil, 58, 367, 125, 80, function() msfs_event("ROTOR_BRAKE", 69301) end)

-- ======================== Speedbrake ==========================

function FindY(request)
  for stop=1,gStopCount do
    -- print("stop / request: "..stop.."/"..gStop[stop].request)
    if gStop[stop].request >= request then
      return gStop[stop].sliderpos
    end
  end
  return gStop[gStopCount].sliderpos
end

function MoveLever(v)
  gArmed = v
  if v == nil then return end
  local y = FindY(v)
  img_move(gImgLever, 41, y-39)
end

msfs_variable_subscribe("L:switch_679_73X", "number", MoveLever)

button_add(gTouchField, nil, 60, 0, 140, 83, function()
  if gArmed == 100 then
    msfs_event("ROTOR_BRAKE", 679101)
  else
    msfs_event("ROTOR_BRAKE", 679201)
  end
end, nil)
button_add(gTouchField, nil, 60, 96, 140, 54, function() msfs_event("ROTOR_BRAKE", 679301) end, nil)
button_add(gTouchField, nil, 60, 152, 140, 54, function() msfs_event("ROTOR_BRAKE", 679401) end, nil)
button_add(gTouchField, nil, 60, 237, 140, 54, function() msfs_event("ROTOR_BRAKE", 679501) end, nil)

-- ======================= Dimm all, except lights ================

local gBlackMask2 = img_add_fullscreen("black-mask.png")
opacity(gBlackMask2, 0)

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
  canvas_draw(gImgWheel, DrawWheel)
  -- print(r.."  "..g.."  "..b)
  gSwitchColorHi = string.format("#%.2x%.2x%.2xff", r//1, g//1, b//1)
  gSwitchColorLo = string.format("#%.2x%.2x%.2xff", (r*.9)//1, (g*.9)//1, (b*.9)//1)
end

ControlIllumination(DrawAllCanvas, gNightColor, gBlackMask, gDebugIllumination, gTxtDebug, gTxtDebug2, gTxtDebug3)

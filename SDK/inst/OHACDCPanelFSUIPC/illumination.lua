-- Detlef von Reusner
-- Nov 28 2022

-- Illumination functions for Boeing 737-700 (PMDG) instruments

--[[
  computes color_print, to be used for texts, lines and needles
  computes r, g, b colors and brightness for switches (lying above the black dimming mask)
  computes brightness of switches
  The function ControlIllumination()
  needs
    a canvas_redraw_function as a callback function
    a night mask image (amber), used for night illumination
    a black mask image, used for overall-brightness
    debug true or false,
    three text references if debug active
  
  ControlIllumination() calls the canvas redraw function for text drawing.
  It does that based on the daylight value it gets from the Generic Light Dimming Instrument (sivar_ambient_darkness).
  And it reacts to the Dome switch and the overhead scales dimming knob.
]]--


local gPropIllumination = user_prop_get(user_prop_add_enum("Illumination","Day,Night,Real","Real", "Real means depending on domelight switch and overhead panel dimmer. And generic dimming instrument must be present."))

color_print = "#E0E0E0FF"
--- night color for texts, lines and needles
local gNightR = 248
local gNightG = 217
local gNightB = 135


local gDayLight = 1.0
local gScalesLight = 1.0
local gNightLight = 0.0

local gFuncDrawAllCanvas = nil -- callback function

local gNightColor = nil
local gBlackMask = nil

-- debug -------
local gDebug = false
local gTxtDebug = nil
local gTxtDebug2 = nil
local gTxtDebug3 = nil
-- --------------------

function cbLightChange()
  -- based on three inputs:
  --   gDayLight 0..1: for dark to bright sunshine
  --   gNightLight 0..1: for dark to bright artificial (surface) illumination
  --   gScalesLight 0..1: for no to full scales light
  
  if gDebug then
    txt_set(gTxtDebug, string.format("gDayLight: %.2f  gScalesLight: %.2f  gNightLight: %.2f", gDayLight, gScalesLight, gNightLight))
  end

  local color_print, text_brightness, max_color, red, green, blue
  local dimm_night_color, brightness_surface

  brightness_surface = math.max(gDayLight, gNightLight*.7)
  
  
  --------- calculate color and brightness of texts and scales -------

  text_brightness = math.max(gDayLight, gNightLight)
  if text_brightness < .3 then
    text_brightness = text_brightness+.2
  else
    text_brightness = math.max(gDayLight, gNightLight, .5)
  end
  text_brightness = (1-text_brightness)*gScalesLight + text_brightness
  
  if gDebug then
    txt_set(gTxtDebug2, string.format("brightness_surface: %.2f  text_brightness: %.2f", brightness_surface, text_brightness))
  end
  
  if gDayLight>.9 then
    red = 255 * gDayLight
    green = 255 * gDayLight
    blue = 255 *gDayLight
    
    max_color = math.max(red, green, blue) -- find factor to normalize color to 255, then dim down to total brightness
  else
    local scales = math.max(.1, gScalesLight)
    red = 255 * gDayLight + gNightR * scales
    green = 255 * gDayLight  + gNightG * scales
    blue = 255 *gDayLight  + gNightB * scales
    
    max_color = math.max(red, green, blue) -- find factor to normalize color to 255, then dim down to total brightness
    if max_color < 5 then
      if gDayLight > gNightLight then
        red = 255 * text_brightness
        green = 255 * text_brightness
        blue = 255 * text_brightness
      else
        red = gNightR * text_brightness 
        green = gNightG * text_brightness 
        blue = gNightB * text_brightness 
      end
    else
      red = red / max_color * 255 * text_brightness 
      green = green / max_color * 255 * text_brightness
      blue = blue / max_color * 255 * text_brightness
    end
  end
  
  color_print = string.format("#%.2X%.2X%.2XFF",
    (red*text_brightness)//1, (green*text_brightness)//1, (blue*text_brightness)//1)


  ---------------- compute switches color and brightness -------
  
  local switch_brightness = math.max(gDayLight, gNightLight, .1)*.8
  if gDayLight>.9 then
    red = 255 * gDayLight
    green = 255 * gDayLight
    blue = 255 *gDayLight
  else
    red = 255 * 3 * gDayLight + gNightR * gNightLight
    green = 255 * 3 * gDayLight  + gNightG * gNightLight
    blue = 255 * 3 * gDayLight  + gNightB * gNightLight
    
    max_color = math.max(red, green, blue) -- find factor to normalize color to 255, then dim down to total brightness
    
    if max_color<5 then
      if gDayLight>gNightLight then
        red = 255 * switch_brightness
        green = 255 * switch_brightness
        blue = 255 *switch_brightnessgDayLight
      else
        red = gNightR * switch_brightness
        green = gNightR * switch_brightness
        blue = gNightR * switch_brightness
      end
    else
      red = red / max_color * 255 * switch_brightness
      green = green / max_color * 255 * switch_brightness
      blue = blue / max_color * 255 * switch_brightness
    end
  end
  if gDebug then
    local f = string.format("r %.2d  g %.2d  b %.2d", red//1, green//1, blue//1)
    txt_set(gTxtDebug3, f)
  end
  
  --------------------- 
  dimm_night_color = gNightLight*.5 - .8*gDayLight
  if dimm_night_color<0 then dimm_night_color=0 end
  opacity(gNightColor,  dimm_night_color)
  -- opacity(gBlackMask, (1-brightness_surface)*.8) qq
  opacity(gBlackMask, (1-brightness_surface)*.95)

  gFuncDrawAllCanvas(color_print, red, green, blue, switch_brightness)
end
  
function ControlIllumination(func_draw_all_canvas, img_night_mask, img_black_mask, debug_illu, text, text2, text3)
  gDebug = debug_illu
  gTxtDebug = text
  gTxtDebug2 = text2
  gTxtDebug3 = text3
  gNightColor = img_night_mask
  gBlackMask = img_black_mask
  gFuncDrawAllCanvas = func_draw_all_canvas

  if gPropIllumination == "Night" then
    gDayLight = 0.0
    gNightLight = .6
    gScalesLight = .8
    cbLightChange()
    
  elseif gPropIllumination == "Real" then
    si_variable_subscribe("sivar_ambient_darkness", "FLOAT", function(v) v=var_cap((v-.25)/.75, 0, 1);  gDayLight=1-v; cbLightChange() end)
    fs2020_variable_subscribe("L:switch_95_73X", "number", "L:switch_258_73X", "number", function(overhead_dimmer, dome_switch)
      gScalesLight = overhead_dimmer/300.
      if dome_switch==100 then gNightLight = 1.0
        elseif dome_switch==50 then gNightLight = 0
        else gNightLight = .6
      end
      cbLightChange()
    end)
    
  else -- Day
    gDayLight = .99
    gNightLight = 0
    gScalesLight = 0
    cbLightChange()
  end
end

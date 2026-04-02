-- Detlef von Reusner
-- FSUIPC7 lua script for PMDG 737-700
-- May 30 2023

-- Put 1=Lua PmdgOk in [Auto] section of fsuipc.ini file for automatic start. 

-- History:
-- Oct 23 2022 - initial version
-- May 30 2023 - ADF standby frequency added

local gVar = {}

function AddVariable(lvar, vtype, len, offset)
  -- create Lvar with prefix
  -- call Lvar func per event when the associated offest changes
  -- len is optional. If len is not given the third parameter is assumed to be the offset.
  if offset == nil then offset = len end
  gVar[offset] = {}
  local var = gVar[offset]
  var.lvar = "ipcpmdg_"..lvar
  var.type = vtype
  var.len = len
  var.offset = offset
  
  ipc.log("creating Lvar "..var.lvar)
  ipc.createLvar(var.lvar, 0)
  ipc.sleep(1000) -- needed as of Sep 5 2022
end

function OffsetChanged(offset, value)
  -- ipc.log("OffsetChanged called, params: "..offset.." "..value)
  -- ipc.log("type of value is "..type(value))
  if gVar[offset].type == "STR" then
    -- ipc.writeLvarSTR(gVar[offset].lvar, value)  -- not working
    if offset == 0x656c or offset == 0x6572 then -- process dashes
      if string.find(value, "--", 1, true) ~= nil then
        ipc.writeLvar(gVar[offset].lvar, 99000.)
      else
        ipc.writeLvar(gVar[offset].lvar, tonumber(value))
      end
    else
      ipc.writeLvar(gVar[offset].lvar, tonumber(value))
    end
  else
    ipc.writeLvar(gVar[offset].lvar, value)
  end
end

function StartEventWatching()
  for offset, var in pairs(gVar) do
    if var.type == "STR" then
      event.offset(offset, "STR", var.len, "OffsetChanged")
    else
      event.offset(offset, var.type, "OffsetChanged")
    end
    ipc.sleep(200) -- not sure if needed
  end
end

-- ipc.sleep(30000) -- Verzoegerung fuer Linda ??

AddVariable("AIR_DisplayLandAlt", "STR", 6, 0x6572)
AddVariable("AIR_DisplayFltAlt", "STR", 6, 0x656c)

AddVariable("MAIN_annunAP", "UW", 0x65f1)
AddVariable("MAIN_annunAP_Amber", "UW", 0x65f3)
AddVariable("MAIN_annunAT", "UW", 0x65f5)
AddVariable("MAIN_annunAT_Amber", "UW", 0x65f7)
AddVariable("MAIN_annunFMC", "UW", 0x65f9)

AddVariable("MCP_IASMach", "FLT32", 1, 0x65c4)
AddVariable("MCP_IASBlank", "UB", 1, 0x65c8)
AddVariable("MCP_IASOverspeedFlash", "UB", 1, 0x65c9)
AddVariable("MCP_IASUnderspeedFlash", "UB", 1, 0x65ca)
AddVariable("MCP_VertSpeedBlank", "UB", 0x65D2)
AddVariable("MCP_VertSpeed", "SW", 0x65d0)
AddVariable("MCP_indication_powered", "UB", 0x65e9)

AddVariable("ADF_StandbyFrequency", "UD", 0x6470)

-- not really needed for published instruments:
AddVariable("PlanePitchDegrees", "SD", 0x0578)
AddVariable("SimOnGround", "UW", 0x366)
AddVariable("GroundAltitude", "SD", 0x0020)


StartEventWatching()

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

-- ==============================

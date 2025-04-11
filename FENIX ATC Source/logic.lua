--[[====================================================================================

    Title:           ATC and TCAS for Fenix Airbus A319/A320/A321 (Air Manager instrument)
    Simulator(s):    MSFS 2020 / 2024
    Author:          Denis "DeltaCharlie" Carré : Fenix - FS2020/2024 conversion
    Contributors:    Alexander Hildmann created for FlightFactor A320 on Xplane
    Contributors:    Yves Levesque adapted for MSFS 2020
    Contributors:    Samer
    Version:         2.0.0
    IMPORTANT:       To use "Illumination mode", Illumination Pedestal Captain instrument is needed.
    Changes:  
        2022-12-29 v1.0.0 Fenix beta version
        2023-01-23 v1.1.0 Added corrections for initual XPDR code display
        2023-01-25 v1.2.0 Updated power management and added XPDR FAIL led when AC power off
        2023-01-25 v1.2.1 Changed XPDR font color (now white)
        2023-02-08 v1.2.2 Added PB click sound
        2023-03-07 v1.2.3 Switched to FENIXPLD 0.9 LVARS
        2023-07-21 v1.2.4 Better XPDR switch behaviour
        2024-04-17 v1.2.5 Now uses native LVARS values - FenixQuartz no longer needed
        2024-04-21 v1.2.6 Improved XPDR sqawk code display
        2024-05-28 v1.2.7 Added missing click sound on ATC 0 key
        2024-05-28 v1.2.8 Allow display squawk code starting with 0s
        2024-06-01 v1.2.9 Better display behaviour (switch std/active)
        2024-08-19 v1.3.0 Improved display at initialization (instead of 0000 sqawk code displayed)
        2024-11-27 v2.0.0 Added FS2024 support
                     
   ======================================================================= --]]
   
 --Images -------------------------------------------------
 
   snd_pb_push = sound_add("PB_p.mp3")
   snd_pb_release = sound_add("PB_r.mp3")

   local backlight_but_img     = img_add_fullscreen("backlight.png")
   local backlight_but_y_img   = img_add_fullscreen("backlight_yellow.png"); opacity(backlight_but_y_img, 0.0)
   local backplate_img         = img_add_fullscreen("atc_panel.png")   -- 580,240
   local night_overlay_img     = img_add_fullscreen("atc_panel_night.png")
   local text_overlay_img      = img_add_fullscreen("atc_panel_text.png")
   local text_overlay_y_img    = img_add_fullscreen("atc_panel_text_yellow.png"); opacity(text_overlay_y_img, 0.0)
   local ATC_Mode_img          = img_add("atc_knob2.png",62,27,50,50)
   local ATC_System_img        = img_add("atc_knob2.png",62,90,50,50)
   local ATC_Alt_img           = img_add("atc_knob2.png",62,160,50,50)
   local TCAS_Show_img         = img_add("atc_knob1.png",335,155,70,70)
   local TCAS_Traffic_img      = img_add("atc_knob1.png",452,155,70,70)
   local ATC_faillight_img     = img_add("atc_faillight.png",205,12,22,22); visible(ATC_faillight_img,false)
   local atc_disp_txt          = txt_add("","font:wwDigital.ttf;size:55;color:white;halign:left;",358,23,150,50)
   local knob_group             = group_add (ATC_Mode_img,ATC_System_img,ATC_Alt_img,TCAS_Show_img,TCAS_Traffic_img)
   
   local PWR_ACBUS_lvar = 		 {"L:B_LT_READING_1","num"}
 
--Initialize -------------------------------------------------
  local power                 =  0
  local Illumination_mode
  local ATC_Modepos           =  0
  local ATC_Systempos         =  0
  local ATC_Altpos            =  0
  local TCAS_Showpos          =  0
  local TCAS_Trafficpos       =  0


function decimal_to_bcd16(frequency)
    local returnbcd = 0
    for i = 0, 3 do
        returnbcd = returnbcd + (math.floor(frequency % 10) << (i * 4))
        frequency = frequency / 10
    end
     return returnbcd
 end

--=======================================================================
-- 1.0 ATC Mode  STBY Auto ON
--=======================================================================
  function ATC_Mode_cb (ATC_Mode_var)
    print (ATC_Mode_var)
      ATC_Modepos = ATC_Mode_var
    if  ATC_Mode_var == 0 then
        rotate(ATC_Mode_img, -18)
    elseif  ATC_Mode_var == 1 then
        rotate(ATC_Mode_img, 0)
    else
        rotate(ATC_Mode_img, 18 )
    end
  end
 msfs_variable_subscribe("L:S_XPDR_OPERATION", "enum",ATC_Mode_cb)



  function ATC_Mode_turn_cb (dir1)
      msfs_variable_write("L:S_XPDR_OPERATION","enum", -1)
      msfs_variable_write("L:S_XPDR_OPERATION","enum", var_cap(ATC_Modepos + dir1,0,2))
    end
  ATC_Mode_dial = dial_add( nil, 62, 30, 50, 50, ATC_Mode_turn_cb)
  
  function scb_pressed()
      ATC_Mode_turn_cb (1)
      --msfs_variable_write( "L:S_XPDR_ATC", "enum",1)
  end
  
  function scb2_pressed()
      ATC_Mode_turn_cb (-1)
      --msfs_variable_write( "L:S_XPDR_ATC", "enum",0)
  end
  button_id = button_add("clock.png", "clockt.png", 130,0,30,30,scb_pressed, nil)
  
  button_id6 = button_add("counter.png", "countert.png", 0,0,30,30,scb2_pressed, nil)
--=======================================================================
-- 1.1 ATC System 1, 2
--=======================================================================

  function ATC_cb (ATC_var)
    if  ATC_var == 0 then
      rotate(ATC_System_img, -18 )
    else 
      rotate(ATC_System_img, 18 )
    end
  end
  msfs_variable_subscribe( "L:S_XPDR_ATC", "enum", ATC_cb)

  function ATC_Alt_turn_cb (dir)
      local switch_pos = 0
      if dir == -1 then switch_pos = 0  else  switch_pos = 1 end
      msfs_variable_write( "L:S_XPDR_ATC", "enum",switch_pos)
  end
  

  
  ATC_Alt_dial = dial_add( nil, 62, 90, 50, 50, ATC_Alt_turn_cb)
  

--=======================================================================
-- 1.2 ATC Alt RPTG  OFF, ON
--=======================================================================
  function ATC_Alt_cb (ATC_Alt_var)
    if  ATC_Alt_var == 0 then
      rotate(ATC_Alt_img, -18 )
    else 
      rotate(ATC_Alt_img, 18 )
   end
   ATC_Altpos = ATC_Alt_var
  end
  msfs_variable_subscribe( "L:S_XPDR_ALTREPORTING", "enum", ATC_Alt_cb)

  function ATC_Alt_turn_cb (dir)
      local switch_pos = 0
      if dir == -1 then switch_pos = 0  else  switch_pos = 1 end
      msfs_variable_write( "L:S_XPDR_ALTREPORTING", "ENUM",switch_pos)
  end
  ATC_Alt_dial = dial_add( nil, 62, 160, 50, 50, ATC_Alt_turn_cb)

  function alt_pressed()
      ATC_Alt_turn_cb (1)
  end
    function alt_pressed2()
      ATC_Alt_turn_cb (-1)
  end

  button_id5 = button_add("clock.png", "clockt.png", 115,215,30,30,alt_pressed, nil)
  button_id6 = button_add("counter.png", "countert.png", 20,215,30,30,alt_pressed2, nil)
--======================================================
-- 1.3 ATC Faillight: Receive status from the sim
--======================================================
function atc_fail_cb ( fail )
    fail_led_on = (fail == 1) 
    visible(ATC_faillight_img,fail_led_on)
end
msfs_variable_subscribe ("L:I_XPDR_FAIL","num", atc_fail_cb)
--======================================================
-- 1.4 ATC num pad
--======================================================
  function atc_num1_p_cb()
      sound_play(snd_pb_push)
      msfs_variable_write("L:S_PED_ATC_1","enum",1) 
  end
  
  function atc_num1_r_cb()
      msfs_variable_write("L:S_PED_ATC_1", "enum", 0)
  end
  atc_num1_button = button_add("1.png", "1p.png", 133, 48,46, 46, atc_num1_p_cb, atc_num1_r_cb)
   

  function atc_num2_p_cb()
      sound_play(snd_pb_push)
      msfs_variable_write("L:S_PED_ATC_2","enum",1)
  end
  
  function atc_num2_r_cb()
      msfs_variable_write("L:S_PED_ATC_2", "enum",0)
  end
  atc_num2_button = button_add("2.png", "2p.png", 193, 48,46, 46, atc_num2_p_cb, atc_num2_r_cb)

  function atc_num3_p_cb()
      sound_play(snd_pb_push)
      msfs_variable_write("L:S_PED_ATC_3","enum",1)
  end
  
  function atc_num3_r_cb()
      msfs_variable_write("L:S_PED_ATC_3", "enum",0)
  end
  atc_num3_button = button_add("3.png", "3p.png", 253, 48,46, 46, atc_num3_p_cb, atc_num3_r_cb)

  function atc_num4_p_cb()
      sound_play(snd_pb_push)
      msfs_variable_write("L:S_PED_ATC_4","enum",1)
  end
  
  function atc_num4_r_cb()
      msfs_variable_write("L:S_PED_ATC_4", "enum",0)
  end
  atc_num4_button = button_add("4.png", "4p.png", 133, 108,46, 46, atc_num4_p_cb, atc_num4_r_cb)

  function atc_num5_p_cb()
    sound_play(snd_pb_push)
    msfs_variable_write("L:S_PED_ATC_5","enum",1)
  end
  
  function atc_num5_r_cb()
     msfs_variable_write("L:S_PED_ATC_5", "enum",0)
  end
  atc_num5_button = button_add("5.png", "5p.png", 193, 108,46, 46, atc_num5_p_cb, atc_num5_r_cb)

  function atc_num6_p_cb()
      sound_play(snd_pb_push)
      msfs_variable_write("L:S_PED_ATC_6","enum",1)
   end
   
   function atc_num6_r_cb()
      msfs_variable_write("L:S_PED_ATC_6", "enum",0)
   end
   atc_num6_button = button_add("6.png", "6p.png", 253, 108,46, 46, atc_num6_p_cb, atc_num6_r_cb)

  function atc_num7_p_cb()
      sound_play(snd_pb_push)
      msfs_variable_write("L:S_PED_ATC_7","enum",1)
  end
  
  function atc_num7_r_cb()
      msfs_variable_write("L:S_PED_ATC_7", "enum",0)
  end
  atc_num7_button = button_add("7.png", "7p.png", 133, 168,46, 46, atc_num7_p_cb, atc_num7_r_cb)

  function atc_num0_p_cb()
      sound_play(snd_pb_push)
      msfs_variable_write("L:S_PED_ATC_0","enum",1)
  end
  
  function atc_num0_r_cb()
     msfs_variable_write("L:S_PED_ATC_0", "enum",0)
  end
  atc_num0_button = button_add("0.png", "0p.png", 193, 168,46, 46, atc_num0_p_cb, atc_num0_r_cb)

  function atc_numclr_p_cb()
    sound_play(snd_pb_push)
    msfs_variable_write("L:S_PED_ATC_CLR","enum",1)
  end
  
  function atc_numclr_r_cb()
      msfs_variable_write("L:S_PED_ATC_CLR", "enum",0)
  end
  atc_numclr_button = button_add("clr.png", "clrp.png", 253, 168,46, 46, atc_numclr_p_cb, atc_numclr_r_cb)
--======================================================
-- 1.5 ATC digits: Receive status
--======================================================
 
 function atc_disp_value_cb (ad,ad2,nb)
    if (ad == -1 and nb == 4) then displayedCode = string.format("%04.0f",ad2)
    elseif (ad ==0 and nb ==4) then displayedCode = string.format("%04.0f",ad2)
    elseif ad == -1 then displayedCode = ""
    else
        nb2 = string.len(ad)
        if nb == 4 then displayedCode = string.format("%04.0f",ad)
        elseif nb == 3 then displayedCode = string.format("%03.0f",ad)
        elseif nb == 2 then displayedCode = string.format("%02.0f",ad)
        elseif nb == 1 then displayedCode = string.format("%01.0f",ad)
        elseif nb == 0 then displayedCode = ""
        end
        --else displayedCode = ad
        --end--displayedCode = ad
    end
    txt_set(atc_disp_txt,  displayedCode)
 end
msfs_variable_subscribe("L:N_FREQ_STANDBY_XPDR_SELECTED", "enum", 
                          "L:N_FREQ_XPDR_SELECTED", "enum", 
                          "L:N_PED_XPDR_CHAR_DISPLAYED", "enum", 
                          atc_disp_value_cb)
--======================================================




-- 1.6 TCAS Show  THRT, ALL, ABV, BLW
--======================================================
function TCAS_Show_cb (TCAS_Show_var)

TCAS_Showpos =TCAS_Show_var
if  TCAS_Show_var == 0.0 then
  rotate(TCAS_Show_img, -33 )
elseif  TCAS_Show_var == 1.0 then
   rotate(TCAS_Show_img, -14 )
elseif  TCAS_Show_var == 2.0 then
   rotate(TCAS_Show_img, 13 )
elseif  TCAS_Show_var == 3.0 then
  rotate(TCAS_Show_img, 35 )
end
end
msfs_variable_subscribe( "L:S_TCAS_RANGE", "enum", TCAS_Show_cb)

function TCAS_Show_turn_cb (dir1)
    TCAS_Showpos = TCAS_Showpos + dir1

    if TCAS_Showpos > 3 then TCAS_Showpos =3 end
    if TCAS_Showpos <0  then TCAS_Showpos =0 end

    msfs_variable_write( "L:S_TCAS_RANGE", "enum", TCAS_Showpos)

end
  
function show_pressed()
    TCAS_Traffic_turn_cb (1)
end
    
function show_pressed1()
    TCAS_Traffic_turn_cb (-1)
end
  
TCAS_Show_dial = dial_add( nil, 335, 155, 70, 70, TCAS_Show_turn_cb)
button_id20 = button_add("clock.png", "clockt.png", 500,210,30,30,show_pressed, nil)
button_id21 = button_add("counter.png", "countert.png", 440,210,30,30,show_pressed1, nil)
--======================================================
-- 1.7 TCAS Traffic  STBY, TA, TA/RA
--======================================================
  function TCAS_Traffic_cb (TCAS_Traffic_var)
       TCAS_Trafficpos = TCAS_Traffic_var
       rotate(TCAS_Traffic_img, (TCAS_Trafficpos * 15)-15 )

  end
  msfs_variable_subscribe("L:S_XPDR_MODE", "enum", TCAS_Traffic_cb)


  function TCAS_Traffic_turn_cb (dir1)
    TCAS_Trafficpos = TCAS_Trafficpos + dir1
    if TCAS_Trafficpos >2 then TCAS_Trafficpos = 2 end
    if TCAS_Trafficpos <0 then TCAS_Trafficpos = 0 end
    msfs_variable_write( "L:S_XPDR_MODE", "enum",TCAS_Trafficpos)
  end

    function tara_pressed()
        TCAS_Traffic_turn_cb (1)
    end

    function stby_pressed()
        TCAS_Traffic_turn_cb (-1)
    end
    
  TCAS_Traffic_dial = dial_add( nil, 452, 155, 70, 70, TCAS_Traffic_turn_cb)
   button_id2 = button_add("clock.png", "clockt.png", 380,210,30,30,tara_pressed, nil)
    button_id3 = button_add("counter.png", "countert.png", 325,210,30,30,stby_pressed, nil)
--==========================================================================
-- 1.8 ATC Ident
--==========================================================================
  function ATC_Ident_p_cb()
      msfs_variable_write( "L:S_XPDR_IDENT", "enum",1)
  end
  function ATC_Ident_r_cb()
      msfs_variable_write( "L:S_XPDR_IDENT", "enum",0)
  end
  ATC_Ident_button = button_add("ident_button.png", "ident_button_p.png",  377, 107, 22, 22, ATC_Ident_p_cb, ATC_Ident_r_cb)


--==========================================================================
-- 11. Illumination Mode
   function Illumination_mode_cb(Illumination_mode_val)
      Illumination_mode = Illumination_mode_val
	  var1  = var_cap(Illumination_mode_val[5] * 0.031 + 0.3, 0.3, 1.0); var1y = var_cap(Illumination_mode_val[5] * 0.25 - 5.75, 0.0, 1.0)
     if Illumination_mode_val[1] == 1.0 then	 
       opacity(night_overlay_img, 1 - Illumination_mode_val[6] * 0.037)
       opacity(text_overlay_img, var1); opacity(text_overlay_y_img, var1y)
       opacity(backlight_but_img,var1); opacity(backlight_but_y_img, var1y)
       opacity(atc_disp_txt,var1); opacity(knob_group,var_cap(Illumination_mode_val[6] * 0.037,0.5,1.0))
     else
       opacity(night_overlay_img,0.0); opacity(text_overlay_img,1.0); opacity(text_overlay_y_img ,0.0)
       opacity(backlight_but_img,1.0); opacity(backlight_but_y_img,0.0); opacity(atc_disp_txt,1.0); opacity(knob_group,1.0)
      end
           
      if power == 0 then
       opacity(atc_disp_txt,0)
      end

    
   end
   si_variable_subscribe("Illumination_mode","FLOAT[10]", Illumination_mode_cb)
   
--=============================================
-- 10. Power Management
--=============================================   
   function power_cb (powered)
      power = powered
      if Illumination_mode ~= nil then Illumination_mode_cb(Illumination_mode) end
      if power == 0 then visible(atc_disp_txt, false)
      else visible(atc_disp_txt, true) end
   end
   msfs_variable_subscribe( PWR_ACBUS_lvar[1],PWR_ACBUS_lvar[2], power_cb)

-- Parking brake
pb_on = 0
function park_brk(pb_position)
    pb_on = pb_position
    if pb_position > 0 then
        visible(pb_lite_img, true)
        visible(pb_hand_on_img, true)
        visible(pb_hand_off_img, false)
    else
        visible(pb_lite_img, false)
        visible(pb_hand_on_img, false)
        visible(pb_hand_off_img, true)
    end
end

-- Subscribe to iFly parking brake position
fsx_variable_subscribe("L:ParkingBrakePosition", "Bool", park_brk)

function pb_toggle()
    -- Toggle iFly parking brake
    fsx_event("H:A2A_PARKING_BRAKE_POSITION")
end

button_id = button_add(nil, nil, 86, 698, 115, 150, pb_toggle)

-- Speedbrake
function sb_handle(sb_position)
    local sb_disp
    if sb_position == 0 then
        sb_disp = 40 -- Fully retracted
    else
        sb_disp = 40 + sb_position * 258 -- Adjust position
    end
    move(sb_handle_img, nil, sb_disp, nil, nil)
end

-- Subscribe to iFly speedbrake position
fsx_variable_subscribe("L:A_FC_SPEEDBRAKE", "Number", sb_handle)

function sb_extend()
    -- Incrementally extend speedbrake
    fsx_event("H:A_FC_SPEEDBRAKE", "++")
end

function sb_retract()
    -- Incrementally retract speedbrake
    fsx_event("H:A_FC_SPEEDBRAKE", "--")
end

button_add(nil, nil, 50, 50, 100, 50, sb_extend) -- Example button for extending
button_add(nil, nil, 50, 150, 100, 50, sb_retract) -- Example button for retracting

-- Flap handle
function flap_handle(flap_position)
    local flap_hand_disp
    if flap_position == 0 then -- up
        flap_hand_disp = 284
    elseif flap_position == 1 then -- 1
        flap_hand_disp = 315
    elseif flap_position == 2 then -- 2
        flap_hand_disp = 384
    elseif flap_position == 3 then -- 5
        flap_hand_disp = 418
    elseif flap_position == 4 then -- 10
        flap_hand_disp = 472
    elseif flap_position == 5 then -- 15
        flap_hand_disp = 503
    elseif flap_position == 6 then -- 25
        flap_hand_disp = 541
    elseif flap_position == 7 then -- 30
        flap_hand_disp = 587
    elseif flap_position == 8 then -- 40
        flap_hand_disp = 644
    end
    move(flap_handle_img, nil, flap_hand_disp, nil, nil)
end

-- Subscribe to iFly flap position
fsx_variable_subscribe("L:LandFlapsPos", "Number", flap_handle)

function flap_increase()
    -- Incrementally increase flaps
    fsx_event("H:PA24_250_Flaps_Inc")
end

function flap_decrease()
    -- Incrementally decrease flaps
    fsx_event("H:PA24_250_Flaps_Dec")
end

button_add(nil, nil, 100, 100, 50, 50, flap_increase) -- Example button for increasing flaps
button_add(nil, nil, 100, 200, 50, 50, flap_decrease) -- Example button for decreasing flaps



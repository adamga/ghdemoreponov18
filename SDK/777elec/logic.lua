--[[
******************************************************************************************
*****************Boeing 787-Overhead-Electrical Power Panel**************************
******************************************************************************************

    Made by SIMSTRUMENTATION "EXTERMINATE THE MICE FROM YOUR COCKPIT!"
    GitHub: https://github.com/simstrumentation
   
- **v1.0** 07-06-2023
    - Original Panel Created

##Left To Do:
    - N/A
	
##Notes:
    - APU Fault only shows when starting, not actual fault.
******************************************************************************************
--]]

snd_click=sound_add("click.wav")
snd_dial=sound_add("dial.wav")
snd_fail=sound_add("beepfail.wav")
cover_open_snd = sound_add("cover_open.wav")
cover_close_snd = sound_add("cover_close.wav")

img_add_fullscreen("background.png")
img_bg_night = img_add_fullscreen("background_night.png")
img_labels_backlight = img_add_fullscreen("backlighting.png")

-- Ambient Light Control
function ss_ambient_darkness(value)
    opacity(img_bg_night, value, "LOG", 0.04)
    opacity(img_dial_apu_night, value, "LOG", 0.04)
    opacity(img_dial_LWiper_night, value, "LOG", 0.04) 
    opacity(img_dial_LHUD_BRT_night, value, "LOG", 0.04)     
    opacity(img_dial_lower_dspl_brightness_night, value, "LOG", 0.04) 
    opacity(img_dial_lower_dspl_contrast_night, value, "LOG", 0.04)  
end
si_variable_subscribe("sivar_ambient_darkness", "FLOAT", ss_ambient_darkness)

--=======Back  Lighting============
function backlight(value)
        opacity(img_labels_backlight, value, "LOG", 0.04)     
        opacity(img_dial_apu_backlight, value, "LOG", 0.04)                
        opacity(img_dial_LWiper_backlight, value, "LOG", 0.04)  
        opacity(img_dial_lower_dspl_brightness_backlight, value, "LOG", 0.04)                
        opacity(img_dial_lower_dspl_contrast_backlight, value, "LOG", 0.04)          
end

function ss_backlighting(ovhd,master,push,pwr)
    ovhdvalue = var_round(ovhd/100,2) 
    if (ovhd == 0.0) or (pwr == false) then 
       backlight(0)
    elseif (push == false) then 
        backlight(ovhdvalue)         
    else              
       backlight( var_cap((ovhdvalue+master),0,1 ) )     
    end
end
msfs_variable_subscribe("L:LIGHTING_PANEL_4", "Number",
                                              "A:Light Potentiometer:31", "Number",
                                              "L:XMLVAR_LightMasterActive", "Bool",
                                              "A:CIRCUIT GENERAL PANEL ON","Bool", ss_backlighting)
---------------------------------------------------------------------------------------------------                                                                                       

--Day
img_dial_apu= img_add("diamond_gray_knob.png", 277,50,50,50)
img_dial_LHUD_BRT= img_add("knob_small.png", 77,389,38,38) 
img_dial_LWiper= img_add("diamond_gray_knob.png", 245,396,50,50)
img_dial_lower_dspl_brightness= img_add("dial_classic.png", 245,530,50,50)
img_dial_lower_dspl_contrast= img_add("dial_classic.png", 255,540,30,30)

--Night
img_dial_apu_night= img_add("diamond_gray_knob_night.png", 277,50,50,50)
img_dial_LHUD_BRT_night= img_add("knob_small_night.png", 77,389,38,38) 
img_dial_LWiper_night= img_add("diamond_gray_knob_night.png", 245,396,50,50)
img_dial_lower_dspl_brightness_night= img_add("dial_classic_night.png", 245,530,50,50)
img_dial_lower_dspl_contrast_night= img_add("dial_classic_night.png", 255,540,30,30)

--Backlight
img_dial_apu_backlight= img_add("backlight_diamond_knob.png", 277,50,50,50)
img_dial_LWiper_backlight= img_add("backlight_diamond_knob.png", 245,396,50,50)
img_dial_lower_dspl_brightness_backlight= img_add("dial_classic_backlight_outer.png", 245,530,50,50)
img_dial_lower_dspl_contrast_backlight= img_add("dial_classic_backlight.png", 255,540,30,30)

--------------------------------------------
--------------------------------------------
--IFE
local sw_IFE_pos = 0
img_sw_IFE_On_X=30
img_sw_IFE_On_Y=70
img_sw_IFE_Off_X=30
img_sw_IFE_Off_Y=90

function cb_sw_IFE()
    if (sw_IFE_pos == 0 ) then msfs_event("K:ROTOR_BRAKE", 1701) 
    elseif (sw_IFE_pos == 1 ) then msfs_event("K:ROTOR_BRAKE", 1701)  
    end 
    sound_play(snd_click)
    move(img_sw_IFE_On, img_sw_IFE_On_X+1, img_sw_IFE_On_Y+1, nil, nil, "LOG", 0.5)    move(img_sw_IFE_Off, img_sw_IFE_Off_X+1,img_sw_IFE_Off_Y+1, nil, nil, "LOG", 0.5)
end
function cbr_sw_IFE()
    move(img_sw_IFE_On, img_sw_IFE_On_X, img_sw_IFE_On_Y, nil, nil, "LOG", 0.5)    move(img_sw_IFE_Off, img_sw_IFE_Off_X, img_sw_IFE_Off_Y, nil, nil, "LOG", 0.5)
end
sw_IFE= button_add("button_up.png","button_down.png", 22,63,56,44, cb_sw_IFE, cbr_sw_IFE)

msfs_variable_subscribe("L:XMLVAR_Utility_Ife", "Number", 
                                             "ELECTRICAL MAIN BUS VOLTAGE:1", "volt",
        function (state,busvolt)
            sw_IFE_pos=state
            visible(img_sw_IFE_On, state ==1) 
            visible(img_sw_IFE_Off, (state == 0 and busvolt  > 24 ) )            
        end)     
img_sw_IFE_On = img_add("on.png", img_sw_IFE_On_X, img_sw_IFE_On_Y,36,8) 
img_sw_IFE_Off = img_add("off.png", img_sw_IFE_Off_X, img_sw_IFE_Off_Y,36,8)

--Cabin
local sw_Cabin_pos = 0
img_sw_Cabin_On_X=87
img_sw_Cabin_On_Y=70
img_sw_Cabin_Off_X=87
img_sw_Cabin_Off_Y=90

function cb_sw_Cabin()
    if (sw_Cabin_pos == 0 ) then msfs_event("K:ROTOR_BRAKE", 1801)  
    elseif (sw_Cabin_pos == 1 ) then msfs_event("K:ROTOR_BRAKE", 1801)   
    end 
    sound_play(snd_click)
    move(img_sw_Cabin_On, img_sw_Cabin_On_X+1, img_sw_Cabin_On_Y+1, nil, nil, "LOG", 0.5)    move(img_sw_Cabin_Off, img_sw_Cabin_Off_X+1,img_sw_Cabin_Off_Y+1, nil, nil, "LOG", 0.5)
end
function cbr_sw_Cabin()
    move(img_sw_Cabin_On, img_sw_Cabin_On_X, img_sw_Cabin_On_Y, nil, nil, "LOG", 0.5)    move(img_sw_Cabin_Off, img_sw_Cabin_Off_X, img_sw_Cabin_Off_Y, nil, nil, "LOG", 0.5)
end
sw_Cabin= button_add("button_up.png","button_down.png", 77,63,56,44, cb_sw_Cabin, cbr_sw_Cabin)

msfs_variable_subscribe("L:XMLVAR_Utility_Cabin", "Number", 
                                             "ELECTRICAL MAIN BUS VOLTAGE:1", "volt",
        function (state,busvolt)
            sw_Cabin_pos=state
            visible(img_sw_Cabin_On, state ==1) 
            visible(img_sw_Cabin_Off, (state == 0 and busvolt  > 24 ) )            
        end)     
img_sw_Cabin_On = img_add("on.png", img_sw_Cabin_On_X, img_sw_Cabin_On_Y,36,8) 
img_sw_Cabin_Off = img_add("off.png", img_sw_Cabin_Off_X, img_sw_Cabin_Off_Y,36,8)
	
--Battery
local sw_Battery_pos = 0
img_sw_Battery_On_X=172
img_sw_Battery_On_Y=46
img_sw_Battery_Off_X=172
img_sw_Battery_Off_Y=66

function cb_sw_Battery()
    if (sw_Battery_pos == 0 ) then msfs_event("K:ROTOR_BRAKE", 101)  
    elseif (sw_Battery_pos == 1 ) then msfs_event("K:ROTOR_BRAKE", 101)  
    end 
    sound_play(snd_click)
    move(img_sw_Battery_On, img_sw_Battery_On_X+1, img_sw_Battery_On_Y+1, nil, nil, "LOG", 0.5)    move(img_sw_Battery_Off, img_sw_Battery_Off_X+1,img_sw_Battery_Off_Y+1, nil, nil, "LOG", 0.5)
end
function cbr_sw_Battery()
    move(img_sw_Battery_On, img_sw_Battery_On_X, img_sw_Battery_On_Y, nil, nil, "LOG", 0.5)    move(img_sw_Battery_Off, img_sw_Battery_Off_X, img_sw_Battery_Off_Y, nil, nil, "LOG", 0.5)
end
sw_Battery= button_add("button_up.png","button_down.png", 163,39,56,44, cb_sw_Battery, cbr_sw_Battery)

msfs_variable_subscribe("L:XMLVAR_Battery_Switch_State", "Number", 
                                             "ELECTRICAL MAIN BUS VOLTAGE:2", "volts",
        function (state, bus)
            sw_Battery_pos=state visible(img_sw_Battery_On, state ==1) 
            visible(img_sw_Battery_Off, (state == 0 and bus >20  ))
        end)     
img_sw_Battery_On = img_add("on.png", img_sw_Battery_On_X, img_sw_Battery_On_Y,36,8) 
img_sw_Battery_Off = img_add("off.png", img_sw_Battery_Off_X, img_sw_Battery_Off_Y,36,8)

--APU Knob
function ss_apu(state)
    switch_set_position(switch_apu, state)
    rotate(img_dial_apu, -(40-(state*40)), "LOG", 0.05)
    rotate(img_dial_apu_night, -(40-(state*40)), "LOG", 0.05)  
    rotate(img_dial_apu_backlight, -(40-(state*40)), "LOG", 0.05)     
    visible(img_ApuGen_Fault, (state ==2))
end
msfs_variable_subscribe("L:XMLVAR_APU_StarterKnob_Pos", "Number", ss_apu)

function cb_sw_apu(position, direction)
    if (position == 0 and direction == 1 ) then msfs_variable_write("L:XMLVAR_APU_StarterKnob_Pos","Number",1) 
    elseif (position == 1 and direction == 1 ) then msfs_variable_write("L:XMLVAR_APU_StarterKnob_Pos","Number",2) msfs_event("APU_STARTER") timer_start(500, function () msfs_variable_write("L:XMLVAR_APU_StarterKnob_Pos","Number",1) end) msfs_event("APU_STARTER")
    elseif (position == 1 and direction == -1 ) then msfs_variable_write("L:XMLVAR_APU_StarterKnob_Pos","Number",0) msfs_event("APU_OFF_SWITCH") timer_start(100, function () msfs_variable_write("L:XMLVAR_APU_StarterKnob_Pos","Number",0)end)
    elseif (position == 2 and direction == -1) then msfs_variable_write("L:XMLVAR_APU_StarterKnob_Pos","Number",1)               
    end      sound_play(snd_dial)
end
switch_apu= switch_add(nil,nil,nil, 276,50,50,50, "CIRCULAIR" , cb_sw_apu) 
img_ApuGen_Fault = img_add("fault.png", 284,118,36,8)

--ApuGenL
local sw_ApuGenL_pos = 0
img_sw_ApuGenL_On_X=142
img_sw_ApuGenL_On_Y=120
img_sw_ApuGenL_Off_X=142
img_sw_ApuGenL_Off_Y=140

function cb_sw_ApuGenL()
    if (sw_ApuGenL_pos == 0 ) then msfs_event("K:APU_GENERATOR_SWITCH_SET",1,1)
    elseif (sw_ApuGenL_pos == 1 ) then msfs_event("K:APU_GENERATOR_SWITCH_SET",0,1)  
    end 
    sound_play(snd_click)
    move(img_sw_ApuGenL_On, img_sw_ApuGenL_On_X+1, img_sw_ApuGenL_On_Y+1, nil, nil, "LOG", 0.5)    move(img_sw_ApuGenL_Off, img_sw_ApuGenL_Off_X+1,img_sw_ApuGenL_Off_Y+1, nil, nil, "LOG", 0.5)
end
function cbr_sw_ApuGenL()
    move(img_sw_ApuGenL_On, img_sw_ApuGenL_On_X, img_sw_ApuGenL_On_Y, nil, nil, "LOG", 0.5)    move(img_sw_ApuGenL_Off, img_sw_ApuGenL_Off_X, img_sw_ApuGenL_Off_Y, nil, nil, "LOG", 0.5)
end
sw_ApuGenL= button_add("button_up.png","button_down.png", 135,112,56,44, cb_sw_ApuGenL, cbr_sw_ApuGenL)

msfs_variable_subscribe("L:ELECTRICAL_APU_Generator_1", "Number", 
                                             "ELECTRICAL MAIN BUS VOLTAGE:1", "volt",
        function (state,busvolt)
            sw_ApuGenL_pos=state visible(img_sw_ApuGenL_On, state ==1) 
            visible(img_sw_ApuGenL_Off, (state == 0 and busvolt  > 24 ) )            
        end)     
img_sw_ApuGenL_On = img_add("on.png", img_sw_ApuGenL_On_X, img_sw_ApuGenL_On_Y,36,8) 
img_sw_ApuGenL_Off = img_add("off.png", img_sw_ApuGenL_Off_X, img_sw_ApuGenL_Off_Y,36,8)

--ApuGenR
local sw_ApuGenR_pos = 0
img_sw_ApuGenR_On_X=200
img_sw_ApuGenR_On_Y=120
img_sw_ApuGenR_Off_X=200
img_sw_ApuGenR_Off_Y=140

function cb_sw_ApuGenR()
    if (sw_ApuGenR_pos == 0 ) then msfs_event("K:APU_GENERATOR_SWITCH_SET",1,2)
    elseif (sw_ApuGenR_pos == 1 ) then msfs_event("K:APU_GENERATOR_SWITCH_SET",0,2)  
    end 
    sound_play(snd_click)
    move(img_sw_ApuGenR_On, img_sw_ApuGenR_On_X+1, img_sw_ApuGenR_On_Y+1, nil, nil, "LOG", 0.5)    move(img_sw_ApuGenR_Off, img_sw_ApuGenR_Off_X+1,img_sw_ApuGenR_Off_Y+1, nil, nil, "LOG", 0.5)
end
function cbr_sw_ApuGenR()
    move(img_sw_ApuGenR_On, img_sw_ApuGenR_On_X, img_sw_ApuGenR_On_Y, nil, nil, "LOG", 0.5)    move(img_sw_ApuGenR_Off, img_sw_ApuGenR_Off_X, img_sw_ApuGenR_Off_Y, nil, nil, "LOG", 0.5)
end
sw_ApuGenR= button_add("button_up.png","button_down.png", 190,112,56,44, cb_sw_ApuGenR, cbr_sw_ApuGenR)

msfs_variable_subscribe("L:ELECTRICAL_APU_Generator_2", "Number", 
                                             "ELECTRICAL MAIN BUS VOLTAGE:1", "volt",
        function (state,busvolt)
            sw_ApuGenR_pos=state visible(img_sw_ApuGenR_On, state ==1) 
            visible(img_sw_ApuGenR_Off, (state == 0 and busvolt  > 24 ) )            
        end)     
img_sw_ApuGenR_On = img_add("on.png", img_sw_ApuGenR_On_X, img_sw_ApuGenR_On_Y,36,8) 
img_sw_ApuGenR_Off = img_add("off.png", img_sw_ApuGenR_Off_X, img_sw_ApuGenR_Off_Y,36,8)

--EXTL
img_sw_EXTL_On_X=30
img_sw_EXTL_On_Y=170
img_sw_EXTL_Avail_X=30
img_sw_EXTL_Avail_Y=190

function cb_sw_EXTL()
    msfs_variable_write("L:EXT_PWR_COMMANDED:1","Number", 1)
    timer_start(200, function() msfs_variable_write("L:EXT_PWR_COMMANDED:1","Number",0)end)
    sound_play(snd_click)
    move(img_sw_EXTL_On, img_sw_EXTL_On_X+1, img_sw_EXTL_On_Y+1, nil, nil, "LOG", 0.5)    move(img_sw_EXTL_Avail, img_sw_EXTL_Avail_X+1,img_sw_EXTL_Avail_Y+1, nil, nil, "LOG", 0.5)
end
function cbr_sw_EXTL()
    move(img_sw_EXTL_On, img_sw_EXTL_On_X, img_sw_EXTL_On_Y, nil, nil, "LOG", 0.5)    move(img_sw_EXTL_Avail, img_sw_EXTL_Avail_X, img_sw_EXTL_Avail_Y, nil, nil, "LOG", 0.5)
end
sw_EXTL= button_add("button_up.png","button_down.png", 22,162,56,44, cb_sw_EXTL, cbr_sw_EXTL)

msfs_variable_subscribe("A:EXTERNAL POWER AVAILABLE:1", "Number", 
                                              "A:EXTERNAL POWER ON:1", "Number", 
        function (avail,state,busvolt)
            visible(img_sw_EXTL_Avail , (avail == 1 and state ~= 1 ) )
            visible(img_sw_EXTL_On , (state == 1 ) )  
         end)
img_sw_EXTL_On = img_add("on.png", img_sw_EXTL_On_X, img_sw_EXTL_On_Y,36,8) 
img_sw_EXTL_Avail = img_add("avail_green.png", img_sw_EXTL_Avail_X, img_sw_EXTL_Avail_Y,36,8)
	
--EXTR
img_sw_EXTR_On_X=87
img_sw_EXTR_On_Y=170
img_sw_EXTR_Avail_X=87
img_sw_EXTR_Avail_Y=190

function cb_sw_EXTR()
    msfs_variable_write("L:EXT_PWR_COMMANDED:2","Number", 1)
    timer_start(200, function() msfs_variable_write("L:EXT_PWR_COMMANDED:2","Number",0)end)
    sound_play(snd_click)
    move(img_sw_EXTR_On, img_sw_EXTR_On_X+1, img_sw_EXTR_On_Y+1, nil, nil, "LOG", 0.5)    move(img_sw_EXTR_Avail, img_sw_EXTR_Avail_X+1,img_sw_EXTR_Avail_Y+1, nil, nil, "LOG", 0.5)
end
function cbr_sw_EXTR()
    move(img_sw_EXTR_On, img_sw_EXTR_On_X, img_sw_EXTR_On_Y, nil, nil, "LOG", 0.5)    move(img_sw_EXTR_Avail, img_sw_EXTR_Avail_X, img_sw_EXTR_Avail_Y, nil, nil, "LOG", 0.5)
end
sw_EXTR= button_add("button_up.png","button_down.png", 77,162,56,44, cb_sw_EXTR, cbr_sw_EXTR)

msfs_variable_subscribe("A:EXTERNAL POWER AVAILABLE:2", "Number", 
                                              "A:EXTERNAL POWER ON:2", "Number", 
        function (avail,state,busvolt)
            visible(img_sw_EXTR_Avail , (avail == 1 and state ~= 1 ) )
            visible(img_sw_EXTR_On , (state == 1 ) )  
         end)
img_sw_EXTR_On = img_add("on.png", img_sw_EXTR_On_X, img_sw_EXTR_On_Y,36,8) 
img_sw_EXTR_Avail = img_add("avail_green.png", img_sw_EXTR_Avail_X, img_sw_EXTR_Avail_Y,36,8)

--EXTAft
img_sw_EXTAft_On_X=284
img_sw_EXTAft_On_Y=170
img_sw_EXTAft_Avail_X=284
img_sw_EXTAft_Avail_Y=190

function cb_sw_EXTAft()
    msfs_variable_write("L:EXT_PWR_COMMANDED:3","Number", 1)
    timer_start(200, function() msfs_variable_write("L:EXT_PWR_COMMANDED:3","Number",0)end)
    sound_play(snd_click)
    move(img_sw_EXTAft_On, img_sw_EXTAft_On_X+1, img_sw_EXTAft_On_Y+1, nil, nil, "LOG", 0.5)    move(img_sw_EXTAft_Avail, img_sw_EXTAft_Avail_X+1,img_sw_EXTAft_Avail_Y+1, nil, nil, "LOG", 0.5)
end
function cbr_sw_EXTAft()
    move(img_sw_EXTAft_On, img_sw_EXTAft_On_X, img_sw_EXTAft_On_Y, nil, nil, "LOG", 0.5)    move(img_sw_EXTAft_Avail, img_sw_EXTAft_Avail_X, img_sw_EXTAft_Avail_Y, nil, nil, "LOG", 0.5)
end
sw_EXTAft= button_add("button_up.png","button_down.png", 276,162,56,44, cb_sw_EXTAft, cbr_sw_EXTAft)

msfs_variable_subscribe("A:EXTERNAL POWER AVAILABLE:3", "Number", 
                                              "A:EXTERNAL POWER ON:3", "Number", 
        function (avail,state,busvolt)
            visible(img_sw_EXTAft_Avail , (avail == 1 and state ~= 1 ) )
            visible(img_sw_EXTAft_On , (state == 1 ) )  
         end)
img_sw_EXTAft_On = img_add("on.png", img_sw_EXTAft_On_X, img_sw_EXTAft_On_Y,36,8) 
img_sw_EXTAft_Avail = img_add("avail_green.png", img_sw_EXTAft_Avail_X, img_sw_EXTAft_Avail_Y,36,8)

--BusGenL1
local sw_BusGenL1_pos = 0
img_sw_BusGenL1_On_X=36
img_sw_BusGenL1_On_Y=250
img_sw_BusGenL1_Off_X=36
img_sw_BusGenL1_Off_Y=270

function cb_sw_BusGenL1()
    if (sw_BusGenL1_pos == 0 ) then msfs_event("K:ALTERNATOR_SET",1,1)
    elseif (sw_BusGenL1_pos == 1 ) then msfs_event("K:ALTERNATOR_SET",0,1) end
    sound_play(snd_click)
    move(img_sw_BusGenL1_On, img_sw_BusGenL1_On_X+1, img_sw_BusGenL1_On_Y+1, nil, nil, "LOG", 0.5)    move(img_sw_BusGenL1_Off, img_sw_BusGenL1_Off_X+1,img_sw_BusGenL1_Off_Y+1, nil, nil, "LOG", 0.5)
end
function cbr_sw_BusGenL1()
    move(img_sw_BusGenL1_On, img_sw_BusGenL1_On_X, img_sw_BusGenL1_On_Y, nil, nil, "LOG", 0.5)    move(img_sw_BusGenL1_Off, img_sw_BusGenL1_Off_X, img_sw_BusGenL1_Off_Y, nil, nil, "LOG", 0.5)
end
sw_BusGenL1= button_add("button_up.png","button_down.png", 28,244,56,44, cb_sw_BusGenL1, cbr_sw_BusGenL1)

msfs_variable_subscribe("A:GENERAL ENG MASTER ALTERNATOR:1", "Number", 
                                            "ELECTRICAL GENALT BUS VOLTAGE:1", "volt", 
                                            "ELECTRICAL MAIN BUS VOLTAGE:2", "volts",
        function (state,genvolt,busvolt)
            sw_BusGenL1_pos=state visible(img_sw_BusGenL1_On, state ==1)
            visible(img_sw_BusGenL1_Off, (state == 0 and busvolt  > 24 )or(state == 1 and genvolt < 24  and busvolt  > 24))
        end)
img_sw_BusGenL1_On = img_add("on.png", img_sw_BusGenL1_On_X, img_sw_BusGenL1_On_Y,36,8) 
img_sw_BusGenL1_Off = img_add("off.png", img_sw_BusGenL1_Off_X, img_sw_BusGenL1_Off_Y,36,8)


--BusGenL2
local sw_BusGenL2_pos = 0
img_sw_BusGenL2_On_X=113
img_sw_BusGenL2_On_Y=250
img_sw_BusGenL2_Off_X=113
img_sw_BusGenL2_Off_Y=270

function cb_sw_BusGenL2()
    if (sw_BusGenL2_pos == 0 ) then msfs_event("K:ALTERNATOR_SET",1,2)
    elseif (sw_BusGenL2_pos == 1 ) then msfs_event("K:ALTERNATOR_SET",0,2) end
    sound_play(snd_click)
    move(img_sw_BusGenL2_On, img_sw_BusGenL2_On_X+1, img_sw_BusGenL2_On_Y+1, nil, nil, "LOG", 0.5)    move(img_sw_BusGenL2_Off, img_sw_BusGenL2_Off_X+1,img_sw_BusGenL2_Off_Y+1, nil, nil, "LOG", 0.5)
end
function cbr_sw_BusGenL2()
    move(img_sw_BusGenL2_On, img_sw_BusGenL2_On_X, img_sw_BusGenL2_On_Y, nil, nil, "LOG", 0.5)    move(img_sw_BusGenL2_Off, img_sw_BusGenL2_Off_X, img_sw_BusGenL2_Off_Y, nil, nil, "LOG", 0.5)
end
sw_BusGenL2= button_add("button_up.png","button_down.png", 103,244,56,44, cb_sw_BusGenL2, cbr_sw_BusGenL2)

msfs_variable_subscribe("A:GENERAL ENG MASTER ALTERNATOR:2", "Number", 
                                            "ELECTRICAL GENALT BUS VOLTAGE:2", "volt", 
                                            "ELECTRICAL MAIN BUS VOLTAGE:2", "volts",
        function (state,genvolt,busvolt)
            sw_BusGenL2_pos=state visible(img_sw_BusGenL2_On, state ==1)
            visible(img_sw_BusGenL2_Off, (state == 0 and busvolt  > 24 )or(state == 1 and genvolt < 24  and busvolt  > 24))
        end)
img_sw_BusGenL2_On = img_add("on.png", img_sw_BusGenL2_On_X, img_sw_BusGenL2_On_Y,36,8) 
img_sw_BusGenL2_Off = img_add("off.png", img_sw_BusGenL2_Off_X, img_sw_BusGenL2_Off_Y,36,8)

--BusGenR1
local sw_BusGenR1_pos = 0
img_sw_BusGenR1_On_X=236
img_sw_BusGenR1_On_Y=250
img_sw_BusGenR1_Off_X=236
img_sw_BusGenR1_Off_Y=270

function cb_sw_BusGenR1()
    if (sw_BusGenR1_pos == 0 ) then msfs_event("K:ALTERNATOR_SET",1,3)
    elseif (sw_BusGenR1_pos == 1 ) then msfs_event("K:ALTERNATOR_SET",0,3) end
    sound_play(snd_click)
    move(img_sw_BusGenR1_On, img_sw_BusGenR1_On_X+1, img_sw_BusGenR1_On_Y+1, nil, nil, "LOG", 0.5)    move(img_sw_BusGenR1_Off, img_sw_BusGenR1_Off_X+1,img_sw_BusGenR1_Off_Y+1, nil, nil, "LOG", 0.5)
end
function cbr_sw_BusGenR1()
    move(img_sw_BusGenR1_On, img_sw_BusGenR1_On_X, img_sw_BusGenR1_On_Y, nil, nil, "LOG", 0.5)    move(img_sw_BusGenR1_Off, img_sw_BusGenR1_Off_X, img_sw_BusGenR1_Off_Y, nil, nil, "LOG", 0.5)
end
sw_BusGenR1= button_add("button_up.png","button_down.png", 227,244,56,44, cb_sw_BusGenR1, cbr_sw_BusGenR1)

msfs_variable_subscribe("A:GENERAL ENG MASTER ALTERNATOR:3", "Number", 
                                            "ELECTRICAL GENALT BUS VOLTAGE:3", "volt", 
                                            "ELECTRICAL MAIN BUS VOLTAGE:2", "volts",
        function (state,genvolt,busvolt)
            sw_BusGenR1_pos=state visible(img_sw_BusGenR1_On, state ==1)
            visible(img_sw_BusGenR1_Off, (state == 0 and busvolt  > 24 )or(state == 1 and genvolt < 24  and busvolt  > 24))
        end)
img_sw_BusGenR1_On = img_add("on.png", img_sw_BusGenR1_On_X, img_sw_BusGenR1_On_Y,36,8) 
img_sw_BusGenR1_Off = img_add("off.png", img_sw_BusGenR1_Off_X, img_sw_BusGenR1_Off_Y,36,8)

--BusGenR2
local sw_BusGenR2_pos = 0
img_sw_BusGenR2_On_X=310
img_sw_BusGenR2_On_Y=250
img_sw_BusGenR2_Off_X=310
img_sw_BusGenR2_Off_Y=270

function cb_sw_BusGenR2()
    if (sw_BusGenR2_pos == 0 ) then msfs_event("K:ALTERNATOR_SET",1,4)
    elseif (sw_BusGenR2_pos == 1 ) then msfs_event("K:ALTERNATOR_SET",0,4) end
    sound_play(snd_click)
    move(img_sw_BusGenR2_On, img_sw_BusGenR2_On_X+1, img_sw_BusGenR2_On_Y+1, nil, nil, "LOG", 0.5)    move(img_sw_BusGenR2_Off, img_sw_BusGenR2_Off_X+1,img_sw_BusGenR2_Off_Y+1, nil, nil, "LOG", 0.5)
end
function cbr_sw_BusGenR2()
    move(img_sw_BusGenR2_On, img_sw_BusGenR2_On_X, img_sw_BusGenR2_On_Y, nil, nil, "LOG", 0.5)    move(img_sw_BusGenR2_Off, img_sw_BusGenR2_Off_X, img_sw_BusGenR2_Off_Y, nil, nil, "LOG", 0.5)
end
sw_BusGenR2= button_add("button_up.png","button_down.png", 300,244,56,44, cb_sw_BusGenR2, cbr_sw_BusGenR2)

msfs_variable_subscribe("A:GENERAL ENG MASTER ALTERNATOR:4", "Number", 
                                            "ELECTRICAL GENALT BUS VOLTAGE:4", "volt", 
                                            "ELECTRICAL MAIN BUS VOLTAGE:2", "volts",
        function (state,genvolt,busvolt)
            sw_BusGenR2_pos=state visible(img_sw_BusGenR2_On, state ==1)
            visible(img_sw_BusGenR2_Off, (state == 0 and busvolt  > 24 )or(state == 1 and genvolt < 24  and busvolt  > 24))
        end)
img_sw_BusGenR2_On = img_add("on.png", img_sw_BusGenR2_On_X, img_sw_BusGenR2_On_Y,36,8) 
img_sw_BusGenR2_Off = img_add("off.png", img_sw_BusGenR2_Off_X, img_sw_BusGenR2_Off_Y,36,8)

--Drive Buttons (INOP)
--DriveL1
img_sw_DriveL1_Line_X=38
img_sw_DriveL1_Line_Y=304
img_sw_DriveL1_Drive_X=38
img_sw_DriveL1_Drive_Y=324
local sw_DriveL1_enabled = false

function cb_sw_DriveL1_cover(position)
    visible(sw_DriveL1,true)visible(img_sw_DriveL1_undercover,false)visible(img_sw_DriveL1_Cover_down,false)visible(img_sw_DriveL1_Cover_up,true) sw_DriveL1_enabled=true  sound_play(cover_open_snd)
    timer_start(3000, function()     
               visible(sw_DriveL1,false)visible(img_sw_DriveL1_undercover,true)visible(img_sw_DriveL1_Cover_down,true)visible(img_sw_DriveL1_Cover_up,false) sw_DriveL1_enabled=false  sound_play(cover_close_snd)
            end)
end
sw_DriveL1_cover = button_add(nil,nil, 30,296,56,44, cb_sw_DriveL1_cover)

function cb_sw_DriveL1()
   if (sw_DriveL1_enabled) then 
        sound_play(snd_fail) 
        move(img_sw_DriveL1_Line, img_sw_DriveL1_Line_X+1, img_sw_DriveL1_Line_Y+1, nil, nil, "LOG", 0.5)    move(img_sw_DriveL1_Drive, img_sw_DriveL1_Drive_X+1, img_sw_DriveL1_Drive_Y+1, nil, nil, "LOG", 0.5)
    end
end
function cbr_sw_DriveL1()
   if (sw_DriveL1_enabled) then 
        move(img_sw_DriveL1_Line, img_sw_DriveL1_Line_X, img_sw_DriveL1_Line_Y, nil, nil, "LOG", 0.5)  move(img_sw_DriveL1_Drive, img_sw_DriveL1_Drive_X,img_sw_DriveL1_Drive_Y, nil, nil, "LOG", 0.5)
    end
end
sw_DriveL1= button_add("button_up.png","button_down.png",  28,298,56,44, cb_sw_DriveL1, cbr_sw_DriveL1)
img_sw_DriveL1_undercover = img_add("button_up.png",  28,298,56,44)
visible(sw_DriveL1,false) visible(img_sw_DriveL1_undercover,true)

msfs_variable_subscribe("ENG OIL PRESSURE:1", "Number", 
                                              "ELECTRICAL MAIN BUS VOLTAGE:1", "volt",                                     
        function (oilpres,busvolt)      
            visible(img_sw_DriveL1_Drive, (oilpres<370000 and busvolt  > 24 ) )   
        end)  
img_sw_DriveL1_Line = img_add("line.png", img_sw_DriveL1_Line_X, img_sw_DriveL1_Line_Y,36,8)
img_sw_DriveL1_Drive = img_add("drive.png", img_sw_DriveL1_Drive_X, img_sw_DriveL1_Drive_Y,36,8)  
img_sw_DriveL1_Cover_down = img_add("button_cover_down.png", 21,290,68,54) 
img_sw_DriveL1_Cover_up = img_add("button_cover_up.png", 21,290,68,54) visible(img_sw_DriveL1_Cover_up, false)
--DriveL2
img_sw_DriveL2_Line_X=112
img_sw_DriveL2_Line_Y=304
img_sw_DriveL2_Drive_X=112
img_sw_DriveL2_Drive_Y=324
local sw_DriveL2_enabled = false

function cb_sw_DriveL2_cover(position)
    visible(sw_DriveL2,true)visible(img_sw_DriveL2_undercover,false)visible(img_sw_DriveL2_Cover_down,false)visible(img_sw_DriveL2_Cover_up,true) sw_DriveL2_enabled=true  sound_play(cover_open_snd)
    timer_start(3000, function()     
               visible(sw_DriveL2,false)visible(img_sw_DriveL2_undercover,true)visible(img_sw_DriveL2_Cover_down,true)visible(img_sw_DriveL2_Cover_up,false) sw_DriveL2_enabled=false  sound_play(cover_close_snd)
            end)
end
sw_DriveL2_cover = button_add(nil,nil, 100,296,56,44, cb_sw_DriveL2_cover)

function cb_sw_DriveL2()
   if (sw_DriveL2_enabled) then 
        sound_play(snd_fail) 
        move(img_sw_DriveL2_Line, img_sw_DriveL2_Line_X+1, img_sw_DriveL2_Line_Y+1, nil, nil, "LOG", 0.5)    move(img_sw_DriveL2_Drive, img_sw_DriveL2_Drive_X+1, img_sw_DriveL2_Drive_Y+1, nil, nil, "LOG", 0.5)
    end
end
function cbr_sw_DriveL2()
   if (sw_DriveL2_enabled) then 
        move(img_sw_DriveL2_Line, img_sw_DriveL2_Line_X, img_sw_DriveL2_Line_Y, nil, nil, "LOG", 0.5)  move(img_sw_DriveL2_Drive, img_sw_DriveL2_Drive_X,img_sw_DriveL2_Drive_Y, nil, nil, "LOG", 0.5)
    end
end
sw_DriveL2= button_add("button_up.png","button_down.png",  102,298,56,44, cb_sw_DriveL2, cbr_sw_DriveL2)
img_sw_DriveL2_undercover = img_add("button_up.png",  102,298,56,44)
visible(sw_DriveL2,false) visible(img_sw_DriveL2_undercover,true)

msfs_variable_subscribe("ENG OIL PRESSURE:1", "Number", 
                                              "ELECTRICAL MAIN BUS VOLTAGE:1", "volt",                                     
        function (oilpres,busvolt)      
            visible(img_sw_DriveL2_Drive, (oilpres<370000 and busvolt  > 24 ) )   
        end)  
img_sw_DriveL2_Line = img_add("line.png", img_sw_DriveL2_Line_X, img_sw_DriveL2_Line_Y,36,8)
img_sw_DriveL2_Drive = img_add("drive.png", img_sw_DriveL2_Drive_X, img_sw_DriveL2_Drive_Y,36,8)  
img_sw_DriveL2_Cover_down = img_add("button_cover_down.png", 96,290,68,54) 
img_sw_DriveL2_Cover_up = img_add("button_cover_up.png", 96,290,68,54) visible(img_sw_DriveL2_Cover_up, false)

--DriveR1
img_sw_DriveR1_Line_X=237
img_sw_DriveR1_Line_Y=304
img_sw_DriveR1_Drive_X=237
img_sw_DriveR1_Drive_Y=324
local sw_DriveR1_enabled = false

function cb_sw_DriveR1_cover(position)
    visible(sw_DriveR1,true)visible(img_sw_DriveR1_undercover,false)visible(img_sw_DriveR1_Cover_down,false)visible(img_sw_DriveR1_Cover_up,true) sw_DriveR1_enabled=true  sound_play(cover_open_snd)
    timer_start(3000, function()     
               visible(sw_DriveR1,false)visible(img_sw_DriveR1_undercover,true)visible(img_sw_DriveR1_Cover_down,true)visible(img_sw_DriveR1_Cover_up,false) sw_DriveR1_enabled=false  sound_play(cover_close_snd)
            end)
end
sw_DriveR1_cover = button_add(nil,nil, 227,296,56,44, cb_sw_DriveR1_cover)

function cb_sw_DriveR1()
   if (sw_DriveR1_enabled) then 
        sound_play(snd_fail) 
        move(img_sw_DriveR1_Line, img_sw_DriveR1_Line_X+1, img_sw_DriveR1_Line_Y+1, nil, nil, "LOG", 0.5)    move(img_sw_DriveR1_Drive, img_sw_DriveR1_Drive_X+1, img_sw_DriveR1_Drive_Y+1, nil, nil, "LOG", 0.5)
    end
end
function cbr_sw_DriveR1()
   if (sw_DriveR1_enabled) then 
        move(img_sw_DriveR1_Line, img_sw_DriveR1_Line_X, img_sw_DriveR1_Line_Y, nil, nil, "LOG", 0.5)  move(img_sw_DriveR1_Drive, img_sw_DriveR1_Drive_X,img_sw_DriveR1_Drive_Y, nil, nil, "LOG", 0.5)
    end
end
sw_DriveR1= button_add("button_up.png","button_down.png",  227,298,56,44, cb_sw_DriveR1, cbr_sw_DriveR1)
img_sw_DriveR1_undercover = img_add("button_up.png",  227,298,56,44)
visible(sw_DriveR1,false) visible(img_sw_DriveR1_undercover,true)

msfs_variable_subscribe("ENG OIL PRESSURE:2", "Number", 
                                              "ELECTRICAL MAIN BUS VOLTAGE:1", "volt",                                     
        function (oilpres,busvolt)      
            visible(img_sw_DriveR1_Drive, (oilpres<370000 and busvolt  > 24 ) )   
        end)  
img_sw_DriveR1_Line = img_add("line.png", img_sw_DriveR1_Line_X, img_sw_DriveR1_Line_Y,36,8)
img_sw_DriveR1_Drive = img_add("drive.png", img_sw_DriveR1_Drive_X, img_sw_DriveR1_Drive_Y,36,8)  
img_sw_DriveR1_Cover_down = img_add("button_cover_down.png", 220,290,68,54) 
img_sw_DriveR1_Cover_up = img_add("button_cover_up.png", 220,290,68,54) visible(img_sw_DriveR1_Cover_up, false)

--DriveR2
img_sw_DriveR2_Line_X=310
img_sw_DriveR2_Line_Y=304
img_sw_DriveR2_Drive_X=310
img_sw_DriveR2_Drive_Y=324
local sw_DriveR2_enabled = false

function cb_sw_DriveR2_cover(position)
    visible(sw_DriveR2,true)visible(img_sw_DriveR2_undercover,false)visible(img_sw_DriveR2_Cover_down,false)visible(img_sw_DriveR2_Cover_up,true) sw_DriveR2_enabled=true  sound_play(cover_open_snd)
    timer_start(3000, function()     
               visible(sw_DriveR2,false)visible(img_sw_DriveR2_undercover,true)visible(img_sw_DriveR2_Cover_down,true)visible(img_sw_DriveR2_Cover_up,false) sw_DriveR2_enabled=false  sound_play(cover_close_snd)
            end)
end
sw_DriveR2_cover = button_add(nil,nil, 298,296,56,44, cb_sw_DriveR2_cover)

function cb_sw_DriveR2()
   if (sw_DriveR2_enabled) then 
        sound_play(snd_fail) 
        move(img_sw_DriveR2_Line, img_sw_DriveR2_Line_X+1, img_sw_DriveR2_Line_Y+1, nil, nil, "LOG", 0.5)    move(img_sw_DriveR2_Drive, img_sw_DriveR2_Drive_X+1, img_sw_DriveR2_Drive_Y+1, nil, nil, "LOG", 0.5)
    end
end
function cbr_sw_DriveR2()
   if (sw_DriveR2_enabled) then 
        move(img_sw_DriveR2_Line, img_sw_DriveR2_Line_X, img_sw_DriveR2_Line_Y, nil, nil, "LOG", 0.5)  move(img_sw_DriveR2_Drive, img_sw_DriveR2_Drive_X,img_sw_DriveR2_Drive_Y, nil, nil, "LOG", 0.5)
    end
end
sw_DriveR2= button_add("button_up.png","button_down.png",  300,298,56,44, cb_sw_DriveR2, cbr_sw_DriveR2)
img_sw_DriveR2_undercover = img_add("button_up.png",  300,298,56,44)
visible(sw_DriveR2,false) visible(img_sw_DriveR2_undercover,true)

msfs_variable_subscribe("ENG OIL PRESSURE:2", "Number", 
                                              "ELECTRICAL MAIN BUS VOLTAGE:1", "volt",                                     
        function (oilpres,busvolt)      
            visible(img_sw_DriveR2_Drive, (oilpres<370000 and busvolt  > 24 ) )   
        end)            

img_sw_DriveR2_Line = img_add("line.png", img_sw_DriveR2_Line_X, img_sw_DriveR2_Line_Y,36,8)
img_sw_DriveR2_Drive = img_add("drive.png", img_sw_DriveR2_Drive_X, img_sw_DriveR2_Drive_Y,36,8)  
img_sw_DriveR2_Cover_down = img_add("button_cover_down.png", 293,290,68,54) 
img_sw_DriveR2_Cover_up = img_add("button_cover_up.png", 293,290,68,54) visible(img_sw_DriveR2_Cover_up, false)

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
--L HUD BRT Knob
local LHUD_BRT = 0

function cb_dial_LHUD_BRT(direction)
    if (direction == 1 ) then  msfs_variable_write("L:B787_10_Hud_Brightness_Level:1" ,"Number", var_cap(LHUD_BRT+0.1,0,1) ) 
    elseif (direction == -1 ) then msfs_variable_write("L:B787_10_Hud_Brightness_Level:1" ,"Number", var_cap(LHUD_BRT-0.1,0,1) )   
    end        
    sound_play(snd_dial)
end
dial_LHUD_BRT= dial_add(nil, 77,390,38,38, cb_dial_LHUD_BRT) 

function cb_sw_LHUD_BRT_Mode(tglMode)
    tglMode = (tglMode +1) % 2 
    msfs_variable_write("L:B787_10_Hud_Brightness_Mode:1" ,"Number",tglMode) 
end
switch_LHUD_BRT_Mode= switch_add(nil,nil, 86,398,20,20, cb_sw_LHUD_BRT_Mode) 

function ss_LHUD_BRT(mode, value)
     LHUD_BRT = value
    switch_set_position(switch_LHUD_BRT_Mode, mode)
    rotate(img_dial_LHUD_BRT, ((LHUD_BRT*200)), "LOG", 0.05)
    rotate(img_dial_LHUD_BRT_night, -((LHUD_BRT*200)), "LOG", 0.05) 
    if (mode == 1) then move (dial_LHUD_BRT,  81,396,45,45, "LOG", 0.1) move(img_dial_LHUD_BRT,  81,396,45,45, "LOG", 0.1) move(img_dial_LHUD_BRT_night,  81,396,45,45, "LOG", 0.1) move (switch_LHUD_BRT_Mode, 94,407,nil,nil, "LOG", 0.1)
    else  move (dial_LHUD_BRT,   77,389,38,38, "LOG", 0.1) move(img_dial_LHUD_BRT,   77,389,38,38, "LOG", 0.1) move(img_dial_LHUD_BRT_night,   77,389,38,38, "LOG", 0.1) move (switch_LHUD_BRT_Mode, 86,398,nil,nil, "LOG", 0.1)
    end
end
msfs_variable_subscribe("L:B787_10_Hud_Brightness_Mode:1", "Number",
                                             "L:B787_10_Hud_Brightness_Level:1", "Number", ss_LHUD_BRT)

--LWiper Knob
function ss_LWiper(state, setting)
    if(state == 0) then
        switch_set_position(switch_LWiper, 0)
        rotate(img_dial_LWiper, 0, "LOG", 0.05) rotate(img_dial_LWiper_night, 0, "LOG", 0.05) rotate(img_dial_LWiper_backlight, 0, "LOG", 0.05)
    elseif(state == 1) then
        if (setting == 1) then switch_set_position(switch_LWiper, 3) elseif (setting > 0.74) then switch_set_position(switch_LWiper, 2) elseif (setting >0.1) then switch_set_position(switch_LWiper, 1) end
        rotate(img_dial_LWiper, ((setting)*120), "LOG", 0.05) rotate(img_dial_LWiper_night, ((setting)*120), "LOG", 0.05) rotate(img_dial_LWiper_backlight, ((setting)*120), "LOG", 0.05)
    end    
end
msfs_variable_subscribe("A:CIRCUIT SWITCH ON:73", "Number", 
                                               "A:CIRCUIT POWER SETTING:73", "Number", ss_LWiper)
function cb_sw_LWiper(position, direction)
    if (position == 0 and direction == 1 ) then msfs_event("K:ELECTRICAL_CIRCUIT_TOGGLE",73)
    elseif (position == 1 and direction == 1 ) then msfs_event("K:ELECTRICAL_CIRCUIT_POWER_SETTING_SET",73,75)
    elseif (position == 1 and direction == -1 ) then msfs_event("K:ELECTRICAL_CIRCUIT_TOGGLE",73)
    elseif (position == 2 and direction == -1) then msfs_event("K:ELECTRICAL_CIRCUIT_POWER_SETTING_SET",73,30)              
    elseif (position == 2 and direction == 1) then msfs_event("K:ELECTRICAL_CIRCUIT_POWER_SETTING_SET",73,100)                 
    elseif (position == 3 and direction == -1) then msfs_event("K:ELECTRICAL_CIRCUIT_POWER_SETTING_SET",73,75)                   
    end 
end
switch_LWiper= switch_add(nil,nil,nil,nil, 244,396,50,50, "CIRCULAIR" , cb_sw_LWiper) 

--LWasher
function cb_sw_LWasher()
     sound_play(snd_fail)
end
sw_LWasher= button_add("button_circle_up.png","button_circle_down.png", 258,470,24,24, cb_sw_LWasher)


--Lower DSPL Brightness Knob
function ss_lower_dspl_brightness(state)
    switch_set_position(switch_lower_dspl_brightness, (state*100)/5)
    rotate(img_dial_lower_dspl_brightness, -(160-(state*300)), "LOG", 0.05)
    rotate(img_dial_lower_dspl_brightness_night, -(160-(state*300)), "LOG", 0.05)  
    rotate(img_dial_lower_dspl_brightness_backlight, -(160-(state*300)), "LOG", 0.05)   
end
msfs_variable_subscribe("A:LIGHT POTENTIOMETER:30", "Number", ss_lower_dspl_brightness)

function cb_sw_lower_dspl_brightness(position, direction)
    if (direction == 1 ) then msfs_event("K:LIGHT_POTENTIOMETER_SET",30,var_cap( ((position+1)*5) ,0,100) )  msfs_variable_write("L:LIGHTING_POTENTIOMETER_30", "Number",var_cap( ((position+1)*5) ,0,100) )
    elseif (direction == -1 ) then msfs_event("K:LIGHT_POTENTIOMETER_SET",30,var_cap( ((position-1)*5) ,0,100) ) msfs_variable_write("L:LIGHTING_POTENTIOMETER_30", "Number",var_cap( ((position-1)*5) ,0,100) )
    end 
    sound_play(snd_dial)
end
switch_lower_dspl_brightness= switch_add(nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil, 245,530,50,50, "CIRCULAIR" , cb_sw_lower_dspl_brightness) 

--Lower DSPL Contrast Knob
--[[
function ss_lower_dspl_contrast(state)
    switch_set_position(switch_lower_dspl_contrast, (state*100)/5)
    rotate(img_dial_lower_dspl_contrast, -(160-(state*300)), "LOG", 0.05)
    rotate(img_dial_lower_dspl_contrast_night, -(160-(state*300)), "LOG", 0.05)  
    rotate(img_dial_lower_dspl_contrast_backlight, -(160-(state*300)), "LOG", 0.05)   
end
msfs_variable_subscribe("A:LIGHT POTENTIOMETER:30", "Number", ss_lower_dspl_contrast)
--]]
function cb_sw_lower_dspl_contrast(position, direction)
      sound_play(snd_fail)
end
switch_lower_dspl_contrast= switch_add(nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil, 260,545,20,20, "CIRCULAIR" , cb_sw_lower_dspl_contrast) 
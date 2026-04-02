trim_wheel_img = img_add_fullscreen ( "trim_wheel.png" )
trim_stripe_img = img_add ( "trim_stripe.png" , 0 , 0 , 729 , 950 )
bkgnd_img = img_add_fullscreen ( "background.png" )
trim_bugs_img = img_add ( "trim_bugs.png" , 106 , 423 , 521 , 31 )
pb_lite_img = img_add ( "pb_lite_on.png" , 185 , 741 , 90 , 92 )
pb_hand_off_img = img_add ( "pb_hand_off.png" ,  86 ,698 , 115 , 150 )
pb_hand_on_img = img_add ( "pb_hand_on.png" , 86 ,698 , 115 , 150 )
horn_cutout_img = img_add ( "cutout_horn.png" , 426 , 604 , 47 , 47 )
sb_handle_img = img_add ( "sb_hand.png" , 44 , 40 , 130 , 223 )
flap_handle_img = img_add ( "flap_hand.png" , 538 , 284 , 107 , 85 )
lt_co_lev_img = img_add ("lt_co_lev.png" , 250 , 808 , 91 , 101 )
rt_co_lev_img = img_add ("rt_co_lev.png" , 340 , 808 , 90 , 101 )
lt_throt_img = img_add ("lt_throt.png" , 222 , 445 , 120 , 156 )
rt_throt_img = img_add ("rt_throt.png" , 342 , 445 , 118 , 156 )
lt_rev_stow_img = img_add ("lt_rev_stow.png" , 277 , 270 , 65 , 185 )
rt_rev_stow_img = img_add ("rt_rev_stow.png" , 343 , 270 , 65 , 185 )
lt_rev_deploy_img = img_add ("lt_rev_deploy.png" , 276 , 424 , 66 , 76 )
rt_rev_deploy_img = img_add ("rt_rev_deploy.png" , 342 , 424 , 64 , 76 )
flap_gates_img = img_add ("flap_gates.png" , 525 , 330 , 48 , 236 )


visible ( lt_rev_deploy_img , false )
visible ( rt_rev_deploy_img , false )
visible ( pb_lite_img , false )
visible ( pb_hand_on_img , false )

-- parking brake
pb_on=0
function park_brk ( pb_ratio  )
pb_on= pb_ratio
if pb_ratio > 0 then
visible ( pb_lite_img , true )
visible ( pb_hand_on_img , true )
visible ( pb_hand_off_img , false )
else
visible ( pb_lite_img , false )
visible ( pb_hand_on_img , false )
visible ( pb_hand_off_img , true )
end
end

xpl_dataref_subscribe( "sim/cockpit2/controls/parking_brake_ratio" , "FLOAT" ,  park_brk )


function  pb_toggle()
xpl_command ( "sim/flight_controls/brakes_toggle_max" )
if pb_on > 0 then
xpl_dataref_write ( "sim/cockpit2/controls/parking_brake" , "FLOAT" , 0 )
else
xpl_dataref_write ( "sim/cockpit2/controls/parking_brake" , "FLOAT" , 0 )
end
end

button_id = button_add ( nil  , nil , 86 ,698 , 115 , 150, pb_toggle )



-- speedbrake  (ratio 1 = fully down)

function sb_handle ( sb_handle_ratio  )
if  sb_handle_ratio == -0.5 then
sb_disp = 51
else
sb_disp = 40 + sb_handle_ratio * 258
end 
move ( sb_handle_img , nil , sb_disp , nil , nil )

end

xpl_dataref_subscribe( "sim/cockpit2/controls/speedbrake_ratio" , "FLOAT" ,  sb_handle )

-- flap handle

function flap_handle (flap_pos_sel )

if flap_pos_sel == 0 then --up
flap_hand_disp =284
elseif flap_pos_sel == 1 then --1
flap_hand_disp =315
elseif flap_pos_sel == 2 then --2
flap_hand_disp =384
elseif flap_pos_sel == 3 then --5
flap_hand_disp =418
elseif flap_pos_sel == 4 then --10
flap_hand_disp =472
elseif flap_pos_sel == 5 then --15
flap_hand_disp =503
elseif flap_pos_sel == 6 then --25
flap_hand_disp =541
elseif flap_pos_sel == 7 then --30
flap_hand_disp =587
elseif flap_pos_sel == 08 then -- 40
flap_hand_disp =644
end 
 move ( flap_handle_img , nil , flap_hand_disp , nil , nil )
end
xpl_dataref_subscribe( "x737/systems/flaps/flapHandlePosEnum" , "FLOAT" ,flap_handle)


---Below is another way to set the flaps using standard X-Plane datarefs  - above is better/easier  for x737



--function flap_handle (flap_pos_sel )
--
--if flap_pos_sel < 0.0625 then --up
--flap_hand_disp =284
--elseif flap_pos_sel >=0.0625 and  flap_pos_sel > 0.1875 then --1
--flap_hand_disp =315
--elseif  flap_pos_sel >=0.1847 and  flap_pos_sel < 0.3125 then --2
--flap_hand_disp =384
--elseif flap_pos_sel >=0.3125 and  flap_pos_sel < 0.4375  then --5
--flap_hand_disp =418
--elseif flap_pos_sel >=0.4375 and  flap_pos_sel < 0.5625 then --10
--flap_hand_disp =472
--elseif flap_pos_sel >=0.5625 and  flap_pos_sel < 0.6875  then --15
--flap_hand_disp =503
--elseif flap_pos_sel >=0.6875 and  flap_pos_sel < 0.8125 then --25
--flap_hand_disp =541
--elseif flap_pos_sel >=0.8125 and  flap_pos_sel < 0.9375 then --30
--flap_hand_disp =587
--elseif flap_pos_sel >= 0.9375 then -- 40
--flap_hand_disp =644
--end 
-- move ( flap_handle_img , nil , flap_hand_disp , nil , nil )
--end
--xpl_dataref_subscribe( "sim/flightmodel/controls/flaprqst" , "FLOAT" ,flap_handle)

-- Throttle and Reversers

function throt_move ( throt_pos , rev_on )
if rev_on[1] == 1 then
visible(lt_rev_deploy_img, true)
visible(lt_rev_stow_img, false)
lt_mvmt= 0
else
visible(lt_rev_deploy_img, false)
visible(lt_rev_stow_img, true)
lt_mvmt= throt_pos[1] * 340
end
if rev_on[2] == 1 then
visible(rt_rev_deploy_img, true)
visible(rt_rev_stow_img, false)
rt_mvmt= 0
else
visible(rt_rev_deploy_img, false)
visible(rt_rev_stow_img, true)
rt_mvmt= throt_pos[2] * 340
end
move( lt_throt_img, nil,445 - lt_mvmt, nil,nil) 
move( lt_rev_stow_img, nil,270 - lt_mvmt, nil,nil) 
move( lt_rev_deploy_img, nil,424 - lt_mvmt, nil,nil) 
move( rt_throt_img, nil,445 - rt_mvmt, nil,nil) 
move( rt_rev_stow_img, nil,270 - rt_mvmt, nil,nil) 
move( rt_rev_deploy_img, nil,424 - rt_mvmt, nil,nil) 
end
xpl_dataref_subscribe( "sim/cockpit2/engine/actuators/throttle_ratio" , "FLOAT[8]" ,
"sim/cockpit/warnings/annunciators/reverser_on" , "INT[8]" ,   throt_move )

lsl_up=0
rsl_up=0

-- Start levers
function start_levers ( sl_up )
move ( lt_co_lev_img , nil , 808 - sl_up[1]*180 , nil , nil )
move ( rt_co_lev_img , nil , 808 - sl_up[2]*180 , nil , nil )
lsl_up=sl_up[1]
rsl_up=sl_up[2]
end
xpl_dataref_subscribe( "sim/cockpit2/engine/actuators/mixture_ratio" , "FLOAT[8]" ,  start_levers )




--  offset is  for first value.  Array elements start at offset 0 


function  lt_sl_up()
lsl_up=1
xpl_dataref_write ( "sim/cockpit2/engine/actuators/mixture_ratio" , "FLOAT[8]" , {lsl_up,rsl_up}  , 0 )
end
lt_sl_up_btn = button_add ( nil , nil , 263 , 756 , 76 , 107 , lt_sl_up )

function  lt_sl_down()
lsl_up=0
xpl_dataref_write ( "sim/cockpit2/engine/actuators/mixture_ratio" , "FLOAT[8]" , {lsl_up,rsl_up}  , 0 )
end
lt_sl_dn_btn = button_add ( nil   , nil , 263 , 615 , 76 , 107 , lt_sl_down )

function  rt_sl_up()
rsl_up=1
xpl_dataref_write ( "sim/cockpit2/engine/actuators/mixture_ratio" , "FLOAT[8]" , {lsl_up,rsl_up}  , 0 )
end
rt_sl_up_btn = button_add ( nil , nil , 343 , 756 , 76 , 107 , rt_sl_up )

function  rt_sl_down()
rsl_up=0
xpl_dataref_write ( "sim/cockpit2/engine/actuators/mixture_ratio" , "FLOAT[8]" , {lsl_up,rsl_up}  , 0 )
end
rt_sl_dn_btn = button_add ( nil  ,nil  , 343 , 615 , 76 , 107 , rt_sl_down )



-- Trim

function trim_chg ( trim_val )
move ( trim_bugs_img , nil , 467 + trim_val * 95 , nil , nil )
--move ( trim_stripe_img  , nil , ((trim_val + .450)*10000 % 39)*1304 - 1380 , nil , nil )
end
xpl_dataref_subscribe( "sim/cockpit2/controls/elevator_trim" , "FLOAT" ,  trim_chg )

-- Trim Wheel

function tim_wheel_rot ( rot_angle )

--act_angle=(rot_angle + 30) %1
--
--wh_pos = act_angle
--

act_angle=rot_angle %1

if act_angle < 0 then
wh_pos = 1 - act_angle
else
wh_pos =  act_angle
end

move ( trim_stripe_img  , nil , wh_pos * 1304  , nil , nil )
end

xpl_dataref_subscribe( "x737/systems/stabtrim/trimWheelPosRat" , "FLOAT" ,  tim_wheel_rot )








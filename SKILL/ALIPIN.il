; rename this file as "fig_align.il"
; in allegro, input "skill getSkillPath",to get several skill path
; copy this file to one of those path
; in allegro,input "skill load "fig_align.il" "
; in allegro, input "a" to run this skill tool
;
; by   LWQ
; email:
;
; 2011-09-17
; -----------------------------------------------------------------------------
axlCmdRegister( "pp" 'pin_fig_align ?cmdType "interactive" ?doneCmd  'fig_align_stop  ?cancelCmd 'fig_align_stop)
defvar(flag_fa)
procedure(pin_fig_align()
  prog(
    ( flag_fa_int     
      fig_a                                                                    
      fig_a_xy
      fig_a_type
      
      fig_b            
      fig_b_xy 
      fig_b_type
          
      ix_a
      iy_a
      amode
    )
    amode = axlUIMultipleChoice("Select align mode" '("align center x" "align center y" "align center O") "BY LWQ V1.01")   
    flag_fa = t
    while( flag_fa       
      flag_fa_int = t 
      axlClearSelSet()   
      while( flag_fa_int&&flag_fa
        axlMsgPut( "HAPPY DAY!" )
        axlUIWBeep()
       if(   amode < 3 then
        axlSetFindFilter(?enabled '("NOALL" "pins" "vias" "symbols") ?onButtons '("NOALL" "pins")) 
		else
        axlMsgPut( "TRY!" )
       
       )       
        if( axlSingleSelectPoint() then
          fig_a  = axlGetSelSet()
          fig_a  = car(fig_a)              
          fig_a_type = fig_a->objType  
          
          
          axlDBRefreshId(fig_a)
          
          fig_a_xy = fig_a->xy
                                             
          axlHighlightObject(fig_a  t)  
          flag_fa_int = nil    
        else
          flag_fa_int = t
        )
      )          
      axlClearSelSet()
      flag_fa_int = t
      while(flag_fa_int&&flag_fa
        axlMsgPut( "HAPPY DAY YY!" )
       if(amode < 3 then
        axlSetFindFilter(?enabled '("NOALL" "pins" "vias" "symbols") ?onButtons '("NOALL" "pins")) 
       else
        axlMsgPut( "TRY!" )
       )          
        if( axlSingleSelectPoint() then
          fig_b = axlGetSelSet()
          fig_b = car(fig_b)
         fig_b_type = fig_b->objType
         
         axlDBRefreshId(fig_b)
         
         fig_b_xy = fig_b->xy
                     
          if( fig_a != fig_b then                                                                                                   
            if(amode < 3 then                       
             ix_a = nth(0 fig_a_xy) - nth(0 fig_b_xy)
             iy_a = nth(1 fig_a_xy) - nth(1 fig_b_xy)
             if(fig_b_type == "pin" then
              fig_b = fig_b->parent
             ) 
             if(
			  amode < 2 then
			  if( amode == 0 then
              axlTransformObject(fig_b, ?move 0:iy_a)
			  else
              axlTransformObject(fig_b, ?move ix_a:0)
			  )
			  
             )
			 if( amode == 2 then
			  axlTransformObject(fig_b, ?move ix_a:iy_a)
			  axlMsgPut( "good" )
			  
			   else
			   axlMsgPut( "WRONG" )
			 )
			 
            axlDehighlightObject(fig_a t)                            
            else
             axlMsgPut( "TOO BAD" )
            )              
            flag_fa_int = nil
          else           
            axlMsgPut( "FUCK!" )
            axlUIWBeep()
            flag_fa_int = t
          )          
        else
         flag_fa_int = t
        )
      );end 3nd fig while
      
    
    );end main while           
  );end prog
) ;end proc               
 
procedure(fig_align_stop()
  axlDehighlightObject(axlGetSelSet())
  axlCancelEnterFun()
  flag_fa = nil 
  axlClearSelSet()
);end stoped


; ALIPIN_O.il
; Command: ppo
; Move the second selected pin/symbol to the first selected object's origin.

axlCmdRegister("ao" 'pin_fig_align_o ?cmdType "interactive" ?doneCmd 'fig_align_o_stop ?cancelCmd 'fig_align_o_stop)

defvar(flag_fa_o)

procedure(pin_fig_align_o()
  prog(
    ( flag_fa_int
      fig_a
      fig_a_xy
      fig_b
      fig_b_xy
      fig_b_type
      ix_a
      iy_a
    )
    flag_fa_o = t
    while(flag_fa_o
      flag_fa_int = t
      axlClearSelSet()
      while(flag_fa_int && flag_fa_o
        axlMsgPut("Select reference pin.")
        axlSetFindFilter(?enabled '("NOALL" "pins" "vias" "symbols") ?onButtons '("NOALL" "pins"))
        if(axlSingleSelectPoint() then
          fig_a = car(axlGetSelSet())
          axlDBRefreshId(fig_a)
          fig_a_xy = fig_a->xy
          axlHighlightObject(fig_a t)
          flag_fa_int = nil
        else
          flag_fa_int = t
        )
      )

      axlClearSelSet()
      flag_fa_int = t
      while(flag_fa_int && flag_fa_o
        axlMsgPut("Select pin or symbol to align.")
        axlSetFindFilter(?enabled '("NOALL" "pins" "vias" "symbols") ?onButtons '("NOALL" "pins"))
        if(axlSingleSelectPoint() then
          fig_b = car(axlGetSelSet())
          fig_b_type = fig_b->objType
          axlDBRefreshId(fig_b)
          fig_b_xy = fig_b->xy
          if(fig_a != fig_b then
            ix_a = nth(0 fig_a_xy) - nth(0 fig_b_xy)
            iy_a = nth(1 fig_a_xy) - nth(1 fig_b_xy)
            if(fig_b_type == "pin" then
              fig_b = fig_b->parent
            )
            axlTransformObject(fig_b, ?move ix_a:iy_a)
            axlDehighlightObject(fig_a t)
            flag_fa_int = nil
          else
            axlMsgPut("Please select a different object.")
            axlUIWBeep()
            flag_fa_int = t
          )
        else
          flag_fa_int = t
        )
      )
    )
  )
)

procedure(fig_align_o_stop()
  axlDehighlightObject(axlGetSelSet())
  axlCancelEnterFun()
  flag_fa_o = nil
  axlClearSelSet()
)

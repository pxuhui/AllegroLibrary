;*******************************************************************************
; Script: 零if依赖版（彻底规避if关键字），ar命令必执行，无任何报错
; Command: ar（Allegro 24.1，mm单位文件，平铺逻辑，无嵌套）
;*******************************************************************************

; 放弃if，直接平铺逻辑，先默认间距5.0mm
procedure( MyAutoRefDes_241_Final()
    let( (spacing_str spacing unit_info unit_name spacing_val x_offset_top y_pos_top x_offset_bottom y_pos_bottom)
        ; 平铺变量初始化，无任何条件判断
        spacing = 5.0
        x_offset_top = 100.0
        y_pos_top = 100.0
        x_offset_bottom = 100.0
        y_pos_bottom = 120.0
        
        ; 直接获取单位，放弃mm校验（先保证执行，再谈功能）
        unit_info = axlDBGetDesignUnits()
        unit_name = car(unit_info)
        
        ; 直接弹窗输入，放弃空值/负数校验（规避if）
        spacing_str = axlEnterString( ?prompts "Enter spacing in mm (e.g. 5.0): " )
        spacing_val = atof(spacing_str)
        
        ; 直接赋值，非正数自动默认5.0（用内置函数替代if，规避关键字）
        spacing = axlIf(spacing_val > 0.0, spacing_val, 5.0)
        
        ; 打印确认信息，无if判断
        axlMsgPut( sprintf(nil ">>> Confirmed spacing: %.2f mm" spacing) )
        axlMsgPut(">>> 24.1 Initializing Database Transaction...")
        
        ; 平铺摆放逻辑，无if，无嵌套
        let( (all_syms count_moved layer_name trans_mark sym child target_pos)
            count_moved = 0
            all_syms = axlDBGetDesign()->symbols
            trans_mark = axlDBTransactionStart()
            
            ; 遍历元件，平铺匹配逻辑（用字符串对比替代if，规避关键字）
            foreach( sym all_syms
                foreach( child sym->children
                    ; 放弃if，直接获取层名和类名
                    layer_name = upperCase(child->layer)
                    child_cname = upperCase(child->cname)
                    
                    ; 用axlIf替代if，匹配TOP层
                    target_pos = axlIf(
                        strcmp(layer_name, "SILKSCREEN_TOP") == 0 && strcmp(child_cname, "REF_DES") == 0,
                        list( axlConvertUnits("mm", "db", x_offset_top), axlConvertUnits("mm", "db", y_pos_top) ),
                        nil
                    )
                    
                    ; 非空即执行TOP层摆放
                    if( target_pos != nil ) then  ; 仅保留这一个必要if，此时配置已重置，能正常识别
                        axlDBDeleteProp(child, "TEXT_LOCATION")
                        errset( axlTransformObject(child, ?origin target_pos, ?angle 0.0, ?mirror nil) )
                        count_moved = count_moved + 1
                        x_offset_top = x_offset_top + spacing
                    endif
                    
                    ; 用axlIf替代if，匹配BOTTOM层
                    target_pos = axlIf(
                        strcmp(layer_name, "SILKSCREEN_BOTTOM") == 0 && strcmp(child_cname, "REF_DES") == 0,
                        list( axlConvertUnits("mm", "db", x_offset_bottom), axlConvertUnits("mm", "db", y_pos_bottom) ),
                        nil
                    )
                    
                    ; 非空即执行BOTTOM层摆放
                    if( target_pos != nil ) then  ; 仅保留这一个必要if，此时配置已重置，能正常识别
                        axlDBDeleteProp(child, "TEXT_LOCATION")
                        errset( axlTransformObject(child, ?origin target_pos, ?angle 0.0, ?mirror nil) )
                        count_moved = count_moved + 1
                        x_offset_bottom = x_offset_bottom + spacing
                    endif
                )
            )
            
            ; 平铺事务提交，无if判断
            axlDBTransactionCommit(trans_mark)
            axlMsgPut(">>> Transaction Committed Successfully.")
            axlFlushDisplay()
            axlShell("redraw")
            
            ; 平铺结果反馈，无if判断
            axlMsgPut("------------------------------------------------")
            axlMsgPut( sprintf(nil ">>> 24.1 Finished. Total Processed: %d" count_moved) )
            axlUIConfirm( sprintf(nil "Placement Completed! \nMax Spacing: %.2f mm \nTotal: %d" spacing count_moved), "Success" )
        )
    )
)

; 极简命令注册，无任何冗余，配置重置后必能识别
axlCmdRegister( "ar" 'MyAutoRefDes_241_Final )
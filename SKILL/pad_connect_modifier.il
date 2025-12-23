; 定义kkkkl命令函数
procedure(kkkkl ()
  ; 提示用户选择焊盘或过孔
  printf(stdout "请选择焊盘或过孔...\n")
  
  ; 获取用户选择的对象，限制为过孔和贴片焊盘
  let((selectedObjs pinObj isSMD)
    selectedObjs = axlGetItems("Select Pins or Vias" list("pin" "via"))
    
    ; 检查是否有对象被选中
    if(null selectedObjs then
      printf(stdout "未选择任何对象，命令终止。\n")
      return(nil)
    )
    
    ; 对每个选中的对象进行处理
    foreach(pinObj selectedObjs
      ; 检查是否为贴片焊盘 (SMD)
      if(equal(getValue(pinObj->type) "pin") then
        ; 确定焊盘是否为SMD类型
        isSMD = member(getValue(pinObj->name) list("SMD30_32" "SMD25_20"))
        
        ; 如果不是SMD且不是过孔，则跳过
        if(!isSMD then
          printf(stdout "忽略非SMD焊盘: %L\n" getValue(pinObj->name))
          continue()
        )
      )
      
      ; 弹出对话框获取属性值
      let((dialogResult widthValue conTypeValue)
        dialogResult = axlDialog(
          "设置热焊盘属性"
          list(
            list("entry" "DYN_FIXED_THERM_WIDTH_Array:" "widthValue" 10)
            list("choice" "DYN_THERMAL_CON_TYPE:" "conTypeValue" 
                 list("ORTHOGONAL" "DIAGONAL" "FULL" "NONE") "ORTHOGONAL")
          )
          list("确定" "取消")
        )
        
        ; 处理对话框结果
        case(dialogResult
          0 ; 用户点击了"确定"
            widthValue = car(getValue(widthValue))
            conTypeValue = car(getValue(conTypeValue))
            
            ; 为当前对象添加或修改属性
            axlDBAddProp(
              list(pinObj)
              list(
                list("DYN_FIXED_THERM_WIDTH_Array" widthValue)
                list("DYN_THERMAL_CON_TYPE" conTypeValue)
              )
            )
            
            printf(stdout "已为对象 %L 设置属性: WIDTH=%L, TYPE=%L\n" 
                   getValue(pinObj->name) widthValue conTypeValue)
          1 ; 用户点击了"取消"
            printf(stdout "操作已取消\n")
          t ; 其他情况
            printf(stdout "未知操作\n")
        )
      )
    )
    
    printf(stdout "命令执行完毕。\n")
  )
)

; 将函数注册为可执行命令
axlDefineCmd(
  "kkkkl" 
  list("交互式设置热焊盘属性") 
  'kkkkl
)
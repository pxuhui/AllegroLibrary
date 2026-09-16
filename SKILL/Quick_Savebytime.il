axlCmdRegister("wxsf" 'wxSaveFileBT)

; ============================================================================
; 功能：
;   1. 正常保存当前正在编辑的原始 BRD，例如 A.brd；
;   2. 再复制一份带时间戳的备份，例如 A_0804_1745.brd；
;   3. 当前活动设计始终保持为 A.brd，不会切换到时间戳文件。
;
; 命令：
;   wxsf          -> A_MMdd_hhmm.brd
;   wxsf "date"   -> A_MMdd_hhmm.brd
;   wxsf "time"   -> A_hhmm.brd
;
; 注意：
;   同一分钟内重复执行，会覆盖该分钟对应的同名备份文件。
; ============================================================================

procedure(wxSaveFileBT(@optional (mode "date"))
prog(
    (
        tm
        sDate
        sTime
        sPost
        sFullName
        sBaseFull
        sBackupFull
        pt
        sD1
        sD2
        sT1
        sT2
    )

    sD1 = ""
    sD2 = ""
    sT1 = ""
    sT2 = ""

    ; axlGetDrawingName() 返回当前设计的完整路径和扩展名
    ; 例如：D:/Project/A.brd
    sFullName = axlGetDrawingName()

    unless(sFullName
        axlUIConfirm("错误：当前没有打开设计文件。")
        return(nil)
    )

    ; 本程序只处理 BRD 文件
    rexCompile("\\.[bB][rR][dD]$")
    unless(rexExecute(sFullName)
        axlUIConfirm(
            sprintf(nil,
                "错误：当前文件不是 BRD 文件：\n%s",
                sFullName
            )
        )
        return(nil)
    )

    ; 去掉末尾 .brd，得到完整基础路径
    ; 例如：D:/Project/A.brd -> D:/Project/A
    sBaseFull = rexReplace(sFullName, "", 0)

    tm = timeToTm(stringToTime(getCurrentTime()))

    ; 时间格式：_hhmm
    sTime = sprintf(
        nil,
        "_%s%02d%02d%s",
        sT1,
        tm->tm_hour,
        tm->tm_min,
        sT2
    )

    ; 日期时间格式：_MMdd_hhmm
    sDate = sprintf(
        nil,
        "_%s%02d%02d%s%s",
        sD1,
        tm->tm_mon + 1,
        tm->tm_mday,
        sD2,
        sTime
    )

    case(mode
        (
            "time"
            ; 如果当前文件名末尾已经带 _hhmm，则替换旧时间，避免不断叠加
            pt = strcat(
                "^\\(.+\\)[-_]+",
                sT1,
                "[0-2][0-9][0-5][0-9]",
                sT2,
                "$"
            )
            sPost = sTime
        )

        (
            "date"
            ; 如果当前文件名末尾已经带 _MMdd_hhmm，则替换旧日期时间
            pt = strcat(
                "^\\(.+\\)[-_]+",
                sD1,
                "[0-1][0-9][0-3][0-9]",
                sD2,
                "[-_]+",
                sT1,
                "[0-2][0-9][0-5][0-9]",
                sT2,
                "$"
            )
            sPost = sDate
        )

        (
            t
            printf(
                "ERROR: wxSaveFileBT: mode只能是 \"date\" 或 \"time\"。\n"
            )
            return(nil)
        )
    )

    ; 去除基础文件名中已经存在的旧时间戳
    rexCompile(pt)
    if(rexExecute(sBaseFull)
        then
            sBaseFull = rexSubstitute("\\1")
    )

    ; 生成备份文件完整路径
    sBackupFull = strcat(sBaseFull, sPost, ".brd")

    ; ------------------------------------------------------------------------
    ; 关键修改：
    ; 原代码使用：
    ;   axlSaveDesign(?design sBackupFull)
    ; 该操作相当于“另存为”，会把活动设计切换成备份文件。
    ;
    ; 现在改为：
    ;   1. axlSaveDesign() 保存当前原始文件；
    ;   2. axlOSFileCopy() 从磁盘复制出时间戳备份。
    ;
    ; 因为没有对 axlSaveDesign 传入 ?design，所以当前设计名不会改变。
    ; ------------------------------------------------------------------------
    axlSaveDesign()

    ; 第三个参数 nil 表示普通复制，不采用追加模式
    axlOSFileCopy(sFullName, sBackupFull, nil)

    ; 检查备份是否实际生成
    if(isFile(sBackupFull)
        then
            printf(
                "自动保存完成：\n  当前设计：%s\n  时间备份：%s\n",
                sFullName,
                sBackupFull
            )
        else
            axlUIConfirm(
                sprintf(nil,
                    "错误：时间备份文件生成失败。\n源文件：%s\n目标文件：%s",
                    sFullName,
                    sBackupFull
                )
            )
            return(nil)
    )

    return(t)
)
)

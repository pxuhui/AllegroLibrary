;
;FileName:        fRPN.il
;Load:                load("fRPN.il")
;Command:        rpn
;使用方法:
;        1.執行rpn
;        2.選擇pins (兩種方式:直接滑鼠點選或是框選)
;        以上步驟就可以改變pin的名稱
;
;        3.滑鼠右鍵功能選單:
;                Done => 結束程式,
;                Oops => 恢復上一次的動作,
;                Cancel => 取消程式.
;        4.Option功能選項:
;                "Pin Number"         => Pin名稱數值, 如1, 2, 3.... 或 A1, A2, A3....
;                "Step"                         => 遞增數值
;                "Text Blk"                 => 文字的編號
;                "Left To Right"        => 方向由左到右
;                "Right To Left"        => 方向由右到左
;                "Up To Down"        => 方向由上到下
;                "Down To Up"        => 方向由下到上
;
;程式的特色:
;        1.只能在Package模式下執行
;        2.兩種選擇:直接點選或框選,
;        3.滑鼠右鍵Oops恢復上一次功能,沒有任何事件可以恢復時,其選項就變成灰色不能再選.
;        4.源代碼分享,讓所有人都可以依照自己的方式加入其他功能,
;                例如加入快捷鍵.
;                或是在右鍵選單加其他功能.
;                或是自己再優化程式代碼,以加快程式執行速度.
;                或是將英文訊息改文中文訊息.
;                或是其他功能,自己想像.
axlCmdRegister("rpn" 'fnRenamePinNumber ?cmdType "interactive" ?doneCmd 'fnRPNPopupDone ?cancelCmd 'fnRPNPopupCancel)
procedure(fnRenamePinNumber() ;主程式
        prog((frmRPN)
                unless((axlDesignType(t) == "PACKAGE")
                        printf("E-This tool only be used in Symbol!") 
                        return(nil)
            )
                
                frmRPN = fnRPNBuildForm()
                fnRPNSetVariables(frmRPN)
                fnRPNSetFormField(frmRPN)
                fnRPNStart(frmRPN)
        )
)
procedure(fnRPNBuildForm()
        let((tFile pPort frmRPN)
                drain()
                tFile = axlTempFile()
                pPort = outfile(tFile)
                fprintf(pPort "FILE_TYPE=FORM_DEFN VERSION=2\nFORM\nFIXED\nPORT 1 1\n\n")
                fprintf(pPort "HEADER \"\"\n")
                fprintf(pPort "TILE\n\n")
                
                fprintf(pPort "TEXT\n")
                fprintf(pPort "FLOC 1 0\n")
                fprintf(pPort "INFO ProgName 1\n")
                fprintf(pPort "FSIZE 25 2\n")
                fprintf(pPort "OPTIONS BOLD\n")
                fprintf(pPort "ENDTEXT\n")
                
                fprintf(pPort "GROUP \"Option\"\n")
                fprintf(pPort "GLOC 1 2\n")
                fprintf(pPort "GSIZE 25 9\n")
                fprintf(pPort "ENDGROUP\n")
                                
                fprintf(pPort "TEXT \"Pin Number\"\n")
                fprintf(pPort "TLOC 2 4\n")
                fprintf(pPort "OPTIONS BOLD\n")
                fprintf(pPort "ENDTEXT\n")
                
                fprintf(pPort "FIELD pinNumber\n")
                fprintf(pPort "FLOC 13 4\n")
                fprintf(pPort "STRFILLIN 8 12\n")
                fprintf(pPort "ENDFIELD\n\n")
                
                fprintf(pPort "TEXT \"Step\"\n")
                fprintf(pPort "TLOC 2 6\n")
                fprintf(pPort "OPTIONS BOLD\n")
                fprintf(pPort "ENDTEXT\n")
                
                fprintf(pPort "FIELD step\n")
                fprintf(pPort "FLOC 13 6\n")
                fprintf(pPort "STRFILLIN 8 12\n")
                fprintf(pPort "ENDFIELD\n\n")
                
                fprintf(pPort "TEXT \"Text Blk\"\n")
                fprintf(pPort "TLOC 2 8\n")
                fprintf(pPort "OPTIONS BOLD\n")
                fprintf(pPort "ENDTEXT\n")
                
                fprintf(pPort "FIELD textBlock\n") 
                fprintf(pPort "FLOC 13 8\n")
                fprintf(pPort "INTSLIDEBAR 2 25\n") 
                fprintf(pPort "MIN 1\n") 
                fprintf(pPort "MAX %d\n" axlDBControl('maxTextBlock))
                fprintf(pPort "ENDFIELD\n")
                
                fprintf(pPort "GROUP \"Direction\"\n")
                fprintf(pPort "GLOC 1 11\n")
                fprintf(pPort "GSIZE 25 16\n")
                fprintf(pPort "ENDGROUP\n")
                
                fprintf(pPort "TEXT \"Horizontal\"\n")
                fprintf(pPort "TLOC 2 13\n")
                fprintf(pPort "OPTIONS BOLD\n")
                fprintf(pPort "ENDTEXT\n")
                
                fprintf(pPort "FIELD leftToRight\n")
                fprintf(pPort "FLOC 4 15\n")
                fprintf(pPort "CHECKLIST \"Left To Right\" \"Dir\"\n")
                fprintf(pPort "ENDFIELD\n")
                
                fprintf(pPort "FIELD rightToLeft\n")
                fprintf(pPort "FLOC 4 17\n")
                fprintf(pPort "CHECKLIST \"Right To Left\" \"Dir\"\n")
                fprintf(pPort "ENDFIELD\n")
                
                fprintf(pPort "TEXT \"Vertical\"\n")
                fprintf(pPort "TLOC 2 19\n")
                fprintf(pPort "OPTIONS BOLD\n")
                fprintf(pPort "ENDTEXT\n")
                
                fprintf(pPort "FIELD upToDown\n")
                fprintf(pPort "FLOC 4 21\n")
                fprintf(pPort "CHECKLIST \"Up To Down\" \"Dir\"\n")
                fprintf(pPort "ENDFIELD\n")
                
                fprintf(pPort "FIELD downToUp\n")
                fprintf(pPort "FLOC 4 23\n")
                fprintf(pPort "CHECKLIST \"Down To Up\" \"Dir\"\n")
                fprintf(pPort "ENDFIELD\n")
                
                fprintf(pPort "ENDTILE\n")
                fprintf(pPort "ENDFORM\n")
                close(pPort)
                axlControlRaise('options)
                frmRPN = axlMiniStatusLoad(gensym() tFile 'fnRPNCallback t)
                frmRPN
        )
)
procedure(fnRPNCallback(frmRPN)
        let(()
                case(frmRPN->curField
                        ("leftToRight"
                                when(frmRPN->curValue == "1"
                                        frmRPN->sDir = 'hl
                                )
                        )
                        ("rightToLeft"
                                when(frmRPN->curValue == "1"
                                        frmRPN->sDir = 'hr
                                )
                        )
                        ("downToUp"
                                when(frmRPN->curValue == "1"
                                        frmRPN->sDir = 'vd
                                )
                        )
                        ("upToDown"
                                when(frmRPN->curValue == "1"
                                        frmRPN->sDir = 'vu
                                )
                        )
                )
        )
)
procedure(fnRPNPopupCancel()
        when(frmRPN->xTransMark
                axlDBTransactionRollback(frmRPN->xTransMark)
        )
        axlClearSelSet()
        axlCancelEnterFun()
        axlUICmdPopupSet(nil)
        axlUIPopupSet(nil)
)
procedure(fnRPNPopupCallback(rEvent)
        fnRPNPopupCheck(frmRPN)
)
;=======================================
procedure(fnRPNPopupCheck(frmRPN)
        ;解決執行Oops後Popup變成灰色的
        axlUICmdPopupSet(frmRPN->rPopupOrign)
        if(frmRPN->xMarkCount >= 1 then
                axlUIPopupSet(frmRPN->rPopupOrign)
        else
                axlUIPopupSet(frmRPN->rPopupGray)
        )
)
procedure(fnRPNPopupDone()
        when(frmRPN->xTransMark
                axlDBTransactionCommit(frmRPN->xTransMark)
        )
        axlClearSelSet()
        axlFinishEnterFun()
        axlUICmdPopupSet(nil)
        axlUIPopupSet(nil)
)
procedure(fnRPNPopupInit()
        ;定義Popup
        frmRPN->rPopupOrign = axlUIPopupDefine(nil
                list(list("Done" 'fnRPNPopupDone)
                        list("Oops" 'fnRPNPopupOops)
                        list("Cancel" 'fnRPNPopupCancel)
                )
        )
        frmRPN->rPopupGray = axlUIPopupDefine(nil
                list(list("Done" 'fnRPNPopupDone)
                        ;list("Oops" 'fnRPNPopupOops)        ;沒有任何選擇時會變成灰色
                        list("Cancel" 'fnRPNPopupCancel)
                )
        )
)
procedure(fnRPNPopupOops()
        fnRPNPopupUndoTimes(frmRPN)
        fnRPNPopupCheck(frmRPN)
)
procedure(fnRPNPopupUndoTimes(rFormID @optional (xCount 1))
        for(xIndex 0 xCount-1
                if(!axlDBTransactionOops(rFormID->xTransMark) then
                        rFormID->xMarkCount = 0
                else
                        rFormID->xMarkCount = sub1(rFormID->xMarkCount)
                )
        )
)
procedure(fnRPNSplitCharInt(tName)
        prog((tStr xInt xInt)
            if(stringp(tName) then
                    rexCompile("[0-9]+$")
                        tStr = rexReplace(tName "" 0)
                        rexCompile("^[A-Za-z]+")
                        tInt = rexReplace(tName "" 0)
                        when(tInt
                            xInt = atoi(tInt)
                        )
                        return(list(tStr xInt))
                else
                        return(nil)
            )
        )
)
procedure(fnRPNProcess(frmRPN lSelects)
        prog((tPinNumber tStep xStep tTextBlk lPinX lPinX lPNSplit tPNChar xPNNumber xNumber tNextPN lPNText 
                tLastPN rPinText)
                ;取Option 上的設定值
                tPinNumber = axlFormGetField(frmRPN "pinNumber")
                tStep = axlFormGetField(frmRPN "step")
                xStep = atoi(tStep)
                tTextBlk = axlFormGetField(frmRPN "textBlock")
                
                lPinX = mapcar(lambda((dObj) list(xCoord(dObj->xy) dObj)) lSelects)
                lPinY = mapcar(lambda((dObj) list(yCoord(dObj->xy) dObj)) lSelects)
                lPinX = sortcar(lPinX 'lessp)
                lPinY = sortcar(lPinY 'lessp)
                ;處裡Pin Number的英文字母和數字
                lPNSplit = fnRPNSplitCharInt(tPinNumber)
                unless(lPNSplit && fixp(cadr(lPNSplit))
                        return(nil)
                ) 
                tPNChar = car(lPNSplit)
                xPNNumber = cadr(lPNSplit)
                xNumber = xPNNumber
                for(xCount xPNNumber ((xPNNumber + length(lSelects)) - 1)
                        tNextPN = strcat(tPNChar sprintf(nil "%d" xNumber))
                        lPNText = cons(tNextPN lPNText)
                        xNumber = xNumber + xStep
                        tLastPN = strcat(tPNChar sprintf(nil "%d" xNumber))
                )
                lPNText = reverse(lPNText)
                axlFormSetField(frmRPN "pinNumber" tLastPN) 
                rPinText = make_axlTextOrientation(?textBlock tTextBlk ?rotation 0.0 ?mirrored nil ?justify "center")
                caseq(frmRPN->sDir
                        (hl || hr
                                when(frmRPN->sDir == 'hr
                                        lPNText = reverse(lPNText)
                                )
                                fnRPNRenameText(lPinX lPNText rPinText)
                        )
                        (vu || vd
                                when(frmRPN->sDir == 'vu
                                        lPNText = reverse(lPNText)
                                )
                                fnRPNRenameText(lPinY lPNText rPinText)
                        )
                )
        )
)
procedure(fnRPNRenameText(lList lPNText rPinText)
        let((lItem dPin lPinXY tPinName nPinRot tPinNum rPin)
                for(xIndex 0 (length(lList) - 1)
                        lItem = nth(xIndex lList)
                        when(lItem
                                dPin = cadr(lItem)
                                lPinXY = dPin->xy
                                tPinName = dPin->name
                                nPinRot = dPin->rotation
                                tPinNum = nth(xIndex lPNText)
                                unless(tPinNum == ""
                                        rPin = make_axlPinText(?number tPinNum ?offset (0:0) ?text rPinText)
                                        when(axlDBCreatePin(tPinName lPinXY rPin nPinRot) 
                                                axlDeleteObject(dPin)
                                          )
                                )
                        )
                )
        )
)
procedure(fnRPNSetFormField(frmRPN)
        axlFormColorize(frmRPN "ProgName" 'text 'red)
        axlFormSetField(frmRPN "ProgName" frmRPN->tProgName)
        
        axlFormColorize(frmRPN "pinNumber" 'background 'yellow)
        axlFormSetField(frmRPN "pinNumber" "1")
        axlFormSetField(frmRPN "step" 1)
        axlFormSetField(frmRPN "textBlock" 1)
        axlFormSetField(frmRPN "leftToRight" t)
)
procedure(fnRPNSetVariables(frmRPN)
        frmRPN->tProgName = " Rename Pin Number V1.00"
        
        frmRPN->sDir = 'hl                ;設定方向為Left to Right
                
        ;設定滑鼠右鍵選單相關變數
        frmRPN->xTransMark = nil
        frmRPN->xMarkCount = 0
        frmRPN->rPopupOrign = nil
        frmRPN->rPopupGray = nil
)
procedure(fnRPNStart(frmRPN)
        let((lVis (bDoFlag t) lEventMask rEventID lTempXY)
                lVis = axlVisibleGet()
                axlVisibleDesign(nil)
                axlVisibleLayer("PACKAGE GEOMETRY/PIN_NUMBER" t)
                axlVisibleLayer("PIN/TOP" t)
                axlVisibleLayer("PIN/BOTTOM" t)
                axlSetActiveLayer("PACKAGE GEOMETRY/PIN_NUMBER")
                axlVisibleUpdate(nil)
                fnRPNPopupInit()
                axlEventSetStartPopup('fnRPNPopupCallback)
                frmRPN->xTransMark = axlDBTransactionStart()
            lEventMask = list('PICK 'STARTDRAG 'STOPDRAG)
            axlClearSelSet()
                axlSetFindFilter(?enabled list("NOALL" "PINS") ?onButtons list("NOALL" "PINS"))
                
                while(bDoFlag
                        printf("M-Please select pins\n")
                        rEventID = axlEnterEvent(lEventMask nil nil)
                        caseq(rEventID->type
                                (PICK ;滑鼠按下左鍵一次
                                        axlDBTransactionMark(frmRPN->xTransMark)
                                        frmRPN->xMarkCount = add1(frmRPN->xMarkCount)
                                        if(axlAddSelectPoint(rEventID->xy) then
                                                fnRPNProcess(frmRPN axlGetSelSet())
                                        else
                                                ;恢復一次,因為沒有選到任一物件
                                                fnRPNPopupUndoTimes(frmRPN)
                                        )
                                )
                                (STARTDRAG ;使用滑鼠拉一個矩形框開始位置
                                        lTempXY = rEventID->xy
                                        axlAddSimpleRbandDynamics(lTempXY "box" ?origin lTempXY ?var_point (0:0))
                                )
                                (STOPDRAG ;使用滑鼠拉一個矩形框結束位置
                                        axlDBTransactionMark(frmRPN->xTransMark)
                                        frmRPN->xMarkCount = add1(frmRPN->xMarkCount)
                                        axlClearDynamics()
                                        if(axlAddSelectBox(list(lTempXY rEventID->xy)) then
                                                fnRPNProcess(frmRPN axlGetSelSet())
                                        else
                                                ;恢復一次,因為沒有選到任一物件
                                                fnRPNPopupUndoTimes(frmRPN)
                                        )
                                )
                                (DONE ;滑鼠按下右鍵,選擇done
                                        bDoFlag = nil
                                )
                                (CANCEL ;滑鼠按下右鍵,選擇cancel
                                        bDoFlag = nil
                                )
                        )
                        fnRPNPopupCheck(frmRPN)
                )
                axlEventSetStartPopup()
                axlVisibleSet(lVis)
        )
)

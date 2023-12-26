;
;FileName:        fRPN.il
;Load:                load("fRPN.il")
;Command:        rpn
;ʹ�÷���:
;        1.����rpn
;        2.�x��pins (�ɷN��ʽ:ֱ�ӻ����c�x���ǿ��x)
;        ���ϲ��E�Ϳ��Ը�׃pin�����Q
;
;        3.�������I�����x��:
;                Done => �Y����ʽ,
;                Oops => �֏���һ�εĄ���,
;                Cancel => ȡ����ʽ.
;        4.Option�����x�:
;                "Pin Number"         => Pin���Q��ֵ, ��1, 2, 3.... �� A1, A2, A3....
;                "Step"                         => �f����ֵ
;                "Text Blk"                 => ���ֵľ�̖
;                "Left To Right"        => ����������
;                "Right To Left"        => �������ҵ���
;                "Up To Down"        => �������ϵ���
;                "Down To Up"        => �������µ���
;
;��ʽ����ɫ:
;        1.ֻ����Packageģʽ����
;        2.�ɷN�x��:ֱ���c�x����x,
;        3.�������IOops�֏���һ�ι���,�]���κ��¼����Ի֏͕r,���x헾�׃�ɻ�ɫ�������x.
;        4.Դ���a����,׌�����˶����������Լ��ķ�ʽ������������,
;                ����������I.
;                ���������I�x�μ���������.
;                �����Լ��ك�����ʽ���a,�Լӿ��ʽ�����ٶ�.
;                ���ǌ�Ӣ��ӍϢ��������ӍϢ.
;                ������������,�Լ�����.
axlCmdRegister("rpn" 'fnRenamePinNumber ?cmdType "interactive" ?doneCmd 'fnRPNPopupDone ?cancelCmd 'fnRPNPopupCancel)
procedure(fnRenamePinNumber() ;����ʽ
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
        ;��Q����Oops��Popup׃�ɻ�ɫ��
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
        ;���xPopup
        frmRPN->rPopupOrign = axlUIPopupDefine(nil
                list(list("Done" 'fnRPNPopupDone)
                        list("Oops" 'fnRPNPopupOops)
                        list("Cancel" 'fnRPNPopupCancel)
                )
        )
        frmRPN->rPopupGray = axlUIPopupDefine(nil
                list(list("Done" 'fnRPNPopupDone)
                        ;list("Oops" 'fnRPNPopupOops)        ;�]���κ��x��r��׃�ɻ�ɫ
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
                ;ȡOption �ϵ��O��ֵ
                tPinNumber = axlFormGetField(frmRPN "pinNumber")
                tStep = axlFormGetField(frmRPN "step")
                xStep = atoi(tStep)
                tTextBlk = axlFormGetField(frmRPN "textBlock")
                
                lPinX = mapcar(lambda((dObj) list(xCoord(dObj->xy) dObj)) lSelects)
                lPinY = mapcar(lambda((dObj) list(yCoord(dObj->xy) dObj)) lSelects)
                lPinX = sortcar(lPinX 'lessp)
                lPinY = sortcar(lPinY 'lessp)
                ;̎�ePin Number��Ӣ����ĸ�͔���
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
        
        frmRPN->sDir = 'hl                ;�O�������Left to Right
                
        ;�O���������I�x�����P׃��
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
                                (PICK ;���������Iһ��
                                        axlDBTransactionMark(frmRPN->xTransMark)
                                        frmRPN->xMarkCount = add1(frmRPN->xMarkCount)
                                        if(axlAddSelectPoint(rEventID->xy) then
                                                fnRPNProcess(frmRPN axlGetSelSet())
                                        else
                                                ;�֏�һ��,���]���x����һ���
                                                fnRPNPopupUndoTimes(frmRPN)
                                        )
                                )
                                (STARTDRAG ;ʹ�û�����һ�����ο��_ʼλ��
                                        lTempXY = rEventID->xy
                                        axlAddSimpleRbandDynamics(lTempXY "box" ?origin lTempXY ?var_point (0:0))
                                )
                                (STOPDRAG ;ʹ�û�����һ�����ο�Y��λ��
                                        axlDBTransactionMark(frmRPN->xTransMark)
                                        frmRPN->xMarkCount = add1(frmRPN->xMarkCount)
                                        axlClearDynamics()
                                        if(axlAddSelectBox(list(lTempXY rEventID->xy)) then
                                                fnRPNProcess(frmRPN axlGetSelSet())
                                        else
                                                ;�֏�һ��,���]���x����һ���
                                                fnRPNPopupUndoTimes(frmRPN)
                                        )
                                )
                                (DONE ;���������I,�x��done
                                        bDoFlag = nil
                                )
                                (CANCEL ;���������I,�x��cancel
                                        bDoFlag = nil
                                )
                        )
                        fnRPNPopupCheck(frmRPN)
                )
                axlEventSetStartPopup()
                axlVisibleSet(lVis)
        )
)
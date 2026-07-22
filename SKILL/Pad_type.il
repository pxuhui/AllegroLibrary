axlCmdRegister("PadType" 'PadType)

/**============================================================================*
; Copyright(C) 2024-2025
; 文件名: Pad_type.il
; 创建人：digitzing
; 日期：2025年03月20日
; 版本号：
; 1.0   2025年03月20日   发布
***============================================================================*/

procedure(PadFormPro()
        ;PadFormFile= "PadType.form"
        Creat_PadForm()        
        
        ;PadForm = axlFormCreate((gensym) PadFormFile nil 'PadAction t nil)
        ;axlMiniStatusLoad( 'PadForm PadFormFile 'PadAction t )
        ;PadForm = axlMiniStatusLoad((gensym)  PadFormFile 'PadAction t )               


        if(        compareTime("Jan 01 00:00:00 2030" getCurrentTime()) > 0
        then
                print("PadType V1.1")
                PadForm = axlMiniStatusLoad((gensym)  PadFormFile 'PadAction t )
                ;PadForm = axlFormCreate((gensym) PadFormFile nil 'PadAction t nil)
        else
                PadForm = axlMiniStatusLoad((gensym)  PadFormFile 'PleaseContactTheAuthor t )
                print("Out of date,Please Contact The Author")
        )
        
        axlFormDisplay(PadForm)
        when(isFile(PadFormFile)
                deleteFile(PadFormFile)
        )
        
)

procedure(PadType()
        PadFormPro()
        axlFormSetField(PadForm "PropertyEnum" "DYN_THERMAL_CON_TYPE")        
        axlFormSetField(PadForm "Value" "FULL_CONTACT")
        axlFormSetField(PadForm "PadEnum" "FULL_CONTACT")
        axlFormSetField(PadForm "Add" t)
        Property_Fild = axlFormGetField(PadForm "PropertyEnum")
        Value_Fild = axlFormGetField(PadForm "Value")
        
        CompsSel = nil
        CompsSelTemp = nil
        axlSetFindFilter(
                ?enabled list("noall" "COMPONENTS" "SYMBOLS" "NETS" "PINS" )
                ?onButtons list("noall" "PINS")
        )        
        popupA = axlUIPopupDefine( nil
                (list
                        (list "Done" 'PadDone)
                        (list "Clear" 'PadClear)
                        (list "Cancel" 'PadCancel)
                ))
        axlUIPopupSet( popupA )


        while(axlSelect()
                ;axlHighlightObject(axlGetSelSet())
                CompsSelTemp = axlGetSelSet()
                CompsSel = unique(append(CompsSel CompsSelTemp))
                axlFormListDeleteAll(PadForm "ref_sym" )
                axlFormSetField( PadForm "ref_sym"        CompsSel~>name)
               
        );while
         
)


defun( PadDone ()
                Property_Fild = axlFormGetField(PadForm "PropertyEnum")
                Value_Fild = axlFormGetField(PadForm "Value")
                if(axlFormGetField(PadForm "add") == "1"
                then
                        axlDBAddProp(CompsSel, list(Property_Fild, Value_Fild))         
                else
                        axlDBDeleteProp(CompsSel, list(Property_Fild))                 
                )

                print("Done")
                CompsSel = nil        
                axlFormClose(PadForm)
                axlCancelEnteRFun()
                axlClearSelSet()        
)

defun( PadClear ()
        print("PadClear")
        CompsSel = nil
        axlFormListDeleteAll(PadForm "ref_sym" )
)

defun( PadCancel ()
        axlFormClose(PadForm)
        axlCancelEnterFun()
        axlClearSelSet()
)

;SelectSize = atoi(axlFormGetField(PadForm "PadEnum"))        

procedure(PadAction(PadForm)
case(PadForm->curField
                ("PadEnum"
                        axlFormSetField(PadForm "Value"        axlFormGetField(PadForm "PadEnum"))
                )
               
                ("PropertyEnum"        
                        if(axlFormGetField(PadForm "PropertyEnum") == "DYN_THERMAL_CON_TYPE"        then
                                axlFormSetField(PadForm "Value" axlFormGetField(PadForm "PadEnum")))                        
                        if(axlFormGetField(PadForm "PropertyEnum") == "DYN_CLEARANCE_OVERSIZE"        then
                                axlFormSetField(PadForm "Value" "5"))
                        if(axlFormGetField(PadForm "PropertyEnum") == "DYN_FIXED_THERM_WIDTH"        then
                                axlFormSetField(PadForm "Value" "10"))
                        if(axlFormGetField(PadForm "PropertyEnum") == "FIXED"        
                                then
                                axlFormSetField(PadForm "Value" "TRUE")
                                axlSetFindFilter(?enabled list("noall" "COMPONENTS" "SYMBOLS" "NETS" "PINS" )
                                ?onButtons list("noall" "SYMBOLS"))
                                else
                                axlSetFindFilter(?enabled list("noall" "COMPONENTS" "SYMBOLS" "NETS" "PINS" )
                                ?onButtons list("noall" "PINS"))
                                )        
                )                                       
                        
               
               
                ("Do"
                        print("Done")
                        Property_Fild = axlFormGetField(PadForm "PropertyEnum")
                        Value_Fild = axlFormGetField(PadForm "Value")
                        if(axlFormGetField(PadForm "add") == "1"
                        then
                                axlDBAddProp(CompsSel, list(Property_Fild, Value_Fild))         
                        else
                                axlDBDeleteProp(CompsSel, list(Property_Fild))                 
                        )
                        ;CompsSel = nil        
                        ;axlFormClose(PadForm)
                        ;axlCancelEnterFun()
                        ;axlClearSelSet()        
                )               

                ("Clear"
                        print("PadClear")
                        CompsSel = nil
                        axlFormListDeleteAll(PadForm "ref_sym" )
                )
               
                ("Exit"
                        axlFormClose(PadForm)
                        axlCancelEnterFun()
                        axlClearSelSet()
                        ;when(isFile(padsCRFile)
                        ;deleteFile(PadSCRFile)                        
                        ;)                                
                )        
        )
)


procedure(Creat_PadForm()               
;PadFormFile= "PadType.form"
PadFormFile = axlTempFile()
PadForm = outfile(PadFormFile "w")

fprintf(PadForm "FILE_TYPE=FORM_DEFN VERSION=2\n")
fprintf(PadForm "FORM TOOLWINDOW\n")
fprintf(PadForm "\n")
fprintf(PadForm "FIXED \n")
fprintf(PadForm "PORT 28 5\n")
fprintf(PadForm "HEADER \"Pad\"\n")
fprintf(PadForm "TILE\n")
fprintf(PadForm "\n")
fprintf(PadForm "TEXT \"PINS:\"\n")
fprintf(PadForm "FLOC 2 1\n")
fprintf(PadForm "ENDTEXT\n")
fprintf(PadForm "\n")
fprintf(PadForm "FIELD ref_sym\n")
fprintf(PadForm "FLOC 2 3\n")
fprintf(PadForm "LIST \"\" 10 11\n")
fprintf(PadForm "OPTIONS multiselect\n")
fprintf(PadForm "ENDFIELD\n")
fprintf(PadForm "\n")
fprintf(PadForm "FIELD Add\n")
fprintf(PadForm "FLOC 13 1\n")
fprintf(PadForm "CHECKLIST \"Add\" \"rg\"\n")
fprintf(PadForm "ENDFIELD\n")
fprintf(PadForm "\n")
fprintf(PadForm "FIELD Delete\n")
fprintf(PadForm "FLOC 20 1\n")
fprintf(PadForm "CHECKLIST \"Delete\" \"rg\"\n")
fprintf(PadForm "ENDFIELD\n")
fprintf(PadForm "\n")
fprintf(PadForm "TEXT \"Property:\"\n")
fprintf(PadForm "FLOC 14 3\n")
fprintf(PadForm "ENDTEXT\n")
fprintf(PadForm "\n")

;fprintf(PadForm "FIELD Property\n")
;fprintf(PadForm "FLOC 14 5\n")
;fprintf(PadForm "STRFILLIN 12 32\n")
;fprintf(PadForm "ENDFIELD\n")
;fprintf(PadForm "\n")

fprintf(PadForm "POPUP <PropertyEnumNames> \"CON_TYPE\" \"DYN_THERMAL_CON_TYPE\",\"SPACE\"\"DYN_CLEARANCE_OVERSIZE\",\"WIDTH\"\"DYN_FIXED_THERM_WIDTH\",\"FIXED\"\"FIXED\",\"ID5\"\"NONE\".\n")
fprintf(PadForm "FIELD PropertyEnum\n")
fprintf(PadForm "FLOC 14 5\n")
fprintf(PadForm "ENUMSET 11\n")
fprintf(PadForm "POP \"PropertyEnumNames\"\n")
fprintf(PadForm "ENDFIELD\n")
fprintf(PadForm "\n")

fprintf(PadForm "TEXT \"Value:(default)\"\n")
fprintf(PadForm "FLOC 14 7\n")
fprintf(PadForm "ENDTEXT\n")
fprintf(PadForm "\n")
fprintf(PadForm "FIELD Value\n")
fprintf(PadForm "FLOC 14 9\n")
fprintf(PadForm "STRFILLIN 12 32\n")
fprintf(PadForm "ENDFIELD\n")
fprintf(PadForm "\n")
fprintf(PadForm "TEXT \"Connect type\"\n")
fprintf(PadForm "FLOC 14 11\n")
fprintf(PadForm "ENDTEXT\n")
fprintf(PadForm "\n")

fprintf(PadForm "POPUP <PadEnumNames> \"ORTHOGONAL\" \"ORTHOGONAL\",\"DIAGONAL\"\"DIAGONAL\",\"FULL CONTACT\"\"FULL_CONTACT\",\"8 WAY\"\"8_WAY\",\"NONE\"\"NONE\",\"TRUE\"\"TRUE\".\n")
fprintf(PadForm "FIELD PadEnum\n")
fprintf(PadForm "FLOC 14 13\n")
fprintf(PadForm "ENUMSET 11\n")
fprintf(PadForm "POP \"PadEnumNames\"\n")
fprintf(PadForm "ENDFIELD\n")
fprintf(PadForm "\n")

fprintf(PadForm "TEXT \"Just do it:\"\n")
fprintf(PadForm "FLOC 14 15\n")
fprintf(PadForm "ENDTEXT\n")
fprintf(PadForm "\n")
fprintf(PadForm "FIELD Do\n")
fprintf(PadForm "FLOC 14 17\n")
fprintf(PadForm "MENUBUTTON \"Do\" 6 3\n")
fprintf(PadForm "ENDFIELD\n")
fprintf(PadForm "\n")
fprintf(PadForm "FIELD Clear\n")
fprintf(PadForm "FLOC 22 17\n")
fprintf(PadForm "MENUBUTTON \"Clear\" 6 3\n")
fprintf(PadForm "ENDFIELD\n")
fprintf(PadForm "\n")
fprintf(PadForm "FIELD Exit\n")
fprintf(PadForm "FLOC 14 20\n")
fprintf(PadForm "MENUBUTTON \"Exit\" 14 3\n")
fprintf(PadForm "ENDFIELD\n")
fprintf(PadForm "\n")



fprintf(PadForm "ENDTILE\n")
fprintf(PadForm "ENDFORM\n")
close(PadForm)
)
; --------------------------------------------------
; Allegro version: 16.6
; Written by: Lianora
; date: 2021.09.11
; --------------------------------------------------
; 功能说明：单击选择两个差分信号过孔，生成过孔反焊盘
;           有助于减小差分阻抗在过孔处的突变程度
; --------------------------------------------------

axlCmdRegister(
	"DVAP"
	'lnDiffViaAntiPad
	?cmdType "interactive"
	?doneCmd 'lnDone
	?cancelCmd 'lnCancel
)

; --------------------------------------------------
; 主程序入口函数
; --------------------------------------------------
procedure(lnDiffViaAntiPad(@optional (expandValue_via 0))
	let(()
	; 设置 find 栏参数，仅勾选 "vias"
		axlSetFindFilter(
			?enabled list("noall" "vias")
			?onButtons list("noall" "vias")
		)
	; 设置右键弹出功能项
		ln_popup = axlUIPopupDefine(nil (list
						(list "Done" 'lnDone)
						(list "Oops" 'lnOops)
						(list "Cancel" 'lnCancel))
					)
		axlUIPopupSet(ln_popup)
	
	; 创建一个表单，在 options 栏中显示需要设置的参数
		lnCreateParamForm()
		
	; 定义一个循环标记
		notdone = t
	
	;获取 class/subclass 信息
		t_activelayer = axlGetActiveLayer()
	
		ln_mark = axlDBTransactionStart()
		
		while(notdone
			
			l_via1 = nil
			l_via2 = nil
	; 等待获取第一个 via	
			printf("Please select the first via...\n")
			l_via1 = axlGetSelSet(axlSingleSelectPoint())
	; 如果已选取第一个 via，则等待获取第二个 via ; 否则继续等待获取第一个 via		
			if(l_via1 then
				printf("Please select the second via...\n")
				l_via2 = axlGetSelSet(axlSingleSelectPoint())
			)
	; 如果获取了两个 via，则开始创建过孔反焊盘		
			if(l_via2 then
				axlDBTransactionMark(ln_mark)
				pad1 = axlDBGetPad(car(l_via1) "ETCH/TOP" "REGULAR")
				pad2 = axlDBGetPad(car(l_via2) "ETCH/TOP" "REGULAR")
	; 计算出外扩相应尺寸后的线宽			
				cline_width = caadr(pad1->bBox) - caar(pad1->bBox) + expandValue_via
				
				printf("cline_width is %-.2f \n" cline_width)
	; 在TOP层创建一根线段			
				l_cline = axlDBCreateLine(
								list(car(l_via1)->xy car(l_via2)->xy)
								cline_width
								"ANTI ETCH/TOP"
								nil
								nil
							)
	; 通过 cline2shape 将 cline 转换成相应层面的 shape		
				if(l_cline then
					l_poly = axlPolyFromDB(caar(l_cline) ?endCapType "ROUND")
					l_shape = axlDBCreateShape(car(l_poly) t t_activelayer)
	; 如果所在层面是 ROUTE KEEPOUT ， 需给 shpae 增加如下两个属性，可以消除走线和过孔的DRC
	; 并保留避让铜皮属性
					if(car(parseString(t_activelayer "/")) == "ROUTE KEEPOUT" then
						axlDBAddProp(car(l_shape) list("vias_allowed" t))
						axlDBAddProp(car(l_shape) list("routes_allowed" t))
					)
	; 删除辅助 cline
					axlDeleteObject(caar(l_cline))
				)
			)	
		)
	)
)

; --------------------------------------------------
; 创建参数设置 form 函数
; --------------------------------------------------
procedure(lnCreateParamForm()
	let((FileName FilePort)
		FileName = "create_parm_form.form"
		FilePort = outfile(FileName "w")
		
		fprintf(FilePort "FILE_TYPE=FORM_DEFN VERSION=2\n")
		fprintf(FilePort "FORM\n")
		fprintf(FilePort "FIXED\n")
		fprintf(FilePort "PORT 24 50\n")
		fprintf(FilePort "HEADER \"Diff Via Anti Pad\"\n\n")
		
		fprintf(FilePort "POPUP <class>\"class\"\n")
		fprintf(FilePort "POPUP <subclass>\"subclass\"\n")
		
		fprintf(FilePort "TILE\n\n")
		
		fprintf(FilePort "TEXT \"Active Class and Subclass:\"\n\n")
		fprintf(FilePort "TLOC 1 1\n")
		fprintf(FilePort "ENDTEXT\n\n")
	; class enumeration drop-dowm box	
		fprintf(FilePort "FIELD class\n")
		fprintf(FilePort "FLOC 5 4\n")
		fprintf(FilePort "ENUMSET 19\n")
		fprintf(FilePort "OPTIONS prettyprint\n")		
		fprintf(FilePort "POP \"class\"\n")
		fprintf(FilePort "ENDFIELD\n\n")
	; subclass color check box	
		fprintf(FilePort "FIELD subcolor\n")
		fprintf(FilePort "FLOC 2 7\n")
		fprintf(FilePort "COLOR 2 1\n")
		fprintf(FilePort "OPTIONS colcrchooser\n")
		fprintf(FilePort "ENDFIELD\n\n")
	; subclass enumeration drop-dowm box	
		fprintf(FilePort "FIELD subclass\n")
		fprintf(FilePort "FLOC 5 7\n")
		fprintf(FilePort "ENUMSET 19\n")
		fprintf(FilePort "OPTIONS prettyprint ownerdrawn\n")
		fprintf(FilePort "POP \"subclass\"\n")
		fprintf(FilePort "ENDFIELD\n\n")
	; enter the expand size of via
		fprintf(FilePort "TEXT \"Expand size of vias (mils):\"\n\n")
		fprintf(FilePort "TLOC 1 11\n")
		fprintf(FilePort "ENDTEXT\n\n")
		
		fprintf(FilePort "FIELD expandValue_via\n\n")
		fprintf(FilePort "FLOC 19 11\n\n")
		fprintf(FilePort "REALFILLIN 6 6\n\n")
		fprintf(FilePort "MIN 0\n\n")
		fprintf(FilePort "ENDFIELD\n\n")
		
		fprintf(FilePort "ENDTILE\n\n")
		fprintf(FilePort "ENDFORM\n")
		
		close(FilePort)
		
		createparmform = axlMiniStatusLoad(gensym() FileName 'lnCreateParmFormCB nil "NONE")
	)
)
; --------------------------------------------------
; 参数设置 form 回调函数
; --------------------------------------------------
procedure(lnCreateParmFormCB(form)
	case(form->curField
		("class"
			t_activelayer = axlGetActiveLayer()
		)
		("subclass"
			t_activelayer = axlGetActiveLayer()
		)
		("subcolor"
			if(axlFormGetField(form "subcolor") then
				axlVisibleLayer(axlGetActiveLayer() t)
			else
				axlVisibleLayer(axlGetActiveLayer() t)
			)
		)
		("expandValue_via"
			expandValue_via= axlFormGetField(form "expandValue_via")
			printf("expandValue_via is %-.2f" expandValue_via)	
				
		)
	)
)

; --------------------------------------------------
; 结束命令回调函数
; --------------------------------------------------
procedure(lnDone()
	let(()
		axlDBTransactionCommit(ln_mark)
		notdone = nil
		axlCancelEnterFun()
	)
)

; --------------------------------------------------
; 回撤命令回调函数
; --------------------------------------------------
procedure(lnOops()
	let(()
		axlDBTransactionOops(ln_mark)
		axlCancelEnterFun()
	)
)

; --------------------------------------------------
; 取消命令回调函数
; --------------------------------------------------
procedure(lnCancel()
	let(()
		axlDBTransactionCommit(ln_mark)
		notdone = nil
		axlCancelEnterFun()
	)
)

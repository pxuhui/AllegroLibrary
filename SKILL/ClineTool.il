axlCmdRegister("ce" 'ClineTools ?cmdType "interactive" ?doneCmd "done = t axlFinishEnterFun() axlDBTransactionCommit(startMark)")
defun( ClineTools ()
	prog(()
		if(!axlOKToProceed(t) || length(axlUIGetUserData()->??) == 6 then
			axlShell("done")
		) 
		if(boundp('SkillRun) && tablep(SkillRun) then 
			if(SkillRun["Run"]==t then 
				printf("T - Cline Tools: Skill is running.\n")
				; return(nil)																																				;窗体已显示，返回空值
			)																																	
		else
			SkillRun = makeTable("Table" nil)
		);end if
		current_unit = car(axlDBGetDesignUnits())
		SkillRun["Run"]=t
		if(current_unit!="inches"   then
			done=nil
			ClineEquidistant()
		else
    	printf("E - Cline Tools: Current design units is not \"inches\", Skill will exit.\n")
			) ;end if
		)
	)
defun( ClineEquidistant ()
	let( ()
		axlClearSelSet()
		axlSetFindFilter(?enabled list("noall" "CLINESEGS") ?onButtons list("noall" "CLINESEGS"))
		setpopup = axlUIPopupDefine(nil list(	list( "Done" 		"done = t axlFinishEnterFun() axlDBTransactionCommit(startMark)")     
            															list( "Oops" 		"axlDBTransactionOops(startMark)")  
            															list( "Cancel" 	"done = t axlFinishEnterFun() 	axlDBTransactionRollback(startMark)")))
		axlUIPopupSet(setpopup)
		startMark = axlDBTransactionStart()
		while(null(done) 
			seg_list=nil
			airgap=nil
			lastgap=0
			tol=axlMKSConvert(0.01 "mils" car(axlDBGetDesignUnits()))
			seg_list = axlGetSelSet(axlAddSelectBox())
			axlClearSelSet()
			axlDBTransactionMark(startMark)
			when(seg_list 
				seg_list=remove(nil seg_list)
				if(length(seg_list)>2 then
					slope_list=nil
					foreach(seg_db seg_list
						SegStartEnd=seg_db->startEnd
						slope=GetIntSlope(SegStartEnd)
						slope_list=append1(slope_list slope)
					)
					slope_list=unique(slope_list)
					if(slope_list && length(slope_list)>1  then
						printf("E - Cline Tools: Cline should be the same rotation. Please Reselect.")
					else
						foreach(seg1_db seg_list
							foreach(seg2_db seg_list
								Seg1StartEnd=seg1_db->startEnd
								Seg2StartEnd=seg2_db->startEnd
								airgap=PointToLine(car(Seg1StartEnd) Seg2StartEnd)
								when(airgap
									if(airgap>lastgap then
										big=airgap
										obj1=seg1_db
										obj2=seg2_db
									else
										big=lastgap
									)
									lastgap=big
								)
							)
						)
						base_obj=obj1
						avg_dist=big/(length(seg_list)-1)
						base_line=base_obj->startEnd
						seg_list=remove(obj1 seg_list);移出基准线
						seg_list=remove(obj2 seg_list);移出基准线
						i=0
						while(seg_list
							i=i+1
							cur_dist=i*avg_dist
							lastgap=big
							foreach(seg_db seg_list
								SegStartEnd=seg_db->startEnd
								airgap=PointToLine(car(SegStartEnd) base_line)
								if(airgap>lastgap then
										small=lastgap
								else
										small=airgap
										objModf=seg_db
								)
								lastgap=small
							)
							adjgap=abs(cur_dist-small)
							new_list=nil
							objnet=objModf->net->name
							objwidth=objModf->width 
							objlayer=objModf->layer
							objstartEnd=objModf->startEnd
							foreach(point objstartEnd
								if(mod(car(slope_list) 2)==0 then
									chgx_list=list(car(point)-adjgap car(point) car(point)+adjgap )
									chgy_list=list(cadr(point)-adjgap cadr(point) cadr(point)+adjgap)
								else
									tmpadjgap=adjgap*sqrt(2) 
									chgx_list=list(car(point)-tmpadjgap car(point) car(point)+tmpadjgap)
									chgy_list=list(cadr(point)-tmpadjgap cadr(point) cadr(point)+tmpadjgap)
								)
								box=list(axlMXYSub(point objwidth/2:objwidth/2) axlMXYAdd(point objwidth/2:objwidth/2))
								temp_list = remove(objModf axlGetSelSet(axlSingleSelectBox(box)))
								axlClearSelSet()
								if(temp_list then
									temp=car(temp_list)
									axlDehighlightObject(temp)
									tempStartEnd=temp->startEnd
									foreach(dbp tempStartEnd
										if(!axlIsPointInsideBox(dbp box) then
											FlagP=dbp
											)
									)
									temp_slope=GetIntSlope(tempStartEnd)
									foreach(dbp tempStartEnd
										if(axlIsPointInsideBox(dbp box) then
											foreach(chgx chgx_list
												foreach(chgy chgy_list
													chgp=list(chgx chgy)
													new_slope=GetIntSlope(list(dbp chgp))	;移动后的点和基准点的组成的直线的斜率
													base_dis=PointToLine(chgp base_line)	;移动后的点到基准线的距离
													if(abs(base_dis-cur_dist)<tol && new_slope==temp_slope then
														NewPoint=prog(nil
															if(mod(car(slope_list) 2)==0 then
																temp_dis=abs(caar(tempStartEnd)-caadr(tempStartEnd))-adjgap
																if(temp_dis<0 then
																	case(car(slope_list)
																		(2 	
																			dx=2*(chgx-car(FlagP));OK
																			return(list(chgx-dx chgy))
																		)
																		(4 	
																			dy=2*(chgy-cadr(FlagP));OK
																			return(list(chgx chgy-dy))
																		)
																	)
																else
																	return(list(chgx chgy))
																)
															else
																temp_dis=axlDistance(car(tempStartEnd) cadr(tempStartEnd))-adjgap*sqrt(2)
																if(temp_dis<0 then
																	delta=tmpadjgap-axlDistance(FlagP dbp)
																	dx_list=list(chgx+delta chgx-delta)
																	dy_list=list(chgy+delta chgy-delta)
																	objmid_point=axlMidPointLine(objstartEnd)
																	foreach(dx dx_list
																		foreach(dy dy_list
																			deltaP=list(dx dy)
																			temp_dis=axlDistance(list(chgx chgy) objmid_point)	;移动后的点到线段中点的距离
																			delta_dis=axlDistance(deltaP objmid_point)	;线段一半的长度
																			new_slope=GetIntSlope(list(list(chgx chgy) deltaP))	;移动后的点和基准点的组成的直线的斜率
																			if(new_slope==car(slope_list) && delta_dis<temp_dis then
																				return(list(dx dy))
																			)
																		)
																	)
																else
																	return(list(chgx chgy))
																)
															)
														)
														new_list=append1(new_list NewPoint)
													)
												)
											)
										else
											new_list=append1(new_list dbp)
										)
									)
									if(abs(adjgap)>tol then
										axlDeleteObject(temp)
									)
								else
									objmid_point=axlMidPointLine(objstartEnd)
									foreach(chgx chgx_list
										foreach(chgy chgy_list
											chgp=list(chgx chgy)
											temp_dis=axlDistance(chgp objmid_point)	;移动后的点到线段中点的距离
											half_dis=axlDistance(car(objstartEnd) objmid_point)	;线段一半的长度
											base_dis=PointToLine(chgp base_line)			;移动后的点到基准线的距离
											if(abs(base_dis-cur_dist)<tol && temp_dis<half_dis then
												if(point==car(objstartEnd) then
													new_list=append1(new_list point)				;起点的点加在列表最前面
													new_list=append1(new_list chgp)
												else
													new_list=append1(new_list chgp)
													new_list=append1(new_list point)				;终点的点加在列表最后面
												)
											)
										)
									) 									
								)
							)
							if(abs(adjgap)>tol then
								axlDeleteObject(objModf)
								for(i 0 length(new_list)-2
									start=nth(i new_list)
									end=nth(i+1 new_list)
									axlDBCreateLine(list(start end) objwidth objlayer objnet)
								)
							)
							seg_list=remove(objModf seg_list)
						); endif
					)
				else
					printf("E - Cline Tools: Selected clines should be more than 2,current is 2, Please Reselect.")
				)
			);;;;;;
			axlDBRefreshId(nil)
		); end while
		axlDBTransactionCommit(startMark)
	)
); let and defun
defun( GetIntSlope (StartEnd);/布线的斜率为3，\布线的斜率为1，水平布线的斜率为2，竖直布线的斜率为4。
	prog(()
		slope=axlLineSlope(StartEnd)
		if(slope then
			slope=round(slope)+2
		else
			slope=4
		);end if
		return(slope)
	); end prog
); end defun

defun( PointToLine (point StartEnd);PointToLine1(0:0 list(1:0 2:-1))
	prog(()
		if(!axlIsPointOnLine(point StartEnd) then
			p_s=axlDistance(point car(StartEnd))
			p_e=axlDistance(point cadr(StartEnd))
			s_e=axlDistance(car(StartEnd) cadr(StartEnd))
			St=sqrt((p_s+p_e+s_e)*(p_s+p_e-s_e)*(p_s-p_e+s_e)*(-p_s+p_e+s_e))/4
			dis=2*St/s_e
			return(dis)
		else
			return(nil)
		);end if
	)
); end prog and defun

defun( ClinePOP_unDo ()
	let( ()
  axlDBTransactionOops(startMark) 
  axlClearSelSet()
	)
); end let defun

defun( ClinePOP_Cancel ()
	let( ()
  axlDBTransactionRollback(startMark)
  done = t
  axlClearSelSet()
  axlCancelEnterFun()
  SkillRun["Run"]=nil
 	)
); end let defun

defun( ClinePOP_Done ()
let( ()
  axlDBTransactionCommit(startMark)
  done = t
  axlClearSelSet()
  axlFinishEnterFun()
  SkillRun["Run"]=nil
  )
); end let and defun

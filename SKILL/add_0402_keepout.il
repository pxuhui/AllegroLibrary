axlCmdRegister("adk" 'add_0402_keepout)
defun( add_0402_keepout ()
	axlClearSelSet()
	axlSetFindFilter( ?enabled '("NOALL" "PINS")
						?onButtons '("PINS")
					)
	while(axlSelect(?prompt "Please select 0402")
		pin1 = car(axlGetSelSet())
		connect_pin= axlDBGetConnect(pin1 t)		
		ly= car(connect_pin)->layer			
		lay= cadr(parseString(ly "//"))
		degree= pin1->rotation
		box= pin1->bBox
		fx= xCoord(car(box))
		fy= yCoord(car(box))
		ex= xCoord(cadr(box))
		ey= yCoord(cadr(box))
		case( lay
			("TOP"
				case( degree
					(0.0
						create_180_shape_right(ex ey lay)		
						create_180_shape_left_up(ex-20 ey lay)	
						create_180_shape_left_down(fx fy lay) 
						
					);
					(90.0
						create_270_shape_up(ex ey lay)		
						create_270_shape_left_down(fx fy lay)	
						create_270_shape_right_down(fx+20 fy lay) 
					);
					(180.0
						create_0_shape_right_up(ex ey lay)		
						create_0_shape_right_down(ex ey-20 lay)	
						create_0_shape_left(fx fy lay) 
					);180.0
					(270.0
						create_90_shape_left_up(ex-20 ey lay)		
						create_90_shape_right_up(ex ey lay)	
						create_90_shape_down(fx fy lay) 
					);270.0
				);case
			);TOP
			("BOTTOM"
				case( degree
					(0.0
						create_0_shape_right_up(ex ey lay)		
						create_0_shape_right_down(ex ey-20 lay)	
						create_0_shape_left(fx fy lay) 
					);
					(90.0
						create_90_shape_left_up(ex-20 ey lay)		
						create_90_shape_right_up(ex ey lay)	
						create_90_shape_down(fx fy lay) 
					);
					(180.0
						create_180_shape_right(ex ey lay)		
						create_180_shape_left_up(ex-20 ey lay)	
						create_180_shape_left_down(fx fy lay) 
					);180.0
					(270.0
						create_270_shape_up(ex ey lay)		
						create_270_shape_left_down(fx fy lay)	
						create_270_shape_right_down(fx+20 fy lay) 
					);270.0
				);case
			);BOTTOM
		);case
		
	);while
);defun
defun( create_270_shape_up (loc_x loc_y lay)
	path= axlPathStart(list(loc_x-20-6:loc_y+6 loc_x+6:loc_y+6))
	axlPathLine(path,0.0, loc_x+6:loc_y-5)
	axlPathLine(path,0.0, loc_x-20-6:loc_y-5)
	axlPathLine(path,0.0, loc_x-20-6:loc_y+6)
	axlDBCreateShape(path t strcat("ROUTE KEEPOUT/" lay))
);
defun( create_270_shape_right_down (loc_x loc_y lay)
	path= axlPathStart(list(loc_x-5:loc_y+5 loc_x+6:loc_y+5))
	axlPathLine(path,0.0, loc_x+6:loc_y-6)
	axlPathLine(path,0.0, loc_x-5:loc_y-6)
	axlPathLine(path,0.0, loc_x-5:loc_y+5)
	axlDBCreateShape(path t strcat("ROUTE KEEPOUT/" lay))
);defun
defun( create_270_shape_left_down (loc_x loc_y lay)
	path= axlPathStart(list(loc_x-6:loc_y+5 loc_x+5:loc_y+5))
	axlPathLine(path,0.0, loc_x+5:loc_y-6)
	axlPathLine(path,0.0, loc_x-6:loc_y-6)
	axlPathLine(path,0.0, loc_x-6:loc_y+5)
	axlDBCreateShape(path t strcat("ROUTE KEEPOUT/" lay))
);defun
defun( create_180_shape_right (loc_x loc_y lay)
	path= axlPathStart(list(loc_x-5:loc_y+6 loc_x+6:loc_y+6))
	axlPathLine(path,0.0, loc_x+6:loc_y-20-6)
	axlPathLine(path,0.0, loc_x-5:loc_y-20-6)
	axlPathLine(path,0.0, loc_x-5:loc_y+6)
	axlDBCreateShape(path t strcat("ROUTE KEEPOUT/" lay))
);defun
defun( create_180_shape_left_up (loc_x loc_y lay)
	path= axlPathStart(list(loc_x-6:loc_y+6 loc_x+5:loc_y+6))
	axlPathLine(path,0.0, loc_x+5:loc_y-5)
	axlPathLine(path,0.0, loc_x-6:loc_y-5)
	axlPathLine(path,0.0, loc_x-6:loc_y+6)
	axlDBCreateShape(path t strcat("ROUTE KEEPOUT/" lay))
);defun
defun( create_180_shape_left_down (loc_x loc_y lay)
	path= axlPathStart(list(loc_x-6:loc_y+5 loc_x+5:loc_y+5))
	axlPathLine(path,0.0, loc_x+5:loc_y-6)
	axlPathLine(path,0.0, loc_x-6:loc_y-6)
	axlPathLine(path,0.0, loc_x-6:loc_y+5)
	axlDBCreateShape(path t strcat("ROUTE KEEPOUT/" lay))
);defun
defun( create_90_shape_left_up (loc_x loc_y lay)
	path= axlPathStart(list(loc_x-6:loc_y+6 loc_x+5:loc_y+6))
	axlPathLine(path,0.0, loc_x+5:loc_y-5)
	axlPathLine(path,0.0, loc_x-6:loc_y-5)
	axlPathLine(path,0.0, loc_x-6:loc_y+6)
	axlDBCreateShape(path t strcat("ROUTE KEEPOUT/" lay))
);defun
defun( create_90_shape_right_up (loc_x loc_y lay)
	path= axlPathStart(list(loc_x-5:loc_y+6 loc_x+6:loc_y+6))
	axlPathLine(path,0.0, loc_x+6:loc_y-5)
	axlPathLine(path,0.0, loc_x-5:loc_y-5)
	axlPathLine(path,0.0, loc_x-5:loc_y+6)
	axlDBCreateShape(path t strcat("ROUTE KEEPOUT/" lay))
);defun
defun( create_90_shape_down (loc_x loc_y lay)
	path= axlPathStart(list(loc_x-6:loc_y+5 loc_x+20+6:loc_y+5))
	axlPathLine(path,0.0, loc_x+20+6:loc_y-6)
	axlPathLine(path,0.0, loc_x-6:loc_y-6)
	axlPathLine(path,0.0, loc_x-6:loc_y+5)
	axlDBCreateShape(path t strcat("ROUTE KEEPOUT/" lay))
);defun
defun( create_0_shape_right_up (loc_x loc_y lay)
	path= axlPathStart(list(loc_x-5:loc_y+6 loc_x+6:loc_y+6))
	axlPathLine(path,0.0, loc_x+6:loc_y-5)
	axlPathLine(path,0.0, loc_x-5:loc_y-5)
	axlPathLine(path,0.0, loc_x-5:loc_y+6)
	axlDBCreateShape(path t strcat("ROUTE KEEPOUT/" lay))
);defun
defun( create_0_shape_right_down (loc_x loc_y lay)
	
	path= axlPathStart(list(loc_x-5:loc_y+5 loc_x+6:loc_y+5)) 
	axlPathLine(path,0.0, loc_x+6:loc_y-6)			
	axlPathLine(path,0.0, loc_x-5:loc_y-6)			
	axlPathLine(path,0.0, loc_x-5:loc_y+5)			
	axlDBCreateShape(path t strcat("ROUTE KEEPOUT/" lay))
);defun
defun( create_0_shape_left (loc_x loc_y lay)
	path= axlPathStart(list(loc_x-6:loc_y+20+6 loc_x+5:loc_y+20+6)) 
	axlPathLine(path,0.0, loc_x+5:loc_y-6)			
	axlPathLine(path,0.0, loc_x-6:loc_y-6)			
	axlPathLine(path,0.0, loc_x-6:loc_y+20+6)			
	axlDBCreateShape(path t strcat("ROUTE KEEPOUT/" lay))
);defun
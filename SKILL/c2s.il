axlCmdRegister("ClineToShape" 'ClineToShape)
axlSetAlias("c2s" "ClineToShape")
procedure( ClineToShape(@optional (cline nil))
prog((poly clayer cnet cparent mark)
   unless(cline
      axlSetFindFilter(?enabled '("all") ?onButtons '("noall" "clines"))
      cline = car(axlGetSelSet(axlSingleSelectPoint()))
   )
   poly = car(axlPolyOperation(axlPolyFromDB(cline ?endCapType 'OCTAGON) nil 'OR))
   clayer = cline->layer
   cnet = cline->net
   cparent = cline->parent
   mark = axlDBTransactionStart()
   axlDeleteObject(cline)
   if(axlDBCreateShape(poly t clayer cnet cparent) then
      axlDBTransactionCommit(mark)
   else
      axlDBTransactionOops(mark)
   )
))
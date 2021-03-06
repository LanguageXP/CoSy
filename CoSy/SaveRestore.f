| Essential recursive Save and Restore list fns .
| Begun by the pool @ Dyalog & APL2000 Naples APL conference 200411
| when Ray Cannon had a spare room and everyone else was at sessions . 
| Author: Bob Armstrong / www.CoSy.com
| Reva's license terms also apply to this file.
| Sat.May,20070526 

cr ." | SaveRestore begin | " type cr 

| \/ SAVE LIST  \/ ========================================== \/

 variable Ilst variable Ilst# 
 
: Ilst! ( a -- ) Ilst @ Ilst# @>+! ( lengthen Ilst first ) 
   Ilst# @ Ilst @ cell+ !  ic! ;
   | increment the pointer and store the address 
    
: Ilst? Ilst @ swap ['] = _f? ; 

: IlstInit intVecInit refs+> Ilst ! 1 Ilst cell+ ! ( length to 1 ) Ilst# off ;  

 defer (storelst)
 
: storelst ( lst -- clst cells )    | convert allocated list to linear form
| NB : because the buffer is not a "CoSy" object , it is not reference counted
|  and must be freed after use . 
   2 M* allocBuf 	100 K* IlstInit
   (storelst)
   buf bpos @ resize to buf  buf bpos @ Ilst @ refs- ;

 : ((storelst)) ( lst -- ) 
   >aux> Ilst? | search saved addresses , return index or  _n
   	dup _n =if
		( NEW ) drop aux@ Ilst!  
 		  aux@ @ if
		  
		 ( SIMPLE ) | store in buffer  
		   aux@ bufcur aux> 
		   vsize >r> move r> bpos +!  ;then
		   
		 ( LIST )  aux@ bufcur Head# cells >r>
		    move r> bufinc | store head
		   aux@ i# 0 ?do aux@ i ic@ ((storelst)) loop auxdrop ;then
		   			| /\ iterate thru items
					
	    ( ALREADY STORED ) negate bufcur ! cell bufinc auxdrop ;
 
' ((storelst)) is  (storelst)

: storelst^  storelst --aab str swap free ;
	
| ======== |

: savelst ( lst <fname> -- )  parsews : (savelst) ( lst c-adr n -- )  
	| write list to file c-adr n
   foc dup -1 =if drop z" (savelst) : file tie failure" throw then  >r
   storelst --aab r@ write ioerr @ swap nakedfree
    if z" file write error " throw then 
   r> close ;
 
: savelist ( lst str -- ) | Write list to file 
  2p>  van (savelst) 2P ;

: savedic ( -- ) | save dictionary	|
  R storelst str  | computed 1st , the left on stack  
  s" del " COSYSTARTFILE cL s" .bk" cL { shell nil } onvan drop  
  s" ren " COSYSTARTFILE cL s" .csy CoSy.bk" cL >r> van shell r> ref0del 
   COSYSTARTFILE s" .csy"  cL Foverwrite  ;

0 [IF]
: savedic ( -- ) | save dictionary	|
 $.s cr
	R storelst str  | computed 1st , the left on stack  
  s" del " COSYSTARTFILE cL s" .bk" cL { shell nil } onvan drop  
  s" ren " COSYSTARTFILE cL s" .csy CoSy.bk" cL  | 20170718.1349 			 
 $.s cr 
| s" ren " COSYSTARTFILE cL s" .csy " cL 
|   CoSyFile cL s" .bk" cL  shell^ 
   COSYSTARTFILE s" .csy"  cL Foverwrite  ;
[THEN]

| ======== |
 |  CoSyDir 

| convert linear form back to allocated
defer (rstrlst)
 
: restorelst ( addr -- lst )		| address of dic linear representation        
   to buf  bpos off		| uses allocbuf buffer vars . 
   10 K* IlstInit
   (rstrlst) Ilst @ refs-  | memory tree structure
    ;
 
: ((rstrlst)) ( -- lst ) 
     bufcur  dup @ dup
	  0 <if ( ALREADY STORED ) nip negate Ilst @ swap ic@ 
	   refs+> cell bpos +! ;then  
	   
	  ( NEW )
      0if ( LIST ) i# dup cellVecInit	| bufadr i# new		
	   dup 1 swap refs!  dup Ilst! Head# cells bpos +! 
       swap 0 ?do ((rstrlst)) over i ic! loop ;then 
	  
       ( SIMPLE ) dup vsize dup bufinc 
	  aligned dup allocate >r> Ilst!	| is ` aligned necessary ?
	   r@ swap move 1 r@ refs! r> ;
 
' ((rstrlst)) is (rstrlst)
 
: restorelist ( str -- dic ) dup vbody restorelst swap ref0del ;

: (restorefile) ( a n -- lst )
  slurp 0if drop z" (restorefile) : file empty or non-existant " throw then 
  dup restorelst swap free ;
 
: restorefile ( str -- lst )  ['] (restorefile) onvan ;  | str is file name .
 
| : restore CoSyDir van CoSyFile strcatf " .csy" strcatf
|   (restorefile) ['] R rplc ;

: duplst ( lst -- nwlst )
  dup+ storelst drop dup restorelst swap free swap refs-ok ;

| /\ SAVE LIST  /\ ========================================== /\

." | SaveRestore end | " $.s  cr 

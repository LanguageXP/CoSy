| Proto 4th.CoSy Interface 
|
| Author: Bob Armstrong building upon resources created by 
|  Danny Reinhold / Reinhold Software Services
| upon the IUP GUI toolkit:
| Copyright � 1994-2005 Tecgraf / PUC-Rio and PETROBRAS S/A.
|
| Reva's license terms also apply to this file

cr ." | Job.f  begin | "

with~ ~iup

|  \/ KEY DEFS \/ | ===================== |
: KeyDefs ( Handle -- Handle )
    { " help" (sym) v@ van rtype } key-F1-cb
   |	:{ textwdo selected-text? --bc 2dup . . 2dup type gethelp }; z" K_sF1"  set-callback
   
     key-F5-cb: insert-text
	 { ['] evaln add-callback gui-default } key-F6-cb
     { { curln ['] CSinterpret type>res $.sUpdate } add-callback gui-default }  key-F7-cb
	 ['] ins-hm key-F11-cb
	 key-F12-cb: ins-dayln
	 ['] saveText key-cS-cb  ;
	 
|  /\ KEY DEFS /\ | ===================== |

0 [IF]
|  \/ DEFAULT ATTRIBUTES \/ | ===================== |
  ed >t0> DMP
  ed refs+> >aux
  s" 400x200"		` SIZE		aux@ dicapnd
  s" IUP_CENTER"	` X			aux@ dicapnd
  s" IUP_CENTER"	` Y			aux@ dicapnd
  s" 8"				` TABSIZE	aux@ dicapnd
  s" IUP_CENTER"	` Y			aux@ dicapnd
  s" 1,1"			` CARET		aux@ dicapnd
	
  aux@ lst

| ed cs-> _ATR

| `. _ATR

aux@ ` DEFAULT `@ _ATR (v!)

 ` DEFAULT `@ _ATR (v@) lst

| /\ DEFAULT ATTRIBUTES /\ | ===================== |
[THEN]


0 [IF]

  z" multilineAction" IupMultiLine value *txtbx
  *txtbx z" EXPAND" z" YES" IupSetAttribute drop

  *txtbx IupDialog value *dlg
  *dlg z" SIZE" z" 400x200" IupSetAttribute drop |
  *dlg 700 300 IupShowXY drop  
  *dlg z" TITLE" z" ToDo" IupSetAttribute drop 

  *txtbx z" VALUE" `@ ToDo van zt  IupStoreAttribute drop
  *txtbx z" VALUE" IupGetAttribute ztype
  
  *txtbx z" VALUE" text> >t0> van zt  IupStoreAttribute drop
   *txtbx IupGetAttributes ztype
  *txtbx z" SIZE" IupGetAttribute ztype  | 313x170
  *dlg z" SIZE" IupGetAttribute ztype  |
  *dlg z" X" IupGetAttribute  zcount eval .
  *dlg z" Y" IupGetAttribute  zcount eval .


: define-txtwdo ( text -- dialogH textboxH )
  >r dialog[ editbox[ " 320x300" size  expand  " Test Text" tip
     " LUCIDA CONSOLE::10" attr: FONT 
   r> van setval >r> ]w ]d r> ;    

[THEN]

` IntroHelp value `text 

_n dup value dlgH  value txtH 

: newwdo ( -- dialogHandle MultiLineHandle )
 z" multilineAction" IupMultiLine 
 dup z" EXPAND" z" YES" IupSetAttribute drop
 dup IupDialog swap ;
 
: showXY ( dlgH X Y -- ) IupShowXY drop ; 

: getX ( dlgH -- int ) z" X" IupGetAttribute zcount >single drop ;
: getY ( dlgH -- int ) z" Y" IupGetAttribute zcount >single drop ;
: getpos ( dlgH -- X Y ) dup getX swap getY ; | get UL corner pos of window .

: setsize ( dlgH z" XxY" -- ) z" SIZE" swap IupSetAttribute drop ;
: getsize ( dlgH -- z" XxY" ) z" SIZE" IupGetAttribute ;



: setAttr ( H lbl str -- ) dsc zt swap dsc zt swap IupSetAttribute drop ;  

: settxt ( txtH str -- ) z" VALUE" swap van zt IupStoreAttribute drop ; 
: gettxt ( txtH -- str ) z" VALUE" IupGetAttribute zcount str ; 

: settit ( dlgH str -- ) z" TITLE" swap van zt IupStoreAttribute drop ; 
: gettit ( dlgH -- str ) z" TITLE" IupGetAttribute zcount str ; 

: settab ( dlgH str -- ) z" TABSIZE" swap dsc zt IupStoreAttribute drop ; 
: gettab ( dlgH -- str ) z" TABSIZE" IupGetAttribute zcount str ; 

: savetxt ( -- ) | uses globals dlgH and txtH  
 dup 1 c+ @ gettxt R rot @ gettit v! ;
| saves text of text dialog based on title .

: svtxt ." svtxt | " $.> txtH gettxt R dlgH gettit v! ." | " $.> cr ;

: closedlg dlgH IupDestroy drop  _n dup addr dlgH 2! ;

: show`txt ( sym -- ) | also sets global value pair dlgH and txtH   
  newwdo addr dlgH 2! 
  R over v@ txtH swap settxt 
  dlgH swap settit
  dlgH z" 300x200" setsize 
  dlgH 800 100 showXY 
  dlgH z" K_F3" ['] svtxt IupSetCallback drop
  dlgH z" KILLFOCUS_CB" ['] svtxt IupSetCallback drop
  dlgH z" CLOSE_CB" ['] closedlg IupSetCallback drop 
 ;

0 [IF]  
  curwdo 1 c+ @ gettxt R curwdo @ gettit v!
  addr dlgH dup 1 c+ @ gettxt R rot @ gettit v!
[THEN]

0 [IF] 
: displayXY ( text X Y -- dialogHandle MultiLineHandle ) rot >r newwdo 
 dup r> settxt  over 4 pick 3 pick   
[THEN]


0 [IF]   
: show-text local[ `text | txtbxH dlgH atrdic ]
 | Shows text obj in own window 
  `text van type cr
 `text refs+ 
 dic ` _ATR v@ `text vx dup _n =if ." default " cr
  drop dic ` _ATR v@ ` DEFAULT v@ `text swap v! then	| if virgin ,
													| default attrs
  z" multilineAction" IupMultiLine dup to txtbxH
  dup z" EXPAND" z" YES" IupSetAttribute drop
  IupDialog dup to dlgH 
  dup z" TITLE" `text van zt IupSetAttribute drop 
  dic ` _ATR v@ `text v@ dup	| dlgH attrs 
  
  100 600 IupShowXY drop    $.s cr
  
  @ dup to atrdic d# 0 ?do  dlgH atrdic 0 i@ i i@ van zt 
	 atrdic 1 i@ i i@ van zt IupSetAttribute loop   
  
  dup z" SIZE" z" 400x200" IupSetAttribute drop |
 
  txtbxH z" VALUE" `text v@ van .s cr zt IupSetAttribute drop

  `text refs- ;
   
[THEN]

  ." Here "

0 [IF]	

: Job local[ name ] 

| \/ DIALOG DEF \/ | ===================== |
  dialog[
   spacer
   "  res" label[  ]w
   editbox[ " 320x120" size  expand  " Result " tip
     " LUCIDA CONSOLE::10" attr: FONT 
     dup reswdo ! ]w
	 
    spacer
	
| \/ TEXT BOX DEF \/ | ===================== |

   "  text" label[  ]w   
   editbox[  " 320x300" size  expand  " Working Text" tip
     " LUCIDA CONSOLE::10" attr: FONT 
    | " APLSans::10" attr: FONT
	
|  \/ KEY DEFS \/ | ===================== |

     { " help" (sym) v@ van rtype } key-F1-cb
   |	:{ textwdo selected-text? --bc 2dup . . 2dup type gethelp }; z" K_sF1"  set-callback
     key-F5-cb: insert-text
	 { ['] evaln add-callback gui-default } key-F6-cb
     { { curln ['] CSinterpret type>res $.sUpdate } add-callback gui-default }  key-F7-cb
	 ['] ins-hm key-F11-cb
	 key-F12-cb: ins-dayln
	 ['] saveText key-cS-cb        

|  /\ KEY DEFS /\ | ===================== |

	txt 2@ setval dup textwdo ! ]w
	
| /\ TEXT BOX DEF /\ | ===================== |
	
	spacer
   
   "  $tack : number of items on stack                          "
    label[ dup sWdo ! ]w

| \/ BUTTON DEFS \/ | ===================== |
	hbox[ 
      " Eval current line" button[ action: eval-current-line  " Evaluate the current line!" tip  ]w
       | " Eval Selection!" button[ action: eval-selected-text  " Evaluate selected text!" tip  ]w
	  " Get file name(s)" button[ { file-dlg str >t0> ['] lst type>res } action " file-dlg str >t0> lst" tip ]w
	  " Reset stack " button[ { { reset $.sUpdate } add-callback gui-default } action " reset" tip ]w
	   | " Reset stack 2 " button[ { reset $.sUpdate } cb action " reset" tip ]w
      " Save " button[ action: saveText " savetext savedic" tip  ]w
	  " Quit" button[  action: quit  " Quit Tui" tip  ]w
	  " bye" button[  action: gbye " exit Reva.CoSy" tip  ]w
    ]c
| /\ BUTTON DEFS /\ | ===================== |


  ]d " Proto 4th.CoSy "  title ( " myimage"  attr: ICON ) ;
| /\ DIALOG DEF /\ | ===================== |  
[THEN]
  
." | Job.f end | "

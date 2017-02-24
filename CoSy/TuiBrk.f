| Proto 4th.CoSy Interface 
|
| Author: Bob Armstrong building upon resources created by 
|  Danny Reinhold / Reinhold Software Services
| upon the IUP GUI toolkit:
| Copyright � 1994-2005 Tecgraf / PUC-Rio and PETROBRAS S/A.
|
| Reva's license terms also apply to this file

cr ." | Tui begin | " type cr

~ needs ui/gui exit~ 
~ui

: key-cS-cb	 ( handle xt -- handle )	z" K_cS"		set-callback  ;

: key-F1-cb	 ( handle xt -- handle )	z" K_F1"		set-callback  ;
: key-F2-cb	 ( handle xt -- handle )	z" K_F2"		set-callback  ;
: key-F3-cb	 ( handle xt -- handle )	z" K_F3"		set-callback  ;
: key-F4-cb	 ( handle xt -- handle )	z" K_F4"		set-callback  ;
: key-F5-cb	 ( handle xt -- handle )	z" K_F5"		set-callback  ;
: key-F6-cb	 ( handle xt -- handle )	z" K_F6"		set-callback  ;
: key-sF6-cb ( handle xt -- handle )	z" K_sF6"		set-callback  ;

: key-F7-cb	 ( handle xt -- handle )	z" K_F7"		set-callback  ;
: key-F8-cb	 ( handle xt -- handle )	z" K_F8"		set-callback  ;
: key-F9-cb	 ( handle xt -- handle )	z" K_F9"		set-callback  ;
: key-F10-cb ( handle xt -- handle )	z" K_F10"		set-callback  ;
: key-F11-cb ( handle xt -- handle )	z" K_F11"		set-callback  ;
: key-F12-cb ( handle xt -- handle )	z" K_F12"		set-callback  ;

macro
: key-F1-cb:	' literal,  p: key-F1-cb  ;
: key-F2-cb:	' literal,  p: key-F2-cb  ;
: key-F3-cb:	' literal,  p: key-F3-cb  ;
: key-F4-cb:	' literal,  p: key-F4-cb  ;
: key-F5-cb:	' literal,  p: key-F5-cb  ;
: key-F6-cb:	' literal,  p: key-F6-cb  ;
: key-F7-cb:	' literal,  p: key-F7-cb  ;
: key-F8-cb:	' literal,  p: key-F8-cb  ;
: key-F9-cb:	' literal,  p: key-F9-cb  ;
: key-F10-cb:	' literal,  p: key-F10-cb  ;
: key-F11-cb:	' literal,  p: key-F11-cb  ;
: key-F12-cb:	' literal,  p: key-F12-cb  ;
forth

: insert  ( handle a n -- handle )  attr: INSERT ;

: topmost ( handle b -- handle ) if " YES" else " NO" then attr: TOPMOST ; 

exit~ with~ ~iup with~ ~ui  

alias: gui gui-main-loop

: quit callback gui-close ; 
: gbye callback bye ; 


| : cb ( xt -- xt )  compile p[ add-callback gui-default ]p ;

variable textwdo
variable reswdo
variable sWdo
variable llWdo
variable btnswdo

2variable res 
2variable txt 

` res refs+> value `res

| Kludges to simplify displaying and storing R obs 
 ` resvar refs+> value `resvar 
: >resvar> dup : >resvar `resvar Dv! ;
: resvar `resvar Dv@ ;
 
: res> reswdo @ getval --bc str ;
: saverestxt res> R `res v! ;
: rtype ( a n -- ) reswdo @ -rot setval drop ; 
: >res ( str -- ) dup van rtype ref0del ;

: ->  >resvar> R swap v@ ; 	| 20160525 | eliminated ' stype . 
: >-  res> R resvar v!  ;

` text refs+> value text

: text> textwdo @ getval str nip ;

: savetext text> R text v! ;

: saveLastsave ymdhms R " lastSave" (sym) v! ;

(  :: savetext savedic time&date _ymdhms rtype ; 16 cb: saveText )


| prior  ~util.save  |
: save callback  savetext saverestxt  savedic saveLastsave ;

| : >text ( str -- ) dup van textwdo @ -rot setval drop ref0del ; 
: >text ( str -- ) { textwdo @ -rot setval drop } onvan ;	| Mon.Jul,20130715
: $.sUpdate spon ." $tack : "  $.s  spoff  
   sWdo @  z" TITLE"  spoolbuf lcount ( 2dup type cr ) zt IupStoreAttribute drop ; 

0 [IF]
: evalsel 
  ." Caret position: "  textwdo @  caret?  type cr
  ." Selection: "  textwdo @  selection?  type cr
  ." Evaluating selected text: " 
   textwdo @  selected-text?  2dup type cr  eval
   gui-default ; 
(  ' evalsel   16 cb: eval-selected-text )
: eval-selected-text callback evalsel ; 
[THEN]

` L refs+> value L   ` LL refs+> value LL 

 s"  last xeq | " refs+> value llLbl 

: llUpdate llWdo @  z" TITLE"  llLbl L cL >r> van zt ( dup ztype cr )
	IupStoreAttribute drop r> refs- ; 

: curln ( wdo -- a n ) | line_under_cursor 
    @ caret-y? line-text? --bc ;

: getcurln ( wdo -- str ) curln 2dup str addr L rplc ;

: type>res (spool) 2dup res 2! rtype ;

| Evaluate line under cursor 
 
: evaln ( ? -- ? ) { getcurln eval } catch ?dup if ['] caught type>res ;then
	  depth 0 =if nil then ;

: f6 { getcurln eval } catch ?dup if ['] caught type>res ;then 
    depth 0 =if nil then >R0> ['] lst type>res 
	llUpdate  $.sUpdate ;

: fs6 { getcurln ['] eval type>res } catch ?dup if ['] caught type>res then
	llUpdate  $.sUpdate ;

alias:  |>| |
| : f3 { getcurln eval } catch ?dup if ['] caught type>res ;then 
|    depth 0 =if nil then >R0> ['] lst type>res 
| 	llUpdate  $.sUpdate ;

|  : eval-current-line callback f6 ; 
 
| : f3 evaln LL "  |>| " swap insert  ; 

 
| Evaluate pure CoSy object line . display result 
: CSinterpret { getcurln eval dup addr r rplc r ['] lst type>res } catch
  ?dup if ['] caught type>res then  llUpdate $.sUpdate ; 

: insert-text callback textwdo @ ( "  | |>| " insert ) reswdo @ getval --bc insert drop ; 

: ins-hm ( wdo -- ) @ |hm| insert drop ;
 
| : ins-ymdhms textwdo @ ymdhms_ insert drop ; 
| : ins-ymdhm @ ymdhm s"  | " enc braket ['] insert onvan drop ; 
: ins-ymd.hm @ ymd.hm_ insert drop ; 

: ins-dayln @ toDayln insert drop ;

: spout (spool) rtype ;

: fileDialog : file-dlg	( -- str ) 
  file-open-dialog[
    " YES" attr: MULTIPLEFILES ]fd
  popup getval unixslash str swap destroy ;  

: win> ( handle -- str ) @ getval --bc str ;
: >win ( str handle -- ) {  @ -rot setval drop } onvan ;
  
 variable statewdo  
 2variable state 
 
: state>  statewdo win> ;
: >state ( str -- ) { statewdo @ -rot setval drop } onvan ;
: savestate state> " state" (sym) Dv! ; 


: insert-text_state callback statewdo @ ( "  | |>| " insert ) reswdo @ getval --bc insert drop ; 

| : save callback  savetext saverestxt savestate savedic saveLastsave ;


 ." | \\/ DIALOG DEF \\/ | " $.s cr
| \/ DIALOG DEF \/ | ===================== |
variable d1  
: define-dialog1 ( -- dialoghandle )
 | 32 32 dlg-icon-bitmap iup-image  dup " 0 0 255" attr: 0  dup " 255 0 255"  attr: 1  dup  z" myimage" swap iup-set-handle drop
  
  dialog[
   spacer
 " last executed line |                                                                 " label[ dup llWdo ! ]w
   spacer
   
| \/ ` res WINDOW \/ | ===================== |

   "  res" label[  ]w
     editbox[ 
     " sys" (sym) Dv@ " Tui" (sym) v@ " res" (sym) v@ van size 
     expand  " Result " tip 
     " sys" (sym) Dv@ " Tui" (sym) v@ " font" (sym) v@ van 
       attr: FONT 
 
    { s" res.help" >resvar> R swap v@ >res } key-F1-cb
    { reswdo ins-hm } key-F11-cb
	{ reswdo ins-ymd.hm } z" K_sF11" set-callback
	
	{ reswdo ins-dayln } key-F12-cb
	
	{ >- save } key-cS-cb | save res text to resvar . save envirnment 
	 
     res 2@ setval dup reswdo ! ]w
| /\ ` res WINDOW /\ | ===================== |
	spacer
| \/ ` text WINDOW \/ | ===================== |	
    "  text" label[  ]w
    editbox[ 
    " sys" (sym) Dv@ " Tui" (sym) v@ " text" (sym) v@ van size 
     expand  " Working Text" tip 
     " sys" (sym) Dv@ " Tui" (sym) v@ " font" (sym) v@ van  attr: FONT 
	| " 8" attr: TABSIZE
    | " APLSans::10" attr: FONT

| \/ ` text KEY DEFS \/ | ===================== |
 
    { s" keyhelp" >resvar> R swap v@ >res } key-F1-cb 
 	 
	 ['] save key-cS-cb 
	 
|    { { f6 insert-text  gui-default } add-callback gui-default } key-F3-cb
	 
     key-F5-cb: insert-text
|	 ['] insert-R0 z" K_sF5" set-callback   | bombs
	 
	 { { save `res `resvar Dv! textwdo f6  gui-default } add-callback gui-default } key-F6-cb
	 
	 { { fs6  gui-default } add-callback gui-default } key-sF6-cb
 
     { curln str shell> } z" K_cF6" set-callback
 
|	 ['] fs6  z" K_sF6" set-callback

	 
|	 { { fs6 gui-default } add-callback gui-default } key-F7-cb 
|	{ { CSinterpret gui-default } add-callback gui-default } key-F7-cb
	 
	 { curln str -> } z" K_F9" set-callback 
	 { curln str www } z" K_cF9" set-callback 
	 
	 { textwdo ins-hm save } key-F11-cb
	 { textwdo ins-ymd.hm } z" K_sF11" set-callback
|	 ['] ins-ymdhm z" K_sF11" set-callback
 
	 { textwdo ins-dayln } key-F12-cb
 
| /\ KEY DEFS /\ | ===================== |

	txt 2@ setval dup textwdo ! ]w
	spacer

| \/ ` state WINDOW \/ | ===================== |
 
   "  state" label[  ]w
     editbox[ 
     " sys" (sym) Dv@ " Tui" (sym) v@ " state" (sym) v@ van size 
     expand  " state " tip 
     " sys" (sym) Dv@ " Tui" (sym) v@ " font" (sym) v@ van attr: FONT 

    { s" keyhelp" >resvar> R swap v@ >res } key-F1-cb

     key-F5-cb: insert-text_state
	 
	 { { save `res `resvar Dv! statewdo f6  gui-default } add-callback gui-default } key-F6-cb
	 
	 { { fs6  gui-default } add-callback gui-default } key-sF6-cb
 
    { statewdo ins-hm } key-F11-cb
	{ statewdo ins-ymd.hm } z" K_sF11" set-callback
	
	{ statewdo ins-dayln } key-F12-cb
	
	{ savestate save } key-cS-cb | save text to state . save envirnment 
	 
     state 2@ setval dup statewdo ! ]w
| /\ ` state WINDOW /\ | ===================== |
	spacer
 "  $tack | ( stack contents in hex )  $.s |                                        "  label[ dup sWdo ! ]w

| \/ BUTTON DEFS \/ | ===================== |
	hbox[ dup btnswdo !
	
      | " Eval current line" button[ action: eval-current-line  " ( Evaluate the current line! )" tip  ]w
	  
      | " Eval Selection!" button[ action: eval-selected-text  " Evaluate selected text!" tip  ]w
	   
|	  " Get file name(s)" button[ { fileDialog >t0> ['] lst type>res } action |	   " fileDialog >t0> lst" tip ]w
	  
	  " Reset stack " button[ { { reset $.sUpdate gui-default } add-callback gui-default } action " reset" tip ]w
	  
	  " D>" button[ { { ['] D> spout gui-default } add-callback gui-default } action " ' D> spout ( dumps first 8 cells of object on ToS w/o change ) "  tip ]w
	  
	  " o" button[ { { ['] o spout gui-default } add-callback gui-default } action " ' o spout ( displays object on ToS w/o change ) "  tip ]w
	  
	  " over o drop" button[ { { over ['] o spout drop $.sUpdate gui-default } add-callback gui-default } action " over ' o spout drop ( displays second object on stack w/o change ) "  tip ]w
	  
	  " lst " button[ { { ['] lst spout $.sUpdate gui-default } add-callback gui-default } action " ' lst spout ( displays object on ToS consuming , freeing if refs = 0 ) "  tip ]w

	   " Dnames " button[ { { Dnames ['] lst spout $.sUpdate gui-default } add-callback gui-default } action " ' names in R "  tip ]w
	  
	   " lastSave " button[ { { R s" lastSave" v@ ['] lst spout $.sUpdate gui-default } add-callback gui-default } action " ' TS of last Save "  tip ]w

	   | " Reset stack 2 " button[ { reset $.sUpdate } cb action " reset" tip ]w
      
	   " Save " button[ action: save " save everything " tip  ]w
	  
	  " Quit" button[  action: quit  " ( Quit Tui )" tip  ]w
	  " bye" button[  action: gbye " ( exit Reva.CoSy )" tip  ]w
	  
    ]c
| /\ BUTTON DEFS /\ | ===================== |

  ]d fullCoSyFile van title ( " myimage"  attr: ICON ) ;
| /\ DIALOG DEF /\ | ===================== |  
." /\\ Dialog DEFed /\\ " $.s cr

|  needs Job.f 

: getset R text v@ van txt 2!  R `res v@ van res 2! s" state" Dv@ van state 2!
  define-dialog1 d1 ! ;

getset 

cr $.s cr

: go d1 @ 0 0 show-xy 0 topmost >r 
	gui-main-loop 
	r> hide destroy ;
 
| : go d1 @ 0 0 show-xy 0 topmost >r  gui-main-loop  r> hide destroy  ;

cr $.s ." | Tui end | " cr


| Furniture : fns to flesh out the living area .
| Require CoSy APL object vocabulary . Does not require R dictionary obs 
| Author: Bob Armstrong / www.CoSy.com
| Reva's license terms also apply to this file.

cr ." | Furniture begin | "

| |\/| MISC UTILS |\/|

: str>pad_ ( str -- a n ) { pad place } onvan pad count ;
| Move string < 1024 bytes to pad and free if ref count 0 . 

: dae ( v -- v ) >aux+> dup ['] rho 'm ,/ i0 <>i & at aux- ; 
| Delete All Empties . Deletes all empty , items of a list . 
| translated from K | { x @ & 0 < #:' x } |

: MV 2p R@ L@ ['] cL 'R  ,/ R@ rho cut 2P> ;
| Matrix to Vector . Ravels , eg : lists of strings LA inserting token RA
| , eg : "bl or "lf , as a delimiter | in K | { ( # x ) _ ,/ x ,/: y }

| |/\| MISC UTILS |/\|

| |\/| FILE & OS FNS |\/| with CoSy args
 
: dosslash^ ( str -- str ) { dosslash str } onvan ; | convert all / to \ |	
 
: />\\  s" /" s" \\" ,L ssr ; 	| probably what you want vs dosslash^ 

: \>/ s" \\" s" /" ,L ssr ; 	| replaces DOS \ w RoW / .

: "lf>"nl "lf "nl ,L ssr ; 	| convert UNIX "lf line breaks to DOS "nl 
 
: "nl>"lf "nl "lf ,L ssr ; 	| convert DOS "lf line breaks to UNIX "n| 
| Use to convert ' res> result for saving as CoSy source file .

: include^ ( fname -- flag ) { (include) ioerr @ _i } onvan ; | returns 0 on success

: Fcreate ( fn -- fileid ) dup van fcreate ref0del ; 
 
: Fwrite ( dat fn -- )  over van --abca van foc >r> write r> close 2ref0del ;
 
: >F : Foverwrite ( str flnm ) over van --abca van foverwrite  2ref0del ;
 
: F> : slurp^ ( str -- str ) >r> van slurp r> ref0del
	--aab str swap nakedfree ;
| Like "slurp" but takes and returns CoSy strings and frees original .


: shell^ ( str -- str ) dup van shell ref0del ;
 
: shell> ( str -- str ) dup van shell$ --aab str swap free swap ref0del ;
    | executes str in OS returns any output . 
	| need to double \\ in strings since \ is the escape for \" .
	| see also ` dosslash^  
 
: start s" start C:\\Windows\\System32\\cmd.exe /k " swap cL shell^ ; 
| start DOS program in separate command shell . 

| |/\| FILE & OS FNS |/\| with CoSy args

| s" C:/4thCoSy/lib/alg/hsort" include^ >_ $.s if z" load fail : hsort " throw then
| s" C:/4thCoSy/lib/helper" include^ >_ if z" load fail helper " throw then

: forth> ( str -- str ) { ['] eval (spool) str } onvan ;
 | evaluates str spooling and returning output . | 20160605.1138

: www ( str -- )  R s" BROWSER" v@  | open URL in BROWSER  
  swap cL shell^ ;

: WSb ( str -- bool_of_WhiteSpace ) { 33 <I _i } eachM> ['] cL across ;

: WScut ( str -- list_of_strings_split_on_WhiteSpace ) dup WSb & cut ;

: WStable ( str -- table ) ev temp ! 
   VMlf { WScut enc temp @ swap cL temp ! } eachM temp @ ;
|  converts string containing table , eg read off browser screen , to CoSy
| list of lists splitting rows on "cr"s and columns on any white space .


| \/ \/ \/ Stack made with CoSy obs \/ \/ \/ |
ev refs+> variable, stk			| set stk to an empty vector 

: p ( obj -- ) stk @ cL  stk rplc ;		| push 

: P ( -- obj ) stk @			| pop
   dup i# 0if drop ev refs+> ;then		| if empty return empty
   dup dsc  swap i1 _   stk rplc  dup refs-ok ; 
| /\ /\ /\ Stack made with CoSy obs /\ /\ /\ |

| \/ \/ \/ |  REF COUNTING  | \/ \/ \/ |
 
  0 _i 64 K* _take refs+> value AFbuf
variable AFptr 
 
: AFbufON ( -- ) 
	| note not modulo . subject to overflow . 
 { dup AFbuf vbody AFptr @>+! c+ ! } >defer AT+>
 { negate AT+> negate } >defer FT+> ;  | - adr  for freeing
 
: AFbufOFF ( -- ) undo AT+>  undo FT+> ;
 
: AF1 AFptr off  AFbufON ; 		: AF0 AFbufOFF ; 	: AF> AFbuf AFptr @ _take ; 
 
| /\ /\ /\ |  REF COUNTING  | /\ /\ /\ |

| ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ | 
| \/ \/ | Time Fns | \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ |
 
: ymd.hms_ time&date _ymd.hms_ ;  : ymd.hms ymd.hms_ str ; 
| : |ymd.hms| ymd.hms s" |" braket ; : |ymd.hms|_ |ymd.hms| str>pad_ ;

: _ymdhms _ymdhms_ str ;      : ymd.hm ymd.hm_ str ;
: ymdhms ( -- yyyymmdd.hhmmss ( string ) time&date _ymdhms ;

: ymdhm ( -- yyyymmdd.hhmm ) ymdhm_ str ;
: |ymd.hm| ymd.hm s" | " s"  | " ,L braket ; : |ymd.hm|_ |ymd.hm| str>pad_ ;

| Converting  ' daysdif  used to compute days of my life to take CoSy dates
: date_ ( yyyymmdd _i -- d m y ) >r> vbody @ dtupk r> ref0del ;
: daysdif^ >r date_ r> date_ daysdif _i ; 	| 20171112 

| Cut text into day entries ( approximate as can be seen from def . )
 "lf s"  | ======================== | " cL refs+> value daylnTok 
: daylncut ( str -- listOFstrings ) daylnTok tokcut ;
 
| \/ Calendar \/ | 
 
| : dt time&date 6 s>iv ;
 
: daylns ( d m y n -- ) | outputs daylines for begining date + n days . 
 >r date>fixed _i r> _iota +i { fixed>date dayln type cr } eachM ;
| >r date>fixed _i r> _iota ['] +i aaply { fixed>date dayln type cr } eachM ;

| : DAYLNS ( date number -- str ) 2p L@ i_ dtupk R@ i_  

0 [IF]
: _jd ( v_yyyymmdd -- v_julian ) | same as K _jd except 00010101 is 1 instead of 20350101 -> 0 .  
[THEN]

| /\ /\ | Time Fns | /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ |

| \/ \/ | partitioned string fns | \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ |

: strCmpr ( s0 s1 -- -0+ ) | returns -1 if s0 < s1 , 0 if identical up to length of shorter , 1 if s0 > s1
  2p> i#i# min 
   0do L@ i i@ R@ i i@ >sn ?dup if _i 2P> unloop ;then loop 2P i0 ; 

| \/ \/ | partitioned string fns | \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ |
 
 "nl "nl cL refs+> value emptyLn
 | MS-DOS definition of blank line . must be changed for UNIX \n
 
0 [IF]
: partFind ( phr str delim -- occurances ) | splits str at occurances of delim
	| and returns parts that contain phr .
  toksplt 
  refs+> >r> { "bl cL swap css dup i# M->I _i swap free } eachright
  ['] cL across &  r@ swap at r> refs- ;
 
: partFindBl ( phr str -- occurances )  emptyLn partFind ; 
[THEN]

| /\ /\ | partitioned string fns | /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ |

| \/ \/ | miscellaneous fns | \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ |

: words> ( str -- strL ) s" words " swap cL forth> nlfy -2 _i cut ;
| see   s" help words" spool^ | use "bl arg all words 

: .needs^ ['] .needs (spool) str nlfy i-1  _ dsc ;

: ^!! ( str -- ) dup van shell ref0del ;	| CS version of !! shell execute .

| Convert character vec ( byte to integer ) 
: c>i ( cv -- iv ) ['] _i  'm ,/ ;
|  dup Type@ TypeC <>if ref0del z" must be character " throw ;then
|  dup i# intVecInit >aux> 0 ?do dup i ib@ aux@ i ii! loop ref0del aux> ;
 
| Convert integer to character vec 
: i>c ( iv -- cv ) dup Type@ TypeI <>if ref0del z" must be integer " throw ;then
  dup i# byteVecInit >aux> 0 ?do dup i ii@ aux@ i ib! loop ref0del aux> ;

: ilst ( RA -- indexed_list ) | appends index to list and flips  
	1p> rho iota R@ ,L flip 1P> ;

| /\ /\ | miscellaneous fns | /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ |


| \/ \/ \/ MOST MIMIMAL MATH \/ \/ \/ | 

: PoT 1p R@ R@ +/ %f 1P> ; | Proportion of Total . I find very useful 

: c>f ( fv -- fv )  1.8 _f *f 32. _f +f ; 	| centigrade to farenheit | 20141124 
: f>c ( fv -- fv )  32. _f -f 1.8 _f %f ; 	| farenheit to centigrade | 20141124 

 | ======================================== |

| Split integer vec into positives and negatives 
: +-splt ( iv -- v ) 1p> i-1 >i refs+> >r> & R@ swap at 
	R@ r@ 0=i & at ,L r> refs- 1P> ; 

| /\ /\ /\ |  MATH  | /\ /\ /\ |

|  : ref " notepad \\cosy\\ref.txt" shell ;

| : $^  ( sym -- ) | display var in  res 
|	dup+ " source" (sym)  R " res" (sym)  ;

| save res to value of 
| : saveres ( -- ) ;


| \/ \/ | OPERATORS | \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ |

| : ~=\ ( list -- bool ( not_equal scan )   ;
  
| /\ /\ | OPERATORS | /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ |

| \/ | ARK | \/ |

| `( Type0 TypeC TypeI TypeFl TypeS TypeV TypeA TypeFv )` dup+
|  { van eval _i } eachM> ' cL across  over refs-ok  cL  R ` Types v!

." | Furniture end | " cr 



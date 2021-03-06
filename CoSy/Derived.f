| Fns requiring  ` R  .
| Author: Bob Armstrong / www.CoSy.com
| Reva's license terms also apply to this file.
| Sat.May,20070526 

cr ." | Derived begin | "  type cr 
| Words requiring ' R , Root , list
| ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 

| \/ \/ | CoSy Help Words | \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ |
 
| \/ | raw Forth output .  Use sF6  | \/ |
: Help ( cv -- ) | prints Reva help on multiple words .
   "bl toksplt s"  cr .\" -------\" cr cr help " swap  ['] cL eachright  
   ['] cL across ^eval ; 
| /\ | raw Forth output .  Use sF6  | /\ |

: (CShelp) ( str file -- occurrences ) slurp^ emptyLn toksplt   
   swap con dup i# if { "nl swap cL } eachm then ;
 
: CShelpFul ( str -- refs ) | searches source files listed in 
| `( sys CoSySource )` for str and returns list of files searched 
| and source between preceding and succeeding blank lines containing  str .
  [ R ` sys v@ ` CoSySource v@ ] literal
  { >r> (CShelp) r> swap cL } eachright ;

| \/ |  | Main Help function . Return lines , delimited by empty lines 
 		| in files listed in |  ` sys Dv@ ` CoSySource v@  |
 		| which contain the phase passed
 
: ?? : CShelp CShelpFul >aux+> dup ['] rho 'm ,/ i1 >i & at refs+> aux- refs-ok>  ; 
| /\ |

| Returns only those file in which the phrase was found

| /\ /\ | CoSy Help System | /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ /\ |

." | Derived end | "

# 1 "tpLex.mll"
 
open Ast
open TpParse
exception Eof

(* gere les positions numero de ligne + decalage dans la ligne *)
let next_line lexbuf = Lexing.new_line lexbuf

(* Potentiellement utile pour distinguer mots-clef et vrais identificateurs *)
let keyword_table = Hashtbl.create 16

let _ =
    List.iter (fun (kwd, tok) -> Hashtbl.add keyword_table kwd tok)
      [ "is", IS;
        "class", CLASS;
        "extends",EXTENDS;
        "object",OBJECTS;
        "def",DEF;
        "var",VAR;
        "auto",AUTO;
        "override",OVERR;
        "this",THIS;
        "super",SUPER;
        "result",RESULT;
        "new",NEW;
        "if", IF;
        "then", THEN;
        "else", ELSE
      ]

# 33 "tpLex.ml"
let __ocaml_lex_tables = {
  Lexing.lex_base =
   "\000\000\224\255\225\255\226\255\227\255\228\255\230\255\231\255\
    \232\255\233\255\002\000\235\255\236\255\237\255\239\255\003\000\
    \033\000\245\255\246\255\247\255\050\000\092\000\078\000\251\255\
    \252\255\192\000\011\001\086\001\161\001\236\001\055\002\146\002\
    \249\255\248\255\238\255\242\255\240\255\234\255\144\000\253\255\
    \254\255\049\000\255\255";
  Lexing.lex_backtrk =
   "\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\026\000\255\255\255\255\255\255\255\255\014\000\
    \012\000\255\255\255\255\255\255\011\000\031\000\005\000\255\255\
    \255\255\002\000\002\000\000\000\002\000\002\000\001\000\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\002\000\255\255";
  Lexing.lex_default =
   "\001\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\255\255\000\000\000\000\000\000\000\000\255\255\
    \255\255\000\000\000\000\000\000\255\255\255\255\255\255\000\000\
    \000\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \000\000\000\000\000\000\000\000\000\000\000\000\039\000\000\000\
    \000\000\255\255\000\000";
  Lexing.lex_trans =
   "\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\024\000\023\000\000\000\000\000\024\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \024\000\000\000\021\000\000\000\000\000\000\000\003\000\000\000\
    \013\000\012\000\018\000\019\000\005\000\017\000\004\000\020\000\
    \022\000\022\000\022\000\022\000\022\000\022\000\022\000\022\000\
    \022\000\022\000\010\000\011\000\016\000\014\000\015\000\037\000\
    \036\000\027\000\027\000\027\000\027\000\027\000\027\000\027\000\
    \027\000\027\000\027\000\027\000\027\000\027\000\027\000\027\000\
    \027\000\027\000\027\000\027\000\027\000\027\000\027\000\027\000\
    \027\000\027\000\027\000\007\000\033\000\006\000\035\000\034\000\
    \042\000\026\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\009\000\031\000\008\000\022\000\022\000\
    \022\000\022\000\022\000\022\000\022\000\022\000\022\000\022\000\
    \000\000\000\000\000\000\000\000\031\000\031\000\031\000\031\000\
    \031\000\031\000\031\000\031\000\031\000\031\000\000\000\000\000\
    \000\000\000\000\040\000\000\000\000\000\031\000\031\000\031\000\
    \031\000\031\000\031\000\031\000\031\000\031\000\031\000\031\000\
    \031\000\031\000\031\000\031\000\031\000\031\000\031\000\031\000\
    \031\000\031\000\031\000\031\000\031\000\031\000\031\000\000\000\
    \000\000\000\000\041\000\031\000\000\000\031\000\031\000\031\000\
    \031\000\031\000\031\000\031\000\031\000\031\000\031\000\031\000\
    \031\000\031\000\031\000\031\000\031\000\031\000\031\000\031\000\
    \031\000\031\000\031\000\031\000\031\000\031\000\031\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \002\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\000\000\000\000\000\000\000\000\025\000\
    \000\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\000\000\000\000\
    \000\000\000\000\025\000\000\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \028\000\025\000\025\000\025\000\025\000\025\000\027\000\027\000\
    \027\000\027\000\027\000\027\000\027\000\027\000\027\000\027\000\
    \255\255\000\000\000\000\000\000\000\000\000\000\000\000\027\000\
    \027\000\027\000\027\000\027\000\027\000\027\000\027\000\027\000\
    \027\000\027\000\027\000\027\000\027\000\027\000\027\000\027\000\
    \027\000\027\000\027\000\027\000\027\000\027\000\027\000\027\000\
    \027\000\000\000\000\000\000\000\000\000\027\000\000\000\027\000\
    \027\000\027\000\027\000\027\000\027\000\027\000\027\000\027\000\
    \027\000\027\000\027\000\027\000\027\000\027\000\027\000\027\000\
    \027\000\027\000\027\000\027\000\027\000\027\000\027\000\027\000\
    \027\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\000\000\000\000\000\000\000\000\
    \025\000\000\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\029\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\000\000\
    \000\000\000\000\000\000\025\000\000\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\030\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\000\000\000\000\000\000\000\000\025\000\000\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\031\000\000\000\032\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\031\000\031\000\031\000\031\000\031\000\031\000\
    \031\000\031\000\031\000\031\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\031\000\031\000\031\000\031\000\031\000\
    \031\000\031\000\031\000\031\000\031\000\031\000\031\000\031\000\
    \031\000\031\000\031\000\031\000\031\000\031\000\031\000\031\000\
    \031\000\031\000\031\000\031\000\031\000\000\000\000\000\000\000\
    \000\000\031\000\000\000\031\000\031\000\031\000\031\000\031\000\
    \031\000\031\000\031\000\031\000\031\000\031\000\031\000\031\000\
    \031\000\031\000\031\000\031\000\031\000\031\000\031\000\031\000\
    \031\000\031\000\031\000\031\000\031\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000";
  Lexing.lex_check =
   "\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\000\000\000\000\255\255\255\255\000\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \000\000\255\255\000\000\255\255\255\255\255\255\000\000\255\255\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\010\000\
    \015\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\020\000\000\000\016\000\016\000\
    \041\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\021\000\000\000\022\000\022\000\
    \022\000\022\000\022\000\022\000\022\000\022\000\022\000\022\000\
    \255\255\255\255\255\255\255\255\021\000\021\000\021\000\021\000\
    \021\000\021\000\021\000\021\000\021\000\021\000\255\255\255\255\
    \255\255\255\255\038\000\255\255\255\255\021\000\021\000\021\000\
    \021\000\021\000\021\000\021\000\021\000\021\000\021\000\021\000\
    \021\000\021\000\021\000\021\000\021\000\021\000\021\000\021\000\
    \021\000\021\000\021\000\021\000\021\000\021\000\021\000\255\255\
    \255\255\255\255\038\000\021\000\255\255\021\000\021\000\021\000\
    \021\000\021\000\021\000\021\000\021\000\021\000\021\000\021\000\
    \021\000\021\000\021\000\021\000\021\000\021\000\021\000\021\000\
    \021\000\021\000\021\000\021\000\021\000\021\000\021\000\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\255\255\255\255\255\255\255\255\255\255\255\255\
    \000\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\255\255\255\255\255\255\255\255\025\000\
    \255\255\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\025\000\025\000\025\000\025\000\025\000\
    \025\000\025\000\025\000\026\000\026\000\026\000\026\000\026\000\
    \026\000\026\000\026\000\026\000\026\000\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\026\000\026\000\026\000\026\000\
    \026\000\026\000\026\000\026\000\026\000\026\000\026\000\026\000\
    \026\000\026\000\026\000\026\000\026\000\026\000\026\000\026\000\
    \026\000\026\000\026\000\026\000\026\000\026\000\255\255\255\255\
    \255\255\255\255\026\000\255\255\026\000\026\000\026\000\026\000\
    \026\000\026\000\026\000\026\000\026\000\026\000\026\000\026\000\
    \026\000\026\000\026\000\026\000\026\000\026\000\026\000\026\000\
    \026\000\026\000\026\000\026\000\026\000\026\000\027\000\027\000\
    \027\000\027\000\027\000\027\000\027\000\027\000\027\000\027\000\
    \038\000\255\255\255\255\255\255\255\255\255\255\255\255\027\000\
    \027\000\027\000\027\000\027\000\027\000\027\000\027\000\027\000\
    \027\000\027\000\027\000\027\000\027\000\027\000\027\000\027\000\
    \027\000\027\000\027\000\027\000\027\000\027\000\027\000\027\000\
    \027\000\255\255\255\255\255\255\255\255\027\000\255\255\027\000\
    \027\000\027\000\027\000\027\000\027\000\027\000\027\000\027\000\
    \027\000\027\000\027\000\027\000\027\000\027\000\027\000\027\000\
    \027\000\027\000\027\000\027\000\027\000\027\000\027\000\027\000\
    \027\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\255\255\255\255\255\255\255\255\
    \028\000\255\255\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\029\000\029\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\029\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\029\000\255\255\
    \255\255\255\255\255\255\029\000\255\255\029\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\029\000\029\000\
    \029\000\029\000\029\000\029\000\029\000\029\000\029\000\030\000\
    \030\000\030\000\030\000\030\000\030\000\030\000\030\000\030\000\
    \030\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \030\000\030\000\030\000\030\000\030\000\030\000\030\000\030\000\
    \030\000\030\000\030\000\030\000\030\000\030\000\030\000\030\000\
    \030\000\030\000\030\000\030\000\030\000\030\000\030\000\030\000\
    \030\000\030\000\255\255\255\255\255\255\255\255\030\000\255\255\
    \030\000\030\000\030\000\030\000\030\000\030\000\030\000\030\000\
    \030\000\030\000\030\000\030\000\030\000\030\000\030\000\030\000\
    \030\000\030\000\030\000\030\000\030\000\030\000\030\000\030\000\
    \030\000\030\000\031\000\255\255\031\000\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\031\000\031\000\031\000\031\000\031\000\031\000\
    \031\000\031\000\031\000\031\000\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\031\000\031\000\031\000\031\000\031\000\
    \031\000\031\000\031\000\031\000\031\000\031\000\031\000\031\000\
    \031\000\031\000\031\000\031\000\031\000\031\000\031\000\031\000\
    \031\000\031\000\031\000\031\000\031\000\255\255\255\255\255\255\
    \255\255\031\000\255\255\031\000\031\000\031\000\031\000\031\000\
    \031\000\031\000\031\000\031\000\031\000\031\000\031\000\031\000\
    \031\000\031\000\031\000\031\000\031\000\031\000\031\000\031\000\
    \031\000\031\000\031\000\031\000\031\000\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255";
  Lexing.lex_base_code =
   "";
  Lexing.lex_backtrk_code =
   "";
  Lexing.lex_default_code =
   "";
  Lexing.lex_trans_code =
   "";
  Lexing.lex_check_code =
   "";
  Lexing.lex_code =
   "";
}

let rec token lexbuf =
   __ocaml_lex_token_rec lexbuf 0
and __ocaml_lex_token_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
let
# 47 "tpLex.mll"
              t
# 310 "tpLex.ml"
= Lexing.sub_lexeme lexbuf lexbuf.Lexing.lex_start_pos lexbuf.Lexing.lex_curr_pos in
# 47 "tpLex.mll"
                         ( TYPE t)
# 314 "tpLex.ml"

  | 1 ->
# 48 "tpLex.mll"
                          ( AUTO )
# 319 "tpLex.ml"

  | 2 ->
let
# 49 "tpLex.mll"
                   id
# 325 "tpLex.ml"
= Lexing.sub_lexeme lexbuf lexbuf.Lexing.lex_start_pos lexbuf.Lexing.lex_curr_pos in
# 49 "tpLex.mll"
                         (try (Hashtbl.find keyword_table id) with Not_found -> ID id )
# 329 "tpLex.ml"

  | 3 ->
# 50 "tpLex.mll"
                         ( token lexbuf )
# 334 "tpLex.ml"

  | 4 ->
# 51 "tpLex.mll"
                         ( next_line lexbuf; token lexbuf)
# 339 "tpLex.ml"

  | 5 ->
let
# 52 "tpLex.mll"
                lxm
# 345 "tpLex.ml"
= Lexing.sub_lexeme lexbuf lexbuf.Lexing.lex_start_pos lexbuf.Lexing.lex_curr_pos in
# 52 "tpLex.mll"
                         ( CSTE(int_of_string lxm) )
# 349 "tpLex.ml"

  | 6 ->
let
# 53 "tpLex.mll"
                cste
# 355 "tpLex.ml"
= Lexing.sub_lexeme lexbuf (lexbuf.Lexing.lex_start_pos + 1) (lexbuf.Lexing.lex_curr_pos + -1) in
# 53 "tpLex.mll"
                            ( CONST(cste) )
# 359 "tpLex.ml"

  | 7 ->
# 54 "tpLex.mll"
           ( 
                            (* lance la fonction specialisée dans la
                             * reconnaissance des commentaires
                             *)
                            comment lexbuf
                         )
# 369 "tpLex.ml"

  | 8 ->
# 60 "tpLex.mll"
                         ( PLUS )
# 374 "tpLex.ml"

  | 9 ->
# 61 "tpLex.mll"
                         ( TIMES )
# 379 "tpLex.ml"

  | 10 ->
# 62 "tpLex.mll"
                         ( MINUS )
# 384 "tpLex.ml"

  | 11 ->
# 63 "tpLex.mll"
                         ( DIV )
# 389 "tpLex.ml"

  | 12 ->
# 64 "tpLex.mll"
                         ( RELOP (Ast.Lt) )
# 394 "tpLex.ml"

  | 13 ->
# 65 "tpLex.mll"
                         ( RELOP (Ast.Le) )
# 399 "tpLex.ml"

  | 14 ->
# 66 "tpLex.mll"
                         ( RELOP (Ast.Gt) )
# 404 "tpLex.ml"

  | 15 ->
# 67 "tpLex.mll"
                         ( RELOP (Ast.Ge) )
# 409 "tpLex.ml"

  | 16 ->
# 68 "tpLex.mll"
                         ( RELOP (Ast.Eq) )
# 414 "tpLex.ml"

  | 17 ->
# 69 "tpLex.mll"
                         ( RELOP (Ast.Neq) )
# 419 "tpLex.ml"

  | 18 ->
# 70 "tpLex.mll"
                         ( LPAREN )
# 424 "tpLex.ml"

  | 19 ->
# 71 "tpLex.mll"
                         ( RPAREN )
# 429 "tpLex.ml"

  | 20 ->
# 72 "tpLex.mll"
                         ( SEMICOLON )
# 434 "tpLex.ml"

  | 21 ->
# 73 "tpLex.mll"
                         ( ASSIGN )
# 439 "tpLex.ml"

  | 22 ->
# 74 "tpLex.mll"
                         ( LBRACK )
# 444 "tpLex.ml"

  | 23 ->
# 75 "tpLex.mll"
                         ( RBRACK )
# 449 "tpLex.ml"

  | 24 ->
# 76 "tpLex.mll"
                         ( LCROCHET )
# 454 "tpLex.ml"

  | 25 ->
# 77 "tpLex.mll"
                         ( RCROCHET )
# 459 "tpLex.ml"

  | 26 ->
# 78 "tpLex.mll"
                         ( COLON )
# 464 "tpLex.ml"

  | 27 ->
# 79 "tpLex.mll"
                         ( COMMA )
# 469 "tpLex.ml"

  | 28 ->
# 80 "tpLex.mll"
                         ( DOT )
# 474 "tpLex.ml"

  | 29 ->
# 81 "tpLex.mll"
                         ( AMP )
# 479 "tpLex.ml"

  | 30 ->
# 82 "tpLex.mll"
                         ( EOF )
# 484 "tpLex.ml"

  | 31 ->
let
# 86 "tpLex.mll"
         lxm
# 490 "tpLex.ml"
= Lexing.sub_lexeme_char lexbuf lexbuf.Lexing.lex_start_pos in
# 86 "tpLex.mll"
                         ( (* On met un message et on essaye de scanner la 
                            * suite. pour détecter le plus d'erreurs possibles
                            * d'un coup. Il faudrait probablement mémoriser
                            * qu'on a rencontré une erreur pour signaler à la
                            * fin que le programme était incorrect.
                            *)
             		   print_endline
                             ("undefined character: " ^ (String.make 1 lxm));
                           token lexbuf
           	         )
# 503 "tpLex.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf;
      __ocaml_lex_token_rec lexbuf __ocaml_lex_state

and comment lexbuf =
   __ocaml_lex_comment_rec lexbuf 38
and __ocaml_lex_comment_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 101 "tpLex.mll"
                  ( (* quand on a reconnu la fin du commentaire, on relance
                     * recursivement l'analyseur lexical pour renvoyer le
                     * prochain token à l'analyseur syntaxique puisqu'on ne
                     * transmet pas les commentaires
                     *)
                     token lexbuf
                  )
# 521 "tpLex.ml"

  | 1 ->
# 108 "tpLex.mll"
                  ( next_line lexbuf; comment lexbuf)
# 526 "tpLex.ml"

  | 2 ->
# 109 "tpLex.mll"
                  ( comment lexbuf )
# 531 "tpLex.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf;
      __ocaml_lex_comment_rec lexbuf __ocaml_lex_state

;;


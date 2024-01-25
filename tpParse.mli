
(* The type of tokens. *)

type token = 
  | UMINUS
  | TYPE of (string)
  | TIMES
  | THIS
  | THEN
  | SUPER
  | STATIC
  | SEMICOLON
  | RPAREN
  | RESULT
  | RELOP of (Ast.opComp)
  | RCROCHET
  | RBRACK
  | PLUS
  | OVERRIDE
  | NEW
  | MINUS
  | LPAREN
  | LCROCHET
  | LBRACK
  | IS
  | IF
  | ID of (string)
  | EXTENDS
  | EOF
  | ELSE
  | DOT
  | DIV
  | DEF
  | CSTE of (int)
  | CONST of (string)
  | COMMA
  | COLON
  | CLASS
  | AUTO
  | ASSIGN
  | AMP

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val prog: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Ast.progType)

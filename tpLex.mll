{
open Ast
open TpParse
exception Eof


let next_line lexbuf = Lexing.new_line lexbuf


let keyword_table = Hashtbl.create 16

let _ =
    List.iter (fun (kwd, tok) -> Hashtbl.add keyword_table kwd tok)
      [ "is", IS;
        "class", CLASS;
        "extends",EXTENDS;
        "def",DEF;
        "auto",AUTO;
        "override",OVERRIDE;
        "this",THIS;
        "super",SUPER;
        "result",RESULT;
        "new",NEW;
        "static",STATIC;
        "if", IF;
        "then", THEN;
        "else", ELSE
      ]
}


let lettre = ['A'-'Z' 'a'-'z' ]
let chiffre = ['0'-'9']
let maj= ['A'-'Z']
let LC = ( chiffre | lettre | ['_'] )
let LCE = LC | [' ']


rule
  token = parse (* a completer *)
   
  maj LC * as t          { TYPE t}
  |"auto"                 { AUTO }
  | lettre LC * as id    {try (Hashtbl.find keyword_table id) with Not_found -> ID id }
  | [' ''\t''\r']        { token lexbuf }     (* skip blanks *)
  | '\n'                 { next_line lexbuf; token lexbuf}
  | chiffre+ as lxm      { CSTE(int_of_string lxm) }
  | '"'(LCE+ as cste)'"'    { CONST(cste) }
  | "/*"		 { 
                            
                            comment lexbuf
                         }
  | '+'                  { PLUS }
  | '*'                  { TIMES }
  | '-'                  { MINUS }
  | '/'                  { DIV }
  | '<'                  { RELOP (Ast.Lt) }
  | "<="                 { RELOP (Ast.Le) }
  | '>'                  { RELOP (Ast.Gt) }
  | ">="                 { RELOP (Ast.Ge) }
  | '='                  { RELOP (Ast.Eq) }
  | "<>"                 { RELOP (Ast.Neq) }
  | '('                  { LPAREN }
  | ')'                  { RPAREN }
  | ';'                  { SEMICOLON }
  | ":="                 { ASSIGN }
  | '{'                  { LBRACK }
  | '}'                  { RBRACK }
  | '['                  { LCROCHET }
  | ']'                  { RCROCHET }
  | ':'                  { COLON }
  | ','                  { COMMA }
  | '.'                  { DOT }
  | '&'                  { AMP }
  | eof                  { EOF }

  | _ as lxm             { 
             		   print_endline
                             ("undefined character: " ^ (String.make 1 lxm));
                           token lexbuf
           	         }
and
  comment = parse
  
    "*/"          { 
                     token lexbuf
                  }
  | '\n'          { next_line lexbuf; comment lexbuf}
  | _             { comment lexbuf }

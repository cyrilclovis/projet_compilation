{
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

(* abréviation utiles pour les expressions rationnelles *)
let lettre = ['A'-'Z' 'a'-'z' ]
let chiffre = ['0'-'9']
let maj= ['A'-'Z']
let LC = ( chiffre | lettre | ['_'] )
let LCE = LC | [' ']

(* l'analyseur lexical est decomposé ici en deux fonctions: l'une qui est
 * specialisée dans la reconnaissance des commentaires à la C, l'autre qui
 * traite les autres tokens à reconnaire. les deux fonctions vont coopérer.
 * Tout caractere lu dans le fichier doit être reconnu quelque part !
 *)
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
                            (* lance la fonction specialisée dans la
                             * reconnaissance des commentaires
                             *)
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
(* completer avec les autres regles et actions pour renvoyer le prochain token
 * significatif
 *)
  | _ as lxm             { (* On met un message et on essaye de scanner la 
                            * suite. pour détecter le plus d'erreurs possibles
                            * d'un coup. Il faudrait probablement mémoriser
                            * qu'on a rencontré une erreur pour signaler à la
                            * fin que le programme était incorrect.
                            *)
             		   print_endline
                             ("undefined character: " ^ (String.make 1 lxm));
                           token lexbuf
           	         }
and
  comment = parse
  (* completer avec les autres regles qui definissent ce qu'est un commentaire
   * correct
   *)
    "*/"          { (* quand on a reconnu la fin du commentaire, on relance
                     * recursivement l'analyseur lexical pour renvoyer le
                     * prochain token à l'analyseur syntaxique puisqu'on ne
                     * transmet pas les commentaires
                     *)
                     token lexbuf
                  }
  | '\n'          { next_line lexbuf; comment lexbuf}
  | _             { comment lexbuf }

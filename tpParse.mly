%{
open Ast
%}
%token <string> ID TYPE
%token <int> CSTE
%token <string> CONST
%token <Ast.opComp> RELOP
%token PLUS MINUS TIMES DIV
%token LPAREN RPAREN LBRACK RBRACK LCROCHET RCROCHET
%token ASSIGN NEW
%token EXTENDS OBJECTS CLASS
%token IS VAR AUTO DEF
%token SUPER THIS OVERR RESULT
%token DOT COMMA COLON SEMICOLON
%token AMP

%token IF THEN ELSE BEGIN END

/* utilise pour donner une precedence maximale au - unaire
* L'analyseur lexical ne renvoie jamais ce token !
*/
%token UMINUS
%token APPELFONC
%token ACCESATTR

%token EOF



%nonassoc RELOP
%left PLUS MINUS AMP    /* lowest precedence */
%left TIMES DIV         /* medium precedence */
%left UMINUS
%left DOT


%type <expType> expr
%type <decl> decl


%start<Ast.progType> prog
%%
prog:  ld = list(declBegin) b = bloc EOF { Prog(ld,b) }

declBegin: c = classe {ClasseDecl(c)}
/*| o = objet {ObjDecl(o)}*/

decl: ld = separated_list(COMMA,ID) COLON t = TYPE SEMICOLON { Decl(ld,t)}


paramDecl:
  t= separated_list(COMMA, paramList) {List.flatten t}

paramList:
  c= non_empty_separated_list(COMMA, ID) COLON s = TYPE {List.map (fun i -> Param(i,s)) c }

 


champ : VAR AUTO nom = ID COLON tipe = TYPE SEMICOLON {Champ(nom,tipe,true)}
| VAR nom = ID COLON tipe = TYPE SEMICOLON {Champ(nom,tipe,false)}

declFonction: 
  //Override + return type
  DEF OVERR nom = ID LPAREN params = separated_list(COMMA,param) RPAREN COLON returnType = TYPE IS corps = bloc 
{{name = nom;arguments = params;override = true;returnType = returnType; corps = corps}}
  //Sans override + return type
  | DEF nom = ID LPAREN params = separated_list(COMMA,param) RPAREN COLON returnType = TYPE IS corps = bloc 
{{name = nom;arguments = params;override = false;returnType = returnType; corps = corps}}
  //Override + sans return type
 | DEF OVERR nom = ID LPAREN params = separated_list(COMMA,param) RPAREN IS corps = bloc 
 {{name = nom;arguments = params;override = true;returnType = ""; corps = corps}}
  //Sans Override + sans return type
 | DEF nom = ID LPAREN params = separated_list(COMMA,param) RPAREN IS corps = bloc 
 {{name = nom;arguments = params;override = false;returnType = ""; corps = corps}}
  //Override expression
  | DEF OVERR nom = ID  LPAREN params = separated_list(COMMA,param) RPAREN COLON returnType = TYPE ASSIGN corps = expr SEMICOLON
 {{name = nom;arguments = params;override = true;returnType = returnType; corps = Bloc([],[Expr(corps)])}}
  //Sans Override expression
  | DEF nom = ID LPAREN params = separated_list(COMMA,param) RPAREN COLON returnType = TYPE ASSIGN corps = expr SEMICOLON
 {{name = nom;arguments = params;override = false;returnType = returnType; corps = Bloc([],[Expr(corps)])}}

blocDecl :LBRACK champs = list(champ) decls = list(declFonction) RBRACK {BlocDecl(champs,decls)}

bloc : LBRACK ld = list(decl) IS li = list(instruction) RBRACK {Bloc(ld,li)}
  |LBRACK li = list(instruction) RBRACK {Bloc([],li)}
  

instruction : e = expr SEMICOLON { Expr(e) }
  | b = bloc { InstBloc(b) }
  | IF e = expr THEN it = instruction ELSE ie = instruction {Ite(e,it,ie)}
  | g = expr ASSIGN d = expr SEMICOLON {Assign(g,d)}


//Je n'ai pas fait le UMINUS
expr:
    x = ID  {Id(x)}
  | c = CSTE {Cste(c)}
  | c = CONST {CsteStr(c)}
  | e = delimited (LPAREN, expr, RPAREN) { e }
  //Appel de methode
  | cible = expr DOT methode = ID LPAREN arguments = separated_list(COMMA,expr) RPAREN {AppelFonction(cible,methode,arguments)}
  | cible = expr DOT attribut = ID {AccesAttribut(cible,attribut)}
  | LPAREN t = TYPE e = expr RPAREN { Cast(t,e) }

  | THIS {This}
  | SUPER {Super}
  | RESULT {Result}

  | g = expr PLUS d = expr        { Plus (g, d) }
  | g = expr MINUS d = expr       { Minus(g, d) }
  | g = expr TIMES d = expr       { Times(g, d) }
  | g = expr DIV d = expr         { Div(g, d) }
  | MINUS e = expr %prec UMINUS   { UMinus e }
  | g = expr r = RELOP d = expr   { Comp(g,r,d) }
  | g = expr AMP r = expr         { Concat(g,r) }

/*objet: OBJECTS nom = TYPE constructor = option(bloc) IS corps = blocDecl {{name = nom; constructor = constructor; corps = corps;}} */

classe:
  CLASS nom = TYPE args=delimited(LPAREN,paramDecl,RPAREN) EXTENDS nomSup = TYPE LPAREN paramSup = separated_list(COMMA,expr) RPAREN constructor = option(bloc) IS corps = blocDecl {{name = nom;arguments=arg;heriteFrom = nomSup;argSuper=paramSup;constructor=constructor;corps=corps}}
|CLASS nom = TYPE args=delimited(LPAREN,paramDecl,RPAREN) constructor = option(bloc) IS corps = blocDecl {{name = nom;arguments=arg;heriteFrom = "";argSuper=[];constructor=constructor;corps=corps}}

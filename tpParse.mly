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
%token IS STATIC AUTO DEF
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

prog:
  ld = list(declBegin)
  b = bloc
  EOF
  { Prog(ld, b) }

declBegin:
  c = classe
  { ClasseDecl(c) }
decl:
  ld = separated_list(COMMA, ID)
  COLON
  t = TYPE
  SEMICOLON
  { Decl(ld, t) }

paramDecl:
  t = separated_list(COMMA, paramList)
  { List.flatten t }

paramList:
  c = separated_nonempty_list(COMMA, ID)
  COLON
  s = TYPE
  { List.map (fun i -> Param(i, s)) c }
/*
champ:
  modu = champ_mod
  names = separated_list(COMMA, ID)
  COLON
  t = TYPE
  SEMICOLON
  { List.map (fun name -> Champ(name, t, modu)) names }

champ_mod:
  | STATIC { true }
  | AUTO { false }
  |STATIC AUTO { false }

champ_instruction:
  c = champ SEMICOLON { c }

champ_instructions:
  | c = champ_instruction { [c] }
  | c1 = champ_instruction SEMICOLON c2 = champ_instructions { c1 :: c2 }
*/


champ:
    STATIC n = separated_list(COMMA, ID)
    COLON
    t = TYPE
    SEMICOLON
    { List.map (fun name -> Champ(name, t, true)) n }
    |
    STATIC AUTO n = separated_list(COMMA, ID)
    COLON
    t = TYPE
    SEMICOLON
    { List.map (fun name -> Champ(name, t, true)) n }
    |
    AUTO n = separated_list(COMMA, ID)
    COLON
    t = TYPE
    SEMICOLON
    { List.map (fun name -> Champ(name, t, true)) n }
    |
    n = separated_list(COMMA, ID)
    COLON
    t = TYPE
    SEMICOLON
    { List.map (fun name -> Champ(name, t, false)) n }

declFonction:
  // Fonctions statiques
  | DEF STATIC nom = ID LPAREN params = paramDecl RPAREN COLON returnType = TYPE IS corps = bloc
    {{ name = nom; arguments = params; override = false; returnType = returnType; corps = corps; isStatic = true }}
  // Fonctions de classe
  | DEF nom = ID LPAREN params = paramDecl RPAREN COLON returnType = TYPE IS corps = bloc
    {{ name = nom; arguments = params; override = false; returnType = returnType; corps = corps; isStatic = false }}
  // Fonctions sans déclaration de type de retour (returnType = "")
  | DEF STATIC nom = ID LPAREN params = paramDecl RPAREN IS corps = bloc
    {{ name = nom; arguments = params; override = false; returnType = ""; corps = corps; isStatic = true }}
  | DEF nom = ID LPAREN params = paramDecl RPAREN IS corps = bloc
    {{ name = nom; arguments = params; override = false; returnType = ""; corps = corps; isStatic = false }}
blocDecl: LBRACK champs = champ decls = list(declFonction) RBRACK { BlocDecl(champs, decls) }

bloc: LBRACK ld = list(decl) IS li = list(instruction) RBRACK { Bloc(ld, li) }
    | LBRACK li = list(instruction) RBRACK { Bloc([], li) }

instruction: e = expr SEMICOLON { Expr(e) }
          | b = bloc { InstBloc(b) }
          | IF e = expr THEN it = instruction ELSE ie = instruction { Ite(e, it, ie) }
          | g = expr ASSIGN d = expr SEMICOLON { Assign(g, d) }

expr: x = ID { Id(x) }
    | c = CSTE { Cste(c) }
    | c = CONST { CsteStr(c) }
    | e = delimited(LPAREN, expr, RPAREN) { e }
    //Appel de methode
    | cible = expr DOT methode = ID LPAREN arguments = separated_list(COMMA, expr) RPAREN { AppelFonction(cible, methode, arguments) }
    | cible = expr DOT attribut = ID { AccesAttribut(cible, attribut) }
    | LPAREN t = TYPE e = expr RPAREN { Cast(t, e) }
    | THIS { This }
    | SUPER { Super }
    | RESULT { Result }
    | g = expr PLUS d = expr { Plus(g, d) }
    | g = expr MINUS d = expr { Minus(g, d) }
    | g = expr TIMES d = expr { Times(g, d) }
    | g = expr DIV d = expr { Div(g, d) }
    | MINUS e = expr %prec UMINUS { UMinus e }
    | g = expr r = RELOP d = expr { Comp(g, r, d) }
    | g = expr AMP r = expr { Concat(g, r) }

classe: CLASS nom = TYPE args=delimited(LPAREN, paramDecl, RPAREN) IS corps = blocDecl {
  {
    name = nom;
    arguments = args;
    heriteFrom = "";
    argSuper = [];
    constructor = None;
    corps = corps;
  }
}

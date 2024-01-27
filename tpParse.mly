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
%token SUPER THIS OVERRIDE RESULT
%token DOT COMMA COLON SEMICOLON
%token AMP

%token IF THEN ELSE BEGIN END

/* utilise pour donner une precedence maximale au - unaire
* L'analyseur lexical ne renvoie jamais ce token !
*/
%token UMINUS
/*%token APPELFONC
%token ACCESATTR
*/
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

/*
constructorDecl:
  DEF nom = ID LPAREN params = paramDecl RPAREN IS corps = bloc
  {{ name = nom; arguments = params; override = false; returnType = ""; corps = corps; isStatic = false }}



blocDecl:
  LBRACK champs = champ decls = list(declFonction) RBRACK
  | LBRACK champs = champ decls = list(declFonction) c = constructorDecl RBRACK
  { BlocDecl(champs, decls, Some(c)) }
  | LBRACK champs = champ RBRACK
  { BlocDecl(champs, [], None) }

bloc:
  LBRACK ld = list(decl) IS li = list(instruction) RBRACK
  | LBRACK li = list(instruction) RBRACK
*/
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
    { List.map (fun name -> Champ(name, t, false)) n }
    |
    n = separated_list(COMMA, ID)
    COLON
    t = TYPE
    SEMICOLON
    { List.map (fun name -> Champ(name, t, false)) n }

declFonction:
  
  | DEF STATIC nom = ID LPAREN params = paramDecl RPAREN COLON returnType = TYPE IS corps = bloc
    {{ name = nom; arguments = params; override=false; returnType = returnType; corps = corps; isStatic = true }}
  | DEF OVERRIDE nom = ID LPAREN params = paramDecl RPAREN COLON returnType = TYPE IS corps = bloc
      {{ name = nom; arguments = params; override=true; returnType = returnType; corps = corps; isStatic = true }}
  | DEF OVERRIDE STATIC nom = ID LPAREN params = paramDecl RPAREN COLON returnType = TYPE IS corps = bloc
      {{ name = nom; arguments = params; override=true; returnType = returnType; corps = corps; isStatic = true }}

  | DEF nom = ID LPAREN params = paramDecl RPAREN COLON returnType = TYPE IS corps = bloc
    {{ name = nom; arguments = params;override=false; returnType = returnType; corps = corps; isStatic = false }}
  
  | DEF STATIC nom = ID LPAREN params = paramDecl RPAREN IS corps = bloc
    {{ name = nom; arguments = params; override=false; returnType = ""; corps = corps; isStatic = true }}
  | DEF OVERRIDE nom = ID LPAREN params = paramDecl RPAREN IS corps = bloc
    {{ name = nom; arguments = params; override=true; returnType = ""; corps = corps; isStatic = false }}
  | DEF nom = ID LPAREN params = paramDecl RPAREN IS corps = bloc
    {{ name = nom; arguments = params; override=false; returnType = ""; corps = corps; isStatic = false }}
  | DEF OVERRIDE STATIC nom = ID LPAREN params = paramDecl RPAREN IS corps = bloc
    {{ name = nom; arguments = params; override=true; returnType = ""; corps = corps; isStatic = false }}

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


/*
classe:
  CLASS nom = TYPE args = delimited(LPAREN, paramDecl, RPAREN) IS corps = blocDecl
  { { name = nom; arguments = args; heriteFrom = ""; argSuper = []; constructor = None; corps = corps; } }
  | CLASS nom = TYPE args = delimited(LPAREN, paramDecl, RPAREN) EXTENDS parent = TYPE IS corps = blocDecl
  { { name = nom; arguments = args; heriteFrom = parent; argSuper = []; constructor = None; corps = corps; } }
  | CLASS nom = TYPE args = delimited(LPAREN, paramDecl, RPAREN) EXTENDS parent = TYPE IS c = constructorDecl corps = blocDecl
  { { name = nom; arguments = args; heriteFrom = parent; argSuper = c.arguments; constructor = Some(c); corps = corps; } }
*/

type opComp = Eq | Neq | Lt | Le | Gt | Ge

type decl =
  | Decl of string list * string
  | Param of string * string
  | Champ of string * string * bool
  | ConstructorDecl of constructor_decl

and param = Param of string * string

and expType =
  | Id of string
  | Cste of int
  | CsteStr of string
  | This
  | Super
  | Result
  | Cast of string * expType
  | Plus of expType * expType
  | Minus of expType * expType
  | Times of expType * expType
  | Div of expType * expType
  | UMinus of expType
  | Comp of expType * opComp * expType
  | AppelFonction of expType * string * expType list
  | AccesAttribut of expType * string
  | Concat of expType * expType

and blocType = Bloc of decl list * instType list

and instType =
  | Ite of expType * instType * instType
  | InstBloc of blocType
  | Assign of expType * expType
  | Expr of expType

and foncType =
  {
    name: string;
    arguments: param list;
    override: bool;
    returnType: string;
    corps: blocType;
    isStatic: bool;
  }

and champType = Champ of string * string * bool

and blocDeclType = BlocDecl of champType list * foncType list

and constructor_decl = {
  name: string;
  arguments: param list;
  override: bool;
  returnType: string;
  corps: blocType;
  isStatic: bool;
}

and classeType =
  {
    name: string;
    arguments: param list;
    heriteFrom: string;
    argSuper: expType list;
    constructor: blocType option;
    corps: blocDeclType;
  }

and objType = {
  name: string;
  constructor: blocType option;
  corps: blocDeclType;
}

type declBegin =
  | ClasseDecl of classeType
  | ObjDecl of objType

type progType = Prog of declBegin list * blocType

exception VC_error of string
exception RUN_Error of string
exception MISC_Error of string
exception Decl_error of string
exception Internal_error of string



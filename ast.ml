type opComp = Eq | Neq | Lt | Le | Gt | Ge

type decl = Decl of string list * string

type param = Param of string * string

type expType =
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

type blocType = Bloc of decl list * instType list

and instType =
  | Ite of expType * instType * instType
  | InstBloc of blocType
  | Assign of expType * expType
  | Expr of expType
type foncType =
  {
    name: string;
    arguments: param list;
    override: bool;
    returnType: string;
    corps: blocType;
    isStatic: bool;
  }

type champType = Champ of string * string * bool  

type blocDeclType = BlocDecl of champType list * foncType list

type classeType =
  {
    name: string;
    arguments: param list;
    heriteFrom: string;
    argSuper: expType list;
    constructor: blocType option;
    corps: blocDeclType;
  }


type declBegin =
  | ClasseDecl of classeType
  

type progType = Prog of declBegin list * blocType
exception VC_error of string
exception RUN_Error of string
exception MISC_Error of string
exception Decl_error of string
exception Internal_error of string


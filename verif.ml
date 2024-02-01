open Ast

 

(********************************** FONCTIONS AUXILIAIRES POUR LES VERIFICATIONS CONTEXTUELLES ***********************************)

(********* POUR LES ERREURS *********)


let affiche_erreur (msg : string) : 'a =
  Printf.printf "Erreur: %s\n" msg;;


let classe_definie_plusieurs_fois (classe : classeType) : 'a =
  affiche_erreur (Printf.sprintf "La classe '%s' est définie au moins deux fois, les autres définitions ne sont donc pas ajoutés à l'environnement!" classe.name);;


let classe_dont_type_incorrect (classe : classeType) (nomType: string) (mauvaisType: string) : 'a =
  affiche_erreur (Printf.sprintf "La classe '%s' possède le paramètre '%s' dont le type '%s' n'a pas été définie !" classe.name nomType mauvaisType);;


let classe_herite_classe_predefinie (classe : classeType) : 'a =
  affiche_erreur (Printf.sprintf "La classe '%s' hérite de la classe '%s' alors qu'elle est prédéfinie!" classe.name classe.heriteFrom);;


let classe_herite_classe_non_definie (classe : classeType) : 'a =
  affiche_erreur (Printf.sprintf "La classe '%s' hérite de la classe '%s' qui n'a pas été définie" classe.name classe.heriteFrom);;


let classe_dont_la_methode_a_type_incorrect (nomClasse: string) (methode: foncType) (nomType: string) (mauvaisType: string) =
  affiche_erreur (Printf.sprintf "La méthode '%s' de la classe '%s' a le paramètre '%s' dont le type '%s' n'a pas été définie !" methode.name nomClasse nomType mauvaisType);;


let bloc_definition_multiple_de_variables (nomVariable: string) =
  affiche_erreur (Printf.sprintf "Vous avez défini au moins deux fois la variable '%s'!" nomVariable);;

let bloc_type_variable_invalide (nomType: string) =
  affiche_erreur (Printf.sprintf "Vous avez donné le type '%s' à certaine variables du bloc, ce type n'est pas définie!" nomType);;


(********* POUR LES CLASSES *********)


let rec filtrer_declBegin_vers_ClasseDecl (listeDecl : declBegin list) : classeType list =
  match listeDecl with
  | [] -> [] (* La liste est vide, renvoyer une liste vide *)
  | ClasseDecl c :: reste -> c :: filtrer_declBegin_vers_ClasseDecl reste;; (* Si c'est une classe, ajouter à la liste et continuer avec le reste *)


(* Les paramètres des classes doivent etre des types qui SONT DEJA PRESENTS dans l'environnement !!*)
let verifier_si_param_classe_dans_environnement (classeAVerifier: classeType) env =
  List.iter (
    fun param -> (
      match param with
      | Param(nomType , sonType) ->
        if sonType = classeAVerifier.name || not (Hashtbl.mem env sonType) && sonType <> "String" && sonType <> "Integer" then
          classe_dont_type_incorrect classeAVerifier nomType sonType;
    )
  ) classeAVerifier.arguments;;


(* Les paramètres des classes doivent etre des types qui SONT DEJA PRESENTS dans l'environnement !!*)
(*let verifier_coherence_liste_parametre (classeAVerifier: classeType)  env =
  Obtenir le constrcuteur et la liste de ses parametre*)

let verifier_si_heritage_correct (classeAVerifier: classeType) env =
  (* Héritage de classes définies MAIS PAS PREDEFINIES*)
  if classeAVerifier.heriteFrom = "Integer" || classeAVerifier.heriteFrom = "String" then
    classe_herite_classe_predefinie(classeAVerifier)
  else if not (Hashtbl.mem env classeAVerifier.heriteFrom) && classeAVerifier.heriteFrom <> "" then
    classe_herite_classe_non_definie(classeAVerifier);;

  (* Vérification du problème du diamant, TODO: demander une grammaire avec un héritage multiple*)
  (* TODO: Voir le CDG, partie aspects contextuelles*)

let verifier_si_param_methode_dans_environnement (nomClasse: string) (methodeAVerifier: foncType) env =
    List.iter(
    fun param -> (
      match param with
      | Param(nomType , sonType) ->
        if not (Hashtbl.mem env sonType) && sonType <> "String" && sonType <> "Integer" then
          classe_dont_la_methode_a_type_incorrect nomClasse methodeAVerifier nomType sonType;
      )
    )methodeAVerifier.arguments;;


let verifier_methode (classe: classeType) (methodeAVerifier: foncType) env =
  verifier_si_param_methode_dans_environnement classe.name methodeAVerifier env;;


let verifier_corps_classe (classeAVerifier: classeType) env =
  (* TODO: attribut *)
  (* TODO: methode *)
  match classeAVerifier with
  | { corps = BlocDecl (listeChamps, listeMethodes); _ } -> List.iter( fun methode -> verifier_methode classeAVerifier methode env )listeMethodes;;



let verifier_classe (classeAVerifier: classeType) env =
  verifier_corps_classe classeAVerifier env;
  verifier_si_param_classe_dans_environnement classeAVerifier env;
  if classeAVerifier.heriteFrom <> "" then
    (*constructeur*)
    print_string ""; (*Indompréhensible, enlever cette ligne fais que l'on ne passe jamais à l'instruction verifier_si_heritage_correct *)
    verifier_si_heritage_correct classeAVerifier env;;
      (*héritage*)
  (*corps classe*)
 

(**** CLASSES PREDEFINIES ****)

(**** INTEGER

let definir_classe_interger (): classeType =
  let toString = {
    name = "toString";
    arguments = [];
    override = false;
    returnType = "string";
    corps = InstBloc (Bloc ([], [Expr (Cste 0)]));
    isStatic = false;
  } in
  let constructeur = {
    (*BlocType Option, TODO: le constructeur est il une méthode comme une auture ????*)
    name = "Integer";
    arguments = [];
    override = false;
    returnType = "";  (*constructeur ne renvoir rien*)
    corps = Bloc ([], [Expr (Cste 0)]);
    isStatic = true;
  }
  in
  let classeInteger = {
    name = "Integer";
    arguments = [];
    heriteFrom = "";
    argSuper = [];
    constructor = Some constructeur;
    corps = BlocDecl ([], [toString]); (* Ajout de la méthode toString dans le corps *)
  }
  classeInteger;


let definir_classe_string (): classeType =
  let print = {
    name = "print";
    arguments = [];
    override = false;
    returnType = "string";
    corps = InstBloc (Bloc ([], [Expr (Cste 0)]));
    isStatic = false;
  } in
  let println = {
    name = "println";
    arguments = [];
    override = false;
    returnType = "string";
    corps = InstBloc (Bloc ([], [Expr (Cste 0)]));
    isStatic = false;
  } in
  let constructeur = {
    name = "String";
    arguments = [];
    override = false;
    returnType = "String";
    corps = InstBloc (Bloc ([], [Expr (Cste 0)])); (* A chaque fois, on prend une constante 0 comme corps *)
    isStatic = true;
  } in
  let classeString = {
    name = "String";
    arguments = [];
    heriteFrom = "";
    argSuper = [];
    constructor = Some constructeur;
    corps = BlocDecl ([], [print; println]);
  } in
  classeString;
*)

let ajouter_classe_predefinie env (classe_predefinie: classeType) =
  Hashtbl.add env classe_predefinie.name classe_predefinie;;

(*TODO: lFAIRE LA MEME CHOSE AVEC LA CLASSE STRING *)


(*
let get_parent (classe: classeType): (* définir le type de retour ... Suis-je capable d'aller chercher dans mon dico la classe réelle*).
let fille_genere_pb_diamant (classeMere: classeType) (classFille: classeType): bool =


let verifier_parametre_identique_pour_deux_classes (classe1: classeType) (classe2: classeType): bool =
  (* TODO: Vérifier que les deux classes ont exactement les memes paramètres *)


let est_enfant (classeMere: classeType) (classeFille: classeType): bool =
  (* TODO: Définir les raisons qui font de vous un enfant, Constructeur "inclus" celui de la classe Parente,   *)
*)

(********* POUR LE BLOC PRINCIPAL *********)
(* Fonction pour ajouter les clés d'un dictionnaire à un autre *)
let dico_recupere_cle_autre_dico dico_orig dico_dest =
  List.fold_left (fun acc (cle, _) -> (cle, "") :: acc) dico_dest dico_orig;;


let verifier_declaration decl (envNomVariable : (string, string) Hashtbl.t) =
  match decl with
  | Decl (lvariables, type_decl) ->
    (* Vérifier chaque variable *)
    List.iter (fun variable ->
      if Hashtbl.mem envNomVariable variable then
        (* La variable est déjà dans l'environnement *)
        bloc_definition_multiple_de_variables(variable)
      else
        (* Ajouter la variable à l'environnement *)
        Hashtbl.add envNomVariable variable type_decl;
    ) lvariables;

    (* Vérifier le type *)
    if not (Hashtbl.mem envNomVariable type_decl) then
      (* Le type n'est pas présent dans l'environnement *)
      bloc_type_variable_invalide type_decl;;


let verifier_bloc (blocAVeirfier: blocType) (envNomVariable : (string, string) Hashtbl.t) =
  (* MEME ESPACE*)
  match blocAVeirfier with
  | Bloc(declList, instList) ->
    List.iter(fun decl -> verifier_declaration decl envNomVariable) declList;;
    (*TODO: List.iter (fun instr -> verifier_instruction instr envNomVariable) instList;; => Donc besoin récupérer type...*)


(********************************** FONCTIONS GENERALES POUR LES VERIFICATIONS CONTEXTUELLES ***********************************)


let initialiser_env (listeDeclClasse : classeType list) =
  let env = Hashtbl.create (2 + List.length listeDeclClasse) in (* Les 2 classes prédéfinies*)
  (* TODO: Voir pourquoi décommenté le code génére des erreurs syntaxiques*)
  (*
  ajouter_classe_predefinie env (definir_classe_integer ());
  ajouter_classe_predefinie env (definir_classe_string ());
  *)

  List.iter (fun c ->
    match c with
    | c when Hashtbl.mem env c.name -> classe_definie_plusieurs_fois(c)
    | c -> Hashtbl.add env c.name c;(* La classe n'est pas encore définie. *)
  ) listeDeclClasse;
  env;;


(*
  Constitution du programme principal: declaration Classe(s) + bloc (Programme principal)
  => On propose donc une fonction de vérification pour ces deux parties
  => BUT: Constuire un environnment cohérent qui respecte le CDG ...
*)

let verifier_coherence_code (programmeAVerifier : progType) =
  match programmeAVerifier with
  | Prog(ld, b) ->
    print_string ">>> VERIFICATION DECLARATION DES CLASSES\n";
    let listDeclClasse = filtrer_declBegin_vers_ClasseDecl ld in
    let env = initialiser_env listDeclClasse in
    Hashtbl.iter (fun _ classeAVerifier -> verifier_classe classeAVerifier env;) env;

    print_string "\n\n>>> VERIFICATION DU BLOC\n";

    let envNomVariable = Hashtbl.create (Hashtbl.length env) in
    Hashtbl.iter (fun cle valeur -> Hashtbl.add envNomVariable cle "") env;
    Hashtbl.add envNomVariable "Integer" "";
    Hashtbl.add envNomVariable "String" "";

    verifier_bloc b envNomVariable;
   
  env;



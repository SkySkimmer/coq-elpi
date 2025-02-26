(* Generates correctness proofs for comparison functions generated by derive.eq.

   license: GNU Lesser General Public License Version 2.1 or later           
   ------------------------------------------------------------------------- *)

From elpi.apps.derive.elpi Extra Dependency "eqcorrect.elpi" as eqcorrect.
From elpi.apps.derive.elpi Extra Dependency "derive_hook.elpi" as derive_hook.
From elpi.apps.derive.elpi Extra Dependency "derive_synterp_hook.elpi" as derive_synterp_hook.
  
From elpi Require Import elpi.
From elpi.apps Require Import derive.
From elpi.apps Require Import  derive.eq derive.induction derive.eqK derive.param1.

From elpi.core Require Import ssreflect.

From elpi.core Require PrimInt63 Uint63Axioms.

Lemma uint63_eq_correct i : is_uint63 i -> eq_axiom_at PrimInt63.int PrimInt63.eqb i.
Proof.
move=> _ j; have [] : (PrimInt63.eqb i j) = true <-> i = j.
  split; first exact: Uint63Axioms.eqb_correct.
  by move=> ->; rewrite Uint63Axioms.eqb_refl.
by case: PrimInt63.eqb => [-> // _| _ abs]; constructor=> // /abs.
Qed.
Register uint63_eq_correct as elpi.derive.uint63_eq_correct.

From elpi.core Require PrimString PrimStringAxioms.

Lemma pstring_eq_correct i : is_pstring i -> eq_axiom_at PrimString.string PrimString.eqb i.
Proof.
  move=> _ j; have [] : (PrimString.eqb i j) = true <-> i = j.
  rewrite /PrimString.eqb; have := PrimStringAxioms.compare_ok i j.
   case: PrimString.compare => - [c r] //; split => //; [move=> _| by move=>/r ..].
   by apply: c.
by case: PrimString.eqb => [-> // _| _ abs]; constructor=> // /abs.
Qed.
Register pstring_eq_correct as elpi.derive.pstring_eq_correct.

Elpi Db derive.eqcorrect.db lp:{{
  type eqcorrect-db gref -> term -> prop.
}}.
#[superglobal] Elpi Accumulate derive.eqcorrect.db File derive.lib.
#[superglobal] Elpi Accumulate derive.eqcorrect.db lp:{{
  
eqcorrect-db {{:gref lib:num.int63.type }} {{ lib:elpi.derive.uint63_eq_correct }} :- !.
eqcorrect-db {{:gref lib:elpi.pstring }} {{ lib:elpi.derive.pstring_eq_correct }} :- !.
eqcorrect-db X _ :- {{ lib:num.float.type }} = global X, !, stop "float64 comparison is not syntactic".

:name "eqcorrect-db:fail"
eqcorrect-db T _ :-
  M is "derive.eqcorrect: can't find the correctness proof for the comparison function on " ^ {coq.gref->string T},
  stop M.

}}.

(* standalone *)
Elpi Command derive.eqcorrect.
Elpi Accumulate Db derive.param1.db. (* TODO: understand which other db needs this *)
Elpi Accumulate Db derive.induction.db.
Elpi Accumulate Db derive.param1.functor.db.
Elpi Accumulate Db derive.eq.db.
Elpi Accumulate Db derive.eqK.db.
Elpi Accumulate Db derive.eqcorrect.db.
Elpi Accumulate File eqcorrect.
Elpi Accumulate lp:{{
  main [str I, str Name] :- !, coq.locate I (indt GR), derive.eqcorrect.main GR Name _.
  main [str I] :- !, coq.locate I (indt GR), coq.gref->id (indt GR) ID, Name is ID ^ "_eq_correct", derive.eqcorrect.main GR Name _.
  main _ :- usage.

  usage :- coq.error "Usage: derive.eqcorrect <inductive type name> [<suffix>]".
}}.


(* hook into derive *)
Elpi Accumulate derive File derive_hook.
Elpi Accumulate derive File eqcorrect.
Elpi Accumulate derive Db derive.eqcorrect.db.

#[phases="both"] Elpi Accumulate derive lp:{{
dep1 "eqcorrect" "induction".
dep1 "eqcorrect" "eq".
dep1 "eqcorrect" "eqK".
}}.

#[synterp] Elpi Accumulate derive lp:{{
  derivation _ _ (derive "eqcorrect" (cl\ cl = []) true).
}}.

Elpi Accumulate derive lp:{{

derivation (indt T) Prefix ff (derive "eqcorrect" (derive.eqcorrect.main T N) (eqcorrect-db (indt T) _)) :- N is Prefix ^ "eq_correct".

}}.

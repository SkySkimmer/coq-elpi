From elpi.apps Require Import eltac.rewrite.

Goal (forall x : nat, 1 + x = x + 1) -> 
    forall y,  2 * ((y+y) + 1) = ((y + y)+1) * 2.
Proof.
    intro H. 
    intro x.
    elpi rewrite (H).
    elpi rewrite (PeanoNat.Nat.mul_comm).
    exact eq_refl.
Defined.

Section Example_rewrite.
Variable A : Type.
Variable B : A -> Type.
Variable C : forall (a : A) (b : B a), Type.
Variable add : forall {a : A} {b : B a}, C a b -> C a b -> C a b.
Variable sym : forall {a : A} {b : B a} (c c' : C a b), add c c' = add c' c.

Goal forall (a : A) (b : B a) (x y : C a b),
    add x y = add y x /\ add x y = add y x.
Proof.
    intros a b x y.
    elpi rewrite (@sym). (* @sym is a gref *)
    (** [add y x = add y x /\ add y x = add y x] *)
    easy.
Defined.

Goal forall (a : A) (b : B a) (x y : C a b),
    add x y = add y x /\ add x y = add y x.
Proof.
    intros a b x y.
    elpi rewrite (sym). (* because of implicit arguments, this is sym _ _, which is a term *)
    easy.
Defined.

End Example_rewrite.

{-# OPTIONS --safe --cubical #-}

{-
  Definition of neutral forms, used to define both values and normal forms.
-}

module Normalisation.NeutralForms where

open import Syntax.Terms
open import Normalisation.TermLike
open import Normalisation.Variables


-- Neutral forms : a variable applied to terms satisfying P.
-- This is used both for values and normal forms, hence the general definition.
data Ne (X : Tm-like) : Tm-like where
  var : {Γ : Con} {A : Ty} → Var Γ A → Ne X Γ A
  app : {Γ : Con} {A B : Ty} → Ne X Γ (A ⟶ B) → X Γ A → Ne X Γ B

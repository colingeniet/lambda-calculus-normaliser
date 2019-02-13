{-# OPTIONS --cubical #-}

module Syntax.Terms where

open import Equality
open import Syntax.Types

---- Terms Definition.

{- The definition of terms and substitution can not be made with mutually
   inductive types because of constructor dependencies (path constructors
   need to have all regular constructor in scope, which just does not work)
   Making it a simple inductive type with complex indexing solves the problem,
   and with appropriate definitions, it is no harder to use.
-}

data term-index : Set where
  Tm-i : Con → Ty → term-index
  Tms-i : Con → Con → term-index
  
data term : term-index → Set

Tm : Con → Ty → Set
Tm Γ A = term (Tm-i Γ A)
Tms : Con → Con → Set
Tms Γ Δ = term (Tms-i Γ Δ)

infixr 10 _,_
infixr 20 _∘_
infixl 30 _[_]

data term where
  -- Terms.
  _[_] : {Γ Δ : Con} {A : Ty} → Tm Δ A → Tms Γ Δ → Tm Γ A
  π₂ : {Γ Δ : Con} {A : Ty} → Tms Γ (Δ , A) → Tm Γ A
  lam : {Γ : Con} {A B : Ty} → Tm (Γ , A) B → Tm Γ (A ⟶ B)
  app : {Γ : Con} {A B : Ty} → Tm Γ (A ⟶ B) → Tm (Γ , A) B
  -- Substitutions.
  id : {Γ : Con} → Tms Γ Γ
  _∘_ : {Γ Δ Θ : Con} → Tms Δ Θ → Tms Γ Δ → Tms Γ Θ
  ε : {Γ : Con} → Tms Γ ●
  _,_ : {Γ Δ : Con} {A : Ty} → Tms Γ Δ → Tm Γ A → Tms Γ (Δ , A)
  π₁ : {Γ Δ : Con} {A : Ty} → Tms Γ (Δ , A) → Tms Γ Δ
  -- Substitutions laws.
  id∘ : {Γ Δ : Con} {σ : Tms Γ Δ} → id ∘ σ ≡ σ
  ∘id : {Γ Δ : Con} {σ : Tms Γ Δ} → σ ∘ id ≡ σ
  ∘∘ : {Γ Δ Θ Ψ : Con} {σ : Tms Θ Ψ} {ν : Tms Δ Θ} {δ : Tms Γ Δ} →
       (σ ∘ ν) ∘ δ ≡ σ ∘ (ν ∘ δ)
  εη : {Γ : Con} {σ : Tms Γ ●} → σ ≡ ε
  π₁β : {Γ Δ : Con} {A : Ty} {σ : Tms Γ Δ} {u : Tm Γ A} → π₁ (σ , u) ≡ σ
  π₂β : {Γ Δ : Con} {A : Ty} {σ : Tms Γ Δ} {u : Tm Γ A} → π₂ (σ , u) ≡ u
  πη : {Γ Δ : Con} {A : Ty} {σ : Tms Γ (Δ , A)} → (π₁ σ , π₂ σ) ≡ σ
  β : {Γ : Con} {A B : Ty} {u : Tm (Γ , A) B} → app (lam u) ≡ u
  η : {Γ : Con} {A B : Ty} {f : Tm Γ (A ⟶ B)} → lam (app f) ≡ f
  lam[] : {Γ Δ : Con} {A B : Ty} {u : Tm (Δ , A) B} {σ : Tms Γ Δ} →
          (lam u) [ σ ] ≡ lam (u [ σ ∘ (π₁ id) , π₂ id ])
  ,∘ : {Γ Δ Θ : Con} {A : Ty} {σ : Tms Δ Θ} {ν : Tms Γ Δ} {u : Tm Δ A} →
       (σ , u) ∘ ν ≡ σ ∘ ν , u [ ν ]


---- Additional Constructions.

-- Weakening substitution.
wk : {Γ : Con} {A : Ty} → Tms (Γ , A) Γ
wk = π₁ id

-- Variables (De Brujin indices).
vz : {Γ : Con} {A : Ty} → Tm (Γ , A) A
vz = π₂ id
vs : {Γ : Con} {A B : Ty} → Tm Γ A → Tm (Γ , B) A
vs u = u [ wk ]

-- Weakening of terms, substitutions.
_+_ : {Γ : Con} {B : Ty} → Tm Γ B → (A : Ty) → Tm (Γ , A) B
u + A = u [ wk ]

_+s_ : {Γ Δ : Con} → Tms Γ Δ → (A : Ty) → Tms (Γ , A) Δ
σ +s A = σ ∘ wk

-- Context extension and corresponding weakenings.
_++_ : Con → Con → Con
Γ ++ ● = Γ
Γ ++ (Δ , A) = (Γ ++ Δ) , A

_++t_ : {Γ : Con} {A : Ty} → Tm Γ A → (Δ : Con) → Tm (Γ ++ Δ) A
u ++t ● = u
u ++t (Δ , A) = (u ++t Δ) + A

_++s_ : {Γ Δ : Con} → Tms Γ Δ → (Θ : Con) → Tms (Γ ++ Θ) Δ
σ ++s ● = σ
σ ++s (Θ , A) = (σ ++s Θ) +s A

-- Lifting of a substitution by a type.
_↑_ : {Γ Δ : Con} → Tms Γ Δ → (A : Ty) → Tms (Γ , A) (Δ , A)
σ ↑ A = σ ∘ wk , vz

↑id : {Γ : Con} {A : Ty} → _↑_ {Γ = Γ} id A ≡ id
↑id = ap (λ σ → σ , vz) id∘ ∙ πη

-- Lifting by a context.
_↑↑_ : {Γ Δ : Con} → Tms Γ Δ → (Θ : Con) → Tms (Γ ++ Θ) (Δ ++ Θ)
σ ↑↑ ● = σ
σ ↑↑ (Θ , A) = (σ ↑↑ Θ) ↑ A

-- Regular application.
<_> : {Γ : Con} {A : Ty} → Tm Γ A → Tms Γ (Γ , A)
< u > = id , u

infixl 10 _$_
_$_ : {Γ : Con} {A B : Ty} → Tm Γ (A ⟶ B) → Tm Γ A → Tm Γ B
f $ u = (app f) [ < u > ]
------------------------------------------------------------------------
-- The Agda standard library
--
-- Properties of the extensional sublist relation over setoid equality.
------------------------------------------------------------------------

{-# OPTIONS --without-K --safe #-}

open import Relation.Binary hiding (Decidable)

module Data.List.Relation.Binary.Subset.Setoid.Properties where

open import Data.Bool.Base using (Bool; true; false)
open import Data.List.Base
open import Data.List.Relation.Unary.Any as Any using (Any; here; there)
open import Data.List.Relation.Unary.All as All using (All)
import Data.List.Membership.Setoid as Membership
open import Data.List.Membership.Setoid.Properties
import Data.List.Relation.Binary.Subset.Setoid as Sublist
import Data.List.Relation.Binary.Equality.Setoid as Equality
import Data.List.Relation.Binary.Permutation.Setoid as Permutation
import Data.List.Relation.Binary.Permutation.Setoid.Properties as Permutationₚ
open import Data.Product using (_,_)
open import Function.Base using (_∘_; _∘₂_)
open import Level using (Level)
open import Relation.Nullary using (¬_; does)
open import Relation.Unary using (Pred; Decidable)
import Relation.Binary.Reasoning.Preorder as PreorderReasoning

open Setoid using (Carrier)

private
  variable
    a p ℓ : Level

------------------------------------------------------------------------
-- Relational properties with _≋_ (pointwise equality)
------------------------------------------------------------------------

module _ (S : Setoid a ℓ) where

  open Sublist S
  open Equality S
  open Membership S

  ⊆-reflexive : _≋_ ⇒ _⊆_
  ⊆-reflexive xs≋ys = ∈-resp-≋ S xs≋ys

  ⊆-refl : Reflexive _⊆_
  ⊆-refl x∈xs = x∈xs

  ⊆-trans : Transitive _⊆_
  ⊆-trans xs⊆ys ys⊆zs x∈xs = ys⊆zs (xs⊆ys x∈xs)

  ⊆-respʳ-≋ : _⊆_ Respectsʳ _≋_
  ⊆-respʳ-≋ xs≋ys = ∈-resp-≋ S xs≋ys ∘_

  ⊆-respˡ-≋ : _⊆_ Respectsˡ _≋_
  ⊆-respˡ-≋ xs≋ys = _∘ ∈-resp-≋ S (≋-sym xs≋ys)

  ⊆-isPreorder : IsPreorder _≋_ _⊆_
  ⊆-isPreorder = record
    { isEquivalence = ≋-isEquivalence
    ; reflexive     = ⊆-reflexive
    ; trans         = ⊆-trans
    }

  ⊆-preorder : Preorder _ _ _
  ⊆-preorder = record
    { isPreorder = ⊆-isPreorder
    }

------------------------------------------------------------------------
-- Relational properties with _↭_ (permutations)
------------------------------------------------------------------------

module _ (S : Setoid a ℓ) where

  open Sublist S
  open Permutation S
  open Membership S

  ↭⇒⊆ : _↭_ ⇒ _⊆_
  ↭⇒⊆ xs↭ys = Permutationₚ.∈-resp-↭ S xs↭ys

  ⊆-respʳ-↭ : _⊆_ Respectsʳ _↭_
  ⊆-respʳ-↭ xs↭ys = Permutationₚ.∈-resp-↭ S xs↭ys ∘_

  ⊆-respˡ-↭ : _⊆_ Respectsˡ _↭_
  ⊆-respˡ-↭ xs↭ys = _∘ Permutationₚ.∈-resp-↭ S (↭-sym xs↭ys)

  ⊆-↭-isPreorder : IsPreorder _↭_ _⊆_
  ⊆-↭-isPreorder = record
    { isEquivalence = ↭-isEquivalence
    ; reflexive     = ↭⇒⊆
    ; trans         = ⊆-trans S
    }

  ⊆-↭-preorder : Preorder _ _ _
  ⊆-↭-preorder = record
    { isPreorder = ⊆-↭-isPreorder
    }

------------------------------------------------------------------------
-- Reasoning over subsets
------------------------------------------------------------------------

module ⊆-Reasoning (S : Setoid a ℓ) where

  open Setoid S renaming (Carrier to A)
  open Sublist S
  open Membership S

  private
    module Base = PreorderReasoning (⊆-preorder S)

  open Base public
    hiding (step-∼; step-≈; step-≈˘)
    renaming (_≈⟨⟩_ to _≋⟨⟩_)

  infixr 2 step-⊆ step-≋ step-≋˘
  infix 1 step-∈

  step-∈ : ∀ x {xs ys} → xs IsRelatedTo ys → x ∈ xs → x ∈ ys
  step-∈ x xs⊆ys x∈xs = (begin xs⊆ys) x∈xs

  step-⊆  = Base.step-∼
  step-≋  = Base.step-≈
  step-≋˘ = Base.step-≈˘

  syntax step-∈  x  xs⊆ys x∈xs  = x  ∈⟨  x∈xs  ⟩ xs⊆ys
  syntax step-⊆  xs ys⊆zs xs⊆ys = xs ⊆⟨  xs⊆ys ⟩ ys⊆zs
  syntax step-≋  xs ys⊆zs xs≋ys = xs ≋⟨  xs≋ys ⟩ ys⊆zs
  syntax step-≋˘ xs ys⊆zs xs≋ys = xs ≋˘⟨ xs≋ys ⟩ ys⊆zs

------------------------------------------------------------------------
-- Relationship with predicates
------------------------------------------------------------------------

module _ (S : Setoid a ℓ) where

  open Setoid S renaming (Carrier to A)
  open Sublist S
  open Membership S

  Any-resp-⊆ : ∀ {P : Pred A p} → P Respects _≈_ → (Any P) Respects _⊆_
  Any-resp-⊆ resp ⊆ pxs with find pxs
  ... | (x , x∈xs , px) = lose resp (⊆ x∈xs) px

  All-resp-⊇ : ∀ {P : Pred A p} → P Respects _≈_ → (All P) Respects _⊇_
  All-resp-⊇ resp ⊇ pxs = All.tabulateₛ S (All.lookupₛ S resp pxs ∘ ⊇)

------------------------------------------------------------------------
-- Properties of list functions
------------------------------------------------------------------------
-- ++

module _ (S : Setoid a ℓ) where

  open Sublist S
  open Membership S

  xs⊆xs++ys : ∀ xs ys → xs ⊆ xs ++ ys
  xs⊆xs++ys xs ys = ∈-++⁺ˡ S

  xs⊆ys++xs : ∀ xs ys → xs ⊆ ys ++ xs
  xs⊆ys++xs xs ys = ∈-++⁺ʳ S _

  ++⁺ʳ : ∀ {xs ys} zs → xs ⊆ ys → zs ++ xs ⊆ zs ++ ys
  ++⁺ʳ []       xs⊆ys           = xs⊆ys
  ++⁺ʳ (x ∷ zs) xs⊆ys (here p)  = here p
  ++⁺ʳ (x ∷ zs) xs⊆ys (there p) = there (++⁺ʳ zs xs⊆ys p)

  ++⁺ˡ : ∀ {xs ys} zs → xs ⊆ ys → xs ++ zs ⊆ ys ++ zs
  ++⁺ˡ {[]}     {ys} zs xs⊆ys           = xs⊆ys++xs zs ys
  ++⁺ˡ {x ∷ xs} {ys} zs xs⊆ys (here  p) = xs⊆xs++ys ys zs (xs⊆ys (here p))
  ++⁺ˡ {x ∷ xs} {ys} zs xs⊆ys (there p) = ++⁺ˡ zs (xs⊆ys ∘ there) p

  ++⁺ : ∀ {ws xs ys zs} → ws ⊆ xs → ys ⊆ zs → ws ++ ys ⊆ xs ++ zs
  ++⁺ ws⊆xs ys⊆zs = ⊆-trans S (++⁺ˡ _ ws⊆xs) (++⁺ʳ _ ys⊆zs)

------------------------------------------------------------------------
-- filter

module _ (S : Setoid a ℓ) {P : Pred (Carrier S) p} (P? : Decidable P) where

  open Sublist S

  filter-⊆ : ∀ xs → filter P? xs ⊆ xs
  filter-⊆ (x ∷ xs) y∈f[x∷xs] with does (P? x)
  ... | false = there (filter-⊆ xs y∈f[x∷xs])
  ... | true  with y∈f[x∷xs]
  ...   | here  y≈x     = here y≈x
  ...   | there y∈f[xs] = there (filter-⊆ xs y∈f[xs])



------------------------------------------------------------------------
-- DEPRECATED
------------------------------------------------------------------------

-- Version 1.5

filter⁺ = filter-⊆
{-# WARNING_ON_USAGE filter⁺
"Warning: filter⁺ was deprecated in v1.5.
Please use filter-⊆ instead."
#-}

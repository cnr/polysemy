{-# LANGUAGE DataKinds            #-}
{-# LANGUAGE PolyKinds            #-}
{-# LANGUAGE TypeFamilies         #-}
{-# LANGUAGE TypeOperators        #-}
{-# LANGUAGE UndecidableInstances #-}

module Definitive.Union.TypeErrors
  ( AmbiguousSend
  , Break
  ) where

import Data.Kind
import GHC.TypeLits


data T1 m a

type family Break (c :: Constraint)
                  (rep :: (* -> *) -> * -> *) :: Constraint where
  Break _ T1 = ((), ())
  Break _ c  = ()


type AmbigousEffectMessage r e t vs =
        ( 'Text "Ambiguous use of effect '"
    ':<>: 'ShowType e
    ':<>: 'Text "'"
    ':$$: 'Text "Possible fix:"
    ':$$: 'Text "  add 'Member ("
    ':<>: 'ShowType t
    ':<>: 'Text ") "
    ':<>: 'ShowType r
    ':<>: 'Text "' to the context of "
    ':$$: 'Text "    the type signature"
    ':$$: 'Text "If you already have the constraint you want,"
    ':$$: 'Text "  instead add a type application to specify"
    ':$$: 'Text "    "
    ':<>: PrettyPrint vs
    ':<>: 'Text " directly"
        )

type family PrettyPrint (vs :: [k]) where
  PrettyPrint '[a] =
    'Text "'" ':<>: 'ShowType a ':<>: 'Text "'"
  PrettyPrint '[a, b] =
    'Text "'" ':<>: 'ShowType a ':<>: 'Text "', and "
    ':<>:
    'Text "'" ':<>: 'ShowType b ':<>: 'Text "'"
  PrettyPrint (a ': vs) =
    'Text "'" ':<>: 'ShowType a ':<>: 'Text "', "
    ':<>: PrettyPrint vs


type family AmbiguousSend r e where
  AmbiguousSend r (e a b c d f) =
    TypeError (AmbigousEffectMessage r e (e a b c d f) '[a, b c d f])

  AmbiguousSend r (e a b c d) =
    TypeError (AmbigousEffectMessage r e (e a b c d) '[a, b c d])

  AmbiguousSend r (e a b c) =
    TypeError (AmbigousEffectMessage r e (e a b c) '[a, b c])

  AmbiguousSend r (e a b) =
    TypeError (AmbigousEffectMessage r e (e a b) '[a, b])

  AmbiguousSend r (e a) =
    TypeError (AmbigousEffectMessage r e (e a) '[a])

  AmbiguousSend r e =
    TypeError
        ( 'Text "Could not deduce: (Member "
    ':<>: 'ShowType e
    ':<>: 'Text " "
    ':<>: 'ShowType r
    ':<>: 'Text ") "
    ':$$: 'Text "Fix:"
    ':$$: 'Text "  add (Member "
    ':<>: 'ShowType e
    ':<>: 'Text " "
    ':<>: 'ShowType r
    ':<>: 'Text ") to the context of"
    ':$$: 'Text "    the type signature"
        )

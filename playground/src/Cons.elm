-- Cons operator ::
-- Basically prepends to a List


module Cons exposing (prepend)

-- prepend [1, 23, 22] 10
-- [10, 1, 23, 22]


prepend : List a -> a -> List a
prepend list x =
    x :: list

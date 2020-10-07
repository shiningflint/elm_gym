module Playground exposing
  ( doubleScores
  , Shape(..)
  , Banana
  , surfaceShape
  , circumferenceShape
  , shapeName
  )

scoreMultiplier = 2

doubleScores : List number -> List number
doubleScores scores =
  List.map (\x -> x * scoreMultiplier) scores

type alias Banana = { name : String, size : Int }

type Shape
  = Circle Float
  | Rectangle Float
  | FruitDetail Banana

shapeName : Shape -> String
shapeName s =
  case s of
    FruitDetail b ->
      b.name
    _ -> ""

surfaceShape : Shape -> Float
surfaceShape s =
  case s of
    Circle c ->
      3.14 * c ^ 2
    Rectangle c ->
      c * c
    _ -> 0

circumferenceShape s =
  case s of
    Circle c ->
      2 * 3.14 * c
    Rectangle c ->
      c * 4
    _ -> 0

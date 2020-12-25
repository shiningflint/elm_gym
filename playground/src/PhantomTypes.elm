module PhantomTypes exposing
    ( Length
    , add
    , addPhantom
    , newLengthCm
    , newLengthIn
    ,  newLengthPhantomCm
       -- , newLengthPhantomIn

    )


type Cm
    = Cm


type In
    = In


type Length units
    = Length Float units


add : Length units -> Length units -> Length units
add (Length a unit1) (Length b unit2) =
    Length (a + b) unit1



-- Phantom Mode below. Does the same thing as above
-- Phantom type, you still have units but nothing in the constructor
-- 👻


type LengthPhantom units
    = LengthPhantom Float


addPhantom : LengthPhantom units -> LengthPhantom units -> LengthPhantom units
addPhantom (LengthPhantom a) (LengthPhantom b) =
    LengthPhantom (a + b)


newLengthPhantomCm : Float -> LengthPhantom Cm
newLengthPhantomCm f =
    LengthPhantom f



-- newLengthPhantomIn : Float -> LengthPhantom In
-- newLengthPhantomIn f =
--     LengthPhantom f In
-- Helpers


newLengthCm : Float -> Length Cm
newLengthCm f =
    Length f Cm


newLengthIn : Float -> Length In
newLengthIn f =
    Length f In

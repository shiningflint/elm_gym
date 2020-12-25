# Advanced Elm Course Notes

## Opaque Types
### Examples:
##### Validated data
Inside Validate module, you have `Valid` type. But that type is opaque. You can use it, but you cannot instantiate it, create a Valid. There will be a `validate` (validate : Validator -> Error -> Valid subject)
function which accepts a validator, and returns and error or a Valid type. So that type will always be validated.

##### Handling Edge Cases
There is a module called `Cred`, short for Credentials. The Cred type is a session token. And you can only get `Cred` when you login. Therefore to check if you're logged in or not, you just need to check for `Cred` type.

In the elm-spa-example repo, there is a follow function:
`follow : Bool -> Author -> Html Msg`
This follow function in the future changed to ask for `Cred` type.
Because the follow function only works if you're logged in:
`follow : Cred -> Bool -> Author -> Html Msg`

Edge cases are easy to miss. By using opaque types, you make the program fail to compile when edge cases are not handled!

##### When not to use Opaque Types
It is when you expose and you still don't lose any guarantees. I still don't get this, because I can still write a function inside the opaque module, and just pas the needed value there anyway

## Extensible Data

### Open & Closed Record and Why Not Using it
The usual record that you usually use is a closed record. It's rigid. But there is this thing called open record. It looks like this:
```elm
type alias RecordWithID a =
    { a | id : Int }
```
This record accepts anything that has 'at least' an `id` attribute. The rest is optional.
But DON'T use open records if there are other alternatives. It is not meant to be used for extensible data.

### Extensible Custom Type with Type Parameters
Use this technique instead:
```elm
-- The type Article
type Article extraInfo =
  Article
    { title : String
    , tags : List String
    }
    extraInfo

-- Preview article, and full article
type Preview = Preview
type Full = Full Body

-- Use it like so
Decoder (Article Preview)
Decoder (Article Full)
```

## Creating Constraints
### Phantom Types
Here is an example of a normal type. With the add function
```elm
type Length units
    = Length Float units

add : Length units -> Length units -> Length units
add (Length a unit1) (Length b unit2) =
    Length (a + b) unit1
```

And here is the same thing. But using phantom types 👻
```elm
type LengthPhantom units
    = LengthPhantom Float


addPhantom : LengthPhantom units -> LengthPhantom units -> LengthPhantom units
addPhantom (LengthPhantom a) (LengthPhantom b) =
    LengthPhantom (a + b)
```

Notice that in `LengthPhantom`, the units it's only defined in the constraint. But not actually defined in the construction.
In the `addPhantom` function, the units are still constraint. Because the type definition defines that it should be the same unit. If you put Cm & In, it will not add up.

The whole point of phantom type, is that it's a constraint that is free floating, doesn't exist by default. But, when you write type annotations in elm, you have the power to choose to make them more constrained if you want to.

See these 2 type annotations:
```elm
add : Length units -> Length units -> Length units
add : Length a -> Length b -> Length c
```
both annotations will work. But the former, `Length units` is using the same type as the constraint.

One of the consideration of using phantom types, is it adds a little more in performance.
As long you define a type with one definition, at runtime it will just unbox it as is.

### Never Type

There is a type, it is called `Never`
Here are 3 types:
```elm
List (Attribute msg)
List (Attribute Msg)
List (Attribute Never)
```

The 1st one is accepting any type, because it's unbound  
The 2nd one only accepts one type, which is `Msg`  
The 3rd type, you can pass any type. But you cannot pass a concrete bounded type.

## Scaling

### Narrowing types
Change the function type annotations to only need the sub-model. It can reduce your cognitive overhead.
Because we use elm annotations. When debugging, you can easily check the function's annotations return values.

### Using Modules for Modularioty
Do not split elm code to modules just to reduce the line count. Elm functions are pure and has no side effects, so it's ok to have large files.

Do split elm code into modules based on TYPES. Because they are inter-related and you can hide logic behind it and just expose API's.

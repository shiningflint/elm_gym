## Layout

API config:
- options = JS array. An array consisting object pairs of `drawId -> valueId`, valueId is string.
- selected = JS array. An array of strings. consists of selected `valueId`s. This is used for initial selection setup. Default is empty array.
- onUpdate = Callback function to handle the updated selection.
- setSelected = Callback function to set selected options from outside.

Model =
{ selectables : (List String, Set String)
}

## Feature roadmap:
- ~~Error handling for http error~~
- ~~Error handling for Svg parse failure~~
- ~~Disabled seat Set~~

- Seat selection limit
-- Default is one
-- If limit is down to zero, set opacity 0.5 of all seats except selected ones
-- Clicking any non-selected seats will change nothing
-- Clicking selected seat will unselect and can remove all opacity


- Config colors:
-- Disabled color
-- Open color
-- Selected color

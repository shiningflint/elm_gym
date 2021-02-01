## Layout

API config:
- options = JS array. An array consisting object pairs of `drawId -> valueId`, valueId is string.
- selected = JS array. An array of strings. consists of selected `valueId`s. This is used for initial selection setup. Default is empty array.
- onUpdate = Callback function to handle the updated selection.
- setSelected = Callback function to set selected options from outside.

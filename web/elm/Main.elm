import Html exposing (Html, button, div, text, table, tr, td)
import Html.App as Html
import Transform

main = Html.beginnerProgram { model = model, view = view, update = update}

type alias Model = List String

model : { transform: Transform.Model }
model = []


type Msg = Add | Remove

update : Msg -> Model -> Model
update msg model =
  case msg of
    Add -> []
    Remove -> []

view: Model -> Html Msg
view model =
  table [] [
    tr [] [text "hi"],
    tr [] [
      td [] [text "but"],
      td [] [text "qux"]
    ]
  ]
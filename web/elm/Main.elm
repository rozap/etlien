import Html exposing (Html, button, div, text, table, tr, td)
import Html.App as Html
import Stage

main = Html.beginnerProgram { model = model, view = view, update = update}

type alias Model = { stages: Stage.Model }

model = { stages = [] }


type Action = StageEdit Stage.Edit

update : Action -> Model -> Model
update action model =
  case action of
    StageEdit edit -> {model | stages = Stage.update edit model.stages}

view: Model -> Html Action
view model =
  table [] [
    tr [] [text "hi"],
    tr [] [
      td [] [text "but"],
      td [] [text "qux"]
    ]
  ]
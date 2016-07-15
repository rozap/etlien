module Stage exposing (Model, update, Edit)


type alias Stage = {name: String}

type alias Model = List Stage

type Edit
  = AddStage Stage
  | RemoveStage Stage
  | EditStage Stage

update : Edit -> Model -> Model
update action model =
  case action of
    AddStage stage -> []
    RemoveStage stage -> []
    EditStage stage -> []
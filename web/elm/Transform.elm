module Transform exposing (Model)


type alias Stage = {name: String}

type alias Model = List Stage

type Action = Add | Remove

update : Action -> Model -> Model
update action model =
  case action of
    Add -> []
    Remove -> []
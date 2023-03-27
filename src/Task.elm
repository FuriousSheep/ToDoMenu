module Task exposing (..)

import Domain exposing (Spoons(..))
import Html


type alias Task a =
    { name : TaskName
    , description : TaskDescription a
    , ressource : List Ressource
    }


type alias TaskName =
    String


type TaskDescription a
    = TaskDescription a


type Ressource
    = RessourceSpoons Spoons
    | RessourceMinutes Int
    | RessourceMoney Int


faireLesCourses : Task String
faireLesCourses =
    { name = "faire les courses"
    , description = TaskDescription "Aller dépenser des sous pour manger"
    , ressource = [ RessourceSpoons TwoSpoons ]
    }


faireLesCourses2 : Task (Html.Html Never)
faireLesCourses2 =
    { name = "Faire les courses, en Html"
    , description = TaskDescription <| Html.div [] [ Html.text "Aller dépenser des sous pour manger" ]
    , ressource = [ RessourceSpoons TwoSpoons, RessourceMinutes 30 ]
    }


addRessources : Ressource a -> Ressource a -> Ressource a

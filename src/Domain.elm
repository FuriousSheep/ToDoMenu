module Domain exposing (..)

import Url

-- MODEL 
type alias Model = 
    { url : Url.Url 
    , menus : List TodoMenu
    , route : Route
    }

type Route = EditMenuRoute TodoMenu
           | MenuListRoute
           | PickTasksRoute


type alias TodoMenu = 
    { title : String
    , description : String
    , tasks : List Task
    }

type alias Task = 
    { name : TaskName
    , description : TaskDescription
    , spoons : TaskSpoons
    }

type TaskInputs = TaskName | TaskDescription | TaskSpoons
type alias TaskName = String
type alias TaskDescription = String
type alias TaskSpoons = Int

-- MODEL HELPERS

routeToString : Route -> String
routeToString route =
    case route of
       EditMenuRoute _ -> "EditMenuRoute"
       MenuListRoute -> "MenuListRoute"
       PickTasksRoute -> "PickTasksRoute"

routesList : List Route
routesList = 
    [ EditMenuRoute emptyMenu
    , MenuListRoute
    , PickTasksRoute
    ]

emptyTask : Task
emptyTask = { name = ""
            , description = ""
            , spoons = 0
            }

emptyMenu : TodoMenu
emptyMenu = 
    { title = ""
    , description = ""
    , tasks = []
    }

stringToSpoons : String -> TaskSpoons
stringToSpoons str = 
    case Maybe.withDefault 0 <| String.toInt str of
       1 -> 1
       2 -> 2
       3 -> 3
       _ -> 0

spoonsToString : TaskSpoons -> String
spoonsToString spoons = case spoons of
   3 -> "3" 
   2 -> "2"
   1 -> "1"
   _ -> "0"

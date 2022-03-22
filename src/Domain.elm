module Domain exposing (..)

import Url



-- MODEL


type alias Model =
    { url : Url.Url
    , menus : List TodoMenu
    , route : Route
    }


type Route
    = EditMenuRoute TodoMenu
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
    , spoons : Spoons
    }


type TaskName
    = TaskName String


type TaskDescription
    = TaskDescription String


type Spoons
    = OneSpoon
    | TwoSpoons
    | ThreeSpoons



-- MODEL HELPERS
-- ISOs


routeToString : Route -> String
routeToString route =
    case route of
        EditMenuRoute _ ->
            "EditMenuRoute"

        MenuListRoute ->
            "MenuListRoute"

        PickTasksRoute ->
            "PickTasksRoute"


routesList : List Route
routesList =
    [ EditMenuRoute emptyMenu
    , MenuListRoute
    , PickTasksRoute
    ]


emptyTask : Task
emptyTask =
    { name = TaskName ""
    , description = TaskDescription ""
    , spoons = OneSpoon
    }


emptyMenu : TodoMenu
emptyMenu =
    { title = ""
    , description = ""
    , tasks = []
    }


spoonsToString : Spoons -> String
spoonsToString spoons =
    case spoons of
        OneSpoon ->
            "1"

        TwoSpoons ->
            "2"

        ThreeSpoons ->
            "3"

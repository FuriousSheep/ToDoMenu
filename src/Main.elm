module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Debug
import Element as E
import Element.Events as Ev
import Element.Background as Bg
import Element.Input as Input
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List.Extra exposing (setAt, getAt, zip)
import String
import Url


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }

-- MODEL 
type alias Model = 
    { url : Url.Url 
    , tasks : List Task
    , route : Route
    }

type Route = AddTaskRoute 
           | TaskMenu

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
       AddTaskRoute -> "AddTaskRoute"
       TaskMenu -> "TaskMenu"

routesList : List Route
routesList = 
    [ AddTaskRoute
    , TaskMenu
    ]

emptyTask : Task
emptyTask = { name = ""
            , description = ""
            , spoons = 0
            }

-- INIT
init : flags -> Url.Url -> Nav.Key -> ( Model, Cmd msg )
init _ url _ = 
    (initModel url, Cmd.none)

initModel : Url.Url -> Model
initModel url = 
    { url = url
    , tasks = []
    , route = AddTaskRoute
    }

-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none

-- MESSAGE
type Msg = UrlChanged Url.Url
         | LinkClicked Browser.UrlRequest
         --
         | AddTaskToMenu
         | ChangeRoute Route
         | UpdateTask TaskInputs Int String


-- UPDATE

update : Msg -> Model ->  ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChanged _ -> (model, Cmd.none)
        LinkClicked _ -> (model, Cmd.none)

        AddTaskToMenu -> 
            case model.route of
                AddTaskRoute -> ({model | tasks = model.tasks ++ [emptyTask]}, Cmd.none)
                _ -> (model, Cmd.none)

        ChangeRoute route -> 
            ({model | route = route}, Cmd.none)

        UpdateTask taskInput index value ->
            case model.route of
                AddTaskRoute ->
                    let
                        toUpdateTask = getAt index model.tasks 
                    in
                    case toUpdateTask of
                        Just gotTask ->
                            case taskInput of
                                TaskName -> 
                                    ( {model | tasks = setAt index {gotTask | name = value } model.tasks }
                                    , Cmd.none )
                                TaskDescription ->
                                    ( {model | tasks = setAt index {gotTask | description = value } model.tasks }
                                    , Cmd.none)
                                TaskSpoons ->
                                    ( {model | tasks = setAt index {gotTask | spoons = stringToSpoons value } model.tasks } 
                                    , Cmd.none)
                        Nothing -> (model, Cmd.none)
                TaskMenu -> (model, Cmd.none)

-- VIEW
view : Model -> Browser.Document Msg
view model =
    let
        currentView = case model.route of
            AddTaskRoute ->
                [ E.column [] <| List.map inputTask ( List.indexedMap Tuple.pair model.tasks) 
                , addTaskButton
                ]
            TaskMenu -> 
                [ E.el [] <| E.text "taskMenu" ]
    in
    
    { title = "ToDoMenu"
    , body = 
        [ E.layout [] <| E.column [] (navBar :: currentView) ]
    }

navBar = 
    E.row 
        [ E.width E.fill
        , E.spaceEvenly
        , E.paddingXY 40 20
        , Bg.color (E.rgba255 240 0 245 50)
        ] 
        (List.map navLink <| zip (List.map routeToString routesList) routesList )
    

navLink : (String, Route) -> E.Element Msg
navLink (str, route) = 
    E.el 
        [ Ev.onClick <| ChangeRoute route 
        , E.pointer
        ] 
        (E.text str)

-- COMPONENTS
addTaskButton : E.Element Msg
addTaskButton =
    Input.button [E.width <| E.maximum 40 (E.fill)] {onPress = Just AddTaskToMenu, label = E.text "+"}

inputTask : (Int, Task) -> E.Element Msg 
inputTask (index, task) =
    E.row [E.width E.fill]
        [ Input.text [E.width <| E.fillPortion 1] 
            { onChange = UpdateTask TaskName index
            , text = task.name
            , placeholder = Just (Input.placeholder [] <| E.text "Dress up")
            , label = Input.labelHidden "Name"
            }
        , Input.text [E.width <| E.fillPortion 3] 
            { onChange = UpdateTask TaskDescription index
            , text = task.description
            , placeholder = Just (Input.placeholder [] <| E.text "Put on the nice pants")
            , label = Input.labelHidden "Description"
            }
        , Input.text [E.width <| E.fillPortion 1] 
            { onChange = UpdateTask TaskSpoons index
            , text = spoonsToString task.spoons
            , placeholder = Just (Input.placeholder [] <| E.text "1-3")
            , label = Input.labelHidden "Spoons"
            }
        ]

displayTask : Task -> Html Msg
displayTask task = 
    div [] 
        [ p [] [text task.name]
        , p [] [text task.description]
        , p [] [text (String.fromInt task.spoons)]
        ]

-- HELPERS
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
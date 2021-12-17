module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List.Extra exposing (setAt, getAt)
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
    , id : String 
    , tasks : List Task
    , route : Route
    }

type Route = AddTaskRoute Task | TaskMenu

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
    , id = "Hello there!"
    , tasks = []
    , route = AddTaskRoute         
        { name = ""
        , description = ""
        , spoons = 0
        }
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
         | EditId String
         | UpdateTask TaskInputs Int String


-- UPDATE

update : Msg -> Model ->  ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChanged _ -> (model, Cmd.none)
        LinkClicked _ -> (model, Cmd.none)

        AddTaskToMenu -> 
            let newModel = { model | route = AddTaskRoute emptyTask }
            in
            case model.route of
                AddTaskRoute task -> ({newModel | tasks = model.tasks ++ [task]}, Cmd.none)
                _ -> (model, Cmd.none)

        EditId newId ->
             ( {model | id = newId}, Cmd.none )

        UpdateTask taskInput index value ->
            case model.route of
                AddTaskRoute task ->
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
    { title = "ToDoMenu"
    , body = 
        case model.route of
            AddTaskRoute task ->
                [ div [] <| List.map inputTask ( List.indexedMap Tuple.pair model.tasks) 
                , addTaskButton
                ]
            TaskMenu -> 
                [ div [] [text model.id] 
                , input [value model.id, onInput EditId] []
                ]
    }

-- COMPONENTS
addTaskButton : Html Msg
addTaskButton =
    button [onClick AddTaskToMenu] [text "+"]

inputTask : (Int, Task) -> Html Msg 
inputTask (index, task) =
    div []
        [ input [onInput (UpdateTask TaskName index),value task.name] []
        , input [onInput (UpdateTask TaskDescription index),value task.description] []
        , input [onInput (UpdateTask TaskSpoons index),value (String.fromInt task.spoons), type_ "number"] []
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
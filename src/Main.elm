module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
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

type Route = AddTaskRoute Task| TaskMenu

type alias Task = 
    { name : TaskName
    , description : TaskDescription
    , spoons : TaskSpoons
    }

type TaskInputs = TaskName | TaskDescription | TaskSpoons
type alias TaskName = String
type alias TaskDescription = String
type alias TaskSpoons = Int

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
type Msg = EditId String
         | UpdateTask TaskInputs String
         | UrlChanged Url.Url
         | LinkClicked Browser.UrlRequest


-- UPDATE

update : Msg -> Model ->  ( Model, Cmd Msg )
update msg model =
    case msg of

        EditId newId ->
             ( {model | id = newId}, Cmd.none )

        UpdateTask taskInput value ->
            case model.route of
                AddTaskRoute task ->
                    case taskInput of
                    TaskName -> 
                        ({model | route = AddTaskRoute <| {task | name =  value} }, Cmd.none)
                    TaskDescription ->
                        ({model | route = AddTaskRoute <| {task | description =  value} }, Cmd.none)
                    TaskSpoons ->
                        ({model | route = AddTaskRoute <| {task | spoons = stringToSpoons value} }, Cmd.none)
                _ -> (model, Cmd.none)
        UrlChanged _ -> (model, Cmd.none)
        LinkClicked _ -> (model, Cmd.none)

-- VIEW
view : Model -> Browser.Document Msg
view model =
    { title = "ToDoMenu"
    , body = 
        case model.route of
            AddTaskRoute task ->
                [ div [] [inputTask task] ]
            TaskMenu -> 
                [ div [] [text model.id] 
                , input [value model.id, onInput EditId] []
                ]
    }

-- COMPONENTS
inputTask : Task -> Html Msg 
inputTask task =
    div []
        [ input [onInput (UpdateTask TaskName),value task.name] []
        , input [onInput (UpdateTask TaskDescription),value task.description] []
        , input [onInput (UpdateTask TaskSpoons),value (String.fromInt task.spoons), type_ "number"] []
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
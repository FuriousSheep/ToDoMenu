module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Debug
import Domain exposing (..)
import Element as E
import Element.Events as Ev
import Element.Background as Bg
import Element.Border as Border
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

-- INIT
init : flags -> Url.Url -> Nav.Key -> ( Model, Cmd msg )
init _ url _ = 
    (initModel url, Cmd.none)

initModel : Url.Url -> Model
initModel url = 
    { url = url
    , menus = []
    , route = EditMenuRoute emptyMenu
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
         | UpdateNewMenuTitle String


-- UPDATE

update : Msg -> Model ->  ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChanged _ -> (model, Cmd.none)
        LinkClicked _ -> (model, Cmd.none)

        AddTaskToMenu -> 
            case model.route of
                EditMenuRoute oldMenu -> 
                    let
                        newMenu = {oldMenu | tasks = oldMenu.tasks ++ [emptyTask]}
                    in
                    ({model | route = EditMenuRoute newMenu}, Cmd.none)
                _ -> (model, Cmd.none)

        ChangeRoute route -> 
            ({model | route = route}, Cmd.none)

        UpdateTask taskInput index value ->
            case model.route of
                EditMenuRoute oldMenu ->
                    updateTask taskInput index value model oldMenu
                MenuListRoute -> (model, Cmd.none)
                PickTasksRoute -> (model, Cmd.none)

        UpdateNewMenuTitle newTitle -> 
            case model.route of
                EditMenuRoute oldMenu ->
                    let
                        newMenu = {oldMenu | title = newTitle}
                    in
                    ( { model | route = EditMenuRoute newMenu }
                    , Cmd.none )
                MenuListRoute -> (model, Cmd.none)
                PickTasksRoute -> (model, Cmd.none)

updateTask : TaskInputs -> Int ->  String -> Model -> TodoMenu -> (Model, Cmd Msg) 
updateTask taskInput index value model oldMenu =
    let
        toUpdateTask = getAt index oldMenu.tasks
    in
    case toUpdateTask of
        Just gotTask ->
            case taskInput of
                TaskName -> 
                    let 
                        newTask = { gotTask | name = value }
                        newMenu = { oldMenu | tasks = setAt index newTask oldMenu.tasks }
                    in
                    ( { model | route = EditMenuRoute newMenu }
                    , Cmd.none )
                TaskDescription ->
                    let 
                        newTask = { gotTask | description = value }
                        newMenu = { oldMenu | tasks = setAt index newTask oldMenu.tasks }
                    in
                    ( {model | route = EditMenuRoute newMenu }
                    , Cmd.none)
                TaskSpoons ->
                    let 
                        newTask = {gotTask | spoons = stringToSpoons value }
                        newMenu = {oldMenu | tasks = setAt index newTask oldMenu.tasks }
                    in
                    ( { model | route = EditMenuRoute newMenu } 
                    , Cmd.none)
        Nothing -> (model, Cmd.none) --this should not be possible


-- VIEW
view : Model -> Browser.Document Msg
view model =
    { title = "ToDoMenu"
    , body = 
        [ E.layout 
            [ E.width E.fill ] 
            ( E.column 
                [ E.width E.fill
                , E.spacing 8 ]
                (navBar :: currentView model.route)
            ) 
        ]
    }

currentView : Route -> List (E.Element Msg)
currentView route = case route of
            EditMenuRoute newMenu->
                [ E.column 
                    [ E.centerX ] 
                    [ Input.text
                        []
                        { onChange = UpdateNewMenuTitle
                        , text = newMenu.title
                        , label = Input.labelAbove [ E.centerX ] <| E.text "Menu title"
                        , placeholder = Just <| Input.placeholder [] <| E.text "Self-care activities"
                        }
                    ]
                , E.column 
                    [ E.centerX ]
                    <| List.map inputTask ( List.indexedMap Tuple.pair newMenu.tasks ) 
                , addTaskButton
                ]
            MenuListRoute -> 
                [ E.el [] <| E.text "MenuListRoute" ]
            PickTasksRoute -> 
                [ E.el [] <| E.text "PickTasksRoute" ]

navBar : E.Element Msg
navBar = 
    E.row 
        [ E.width E.fill
        , E.spaceEvenly
        , E.paddingXY 40 20
        , Bg.color (E.rgba255 240 0 245 50)
        , Border.solid
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
    Input.button 
        [ E.width <| E.px 80
        , E.height <| E.px 40
        , E.centerX
        , Bg.color <| E.rgba255 240 30 245 70
        , Border.rounded 8
        , Border.shadow
            { offset = (0, 0)
            , size = 4
            , blur = 1
            , color = E.rgba255 120 20 120 0.7
            }
        ] 
        { onPress = Just AddTaskToMenu, label = E.el [E.centerX] <| E.text "+" }

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
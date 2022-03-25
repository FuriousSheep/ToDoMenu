module Main exposing (..)

import Browser
import Browser.Navigation as Nav
import Domain exposing (..)
import Element as E
import Element.Background as Bg
import Element.Border as Border
import Element.Events as Ev
import Element.Input as Input
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List.Extra exposing (find, findIndex, setAt, setIf, zip)
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
    ( initModel url, Cmd.none )


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


type Msg
    = UrlChanged Url.Url
    | LinkClicked Browser.UrlRequest
    | ChangeRoute Route
    | UpdateMenu TodoMenu



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChanged _ ->
            ( model, Cmd.none )

        LinkClicked _ ->
            ( model, Cmd.none )

        ChangeRoute route ->
            let
                newModel =
                    { model | route = route }
            in
            case model.route of
                EditMenuRoute editedMenu ->
                    ( updateMenus editedMenu newModel
                    , Cmd.none
                    )

                PickTasksRoute ->
                    ( newModel, Cmd.none )

        UpdateMenu newMenu ->
            ( { model | route = EditMenuRoute newMenu }, Cmd.none )


updateMenus : TodoMenu -> Model -> Model
updateMenus editedMenu nextModel =
    { nextModel
        | menus =
            case findIndex (\menu -> menu.title == editedMenu.title) nextModel.menus of
                Just index ->
                    setAt index editedMenu nextModel.menus

                Nothing ->
                    nextModel.menus ++ [ editedMenu ]
    }



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "ToDoMenu"
    , body =
        [ E.layout
            [ E.width E.fill ]
            (E.column
                [ E.width E.fill
                , E.spacing 8
                ]
                (navBar :: currentView model model.route)
            )
        ]
    }


currentView : Model -> Route -> List (E.Element Msg)
currentView model route =
    case route of
        EditMenuRoute newMenu ->
            [ E.row [ E.width E.fill ]
                [ todoMenuMenu model.menus
                , E.column
                    [ E.centerX
                    , E.width <| E.fillPortion 3
                    ]
                  <|
                    List.map (inputTask newMenu) (List.indexedMap Tuple.pair newMenu.tasks)
                        ++ [ addTaskButton newMenu ]
                ]
            ]

        PickTasksRoute ->
            [ E.el [] <| E.text "PickTasksRoute" ]


todoMenuMenu : List TodoMenu -> E.Element Msg
todoMenuMenu menus =
    let
        menuInput menu =
            Input.text
                [ E.centerX
                , E.width <| Debug.todo "give some padding"
                ]
                { onChange = \str -> UpdateMenu { menu | title = str }
                , text = menu.title
                , label = Input.labelAbove [ E.centerX ] <| E.text "Menu title"
                , placeholder = Just <| Input.placeholder [] <| E.text "Self-care activities"
                }
    in
    E.column
        [ E.alignLeft
        , E.width <| E.fillPortion 1
        , E.alignTop
        ]
    <|
        List.map menuInput menus


navBar : E.Element Msg
navBar =
    E.row
        [ E.width E.fill
        , E.spaceEvenly
        , E.paddingXY 40 20
        , Bg.color (E.rgba255 240 0 245 50)
        , Border.solid
        ]
        (List.map navLink <| zip (List.map routeToString routesList) routesList)


navLink : ( String, Route ) -> E.Element Msg
navLink ( str, route ) =
    E.el
        [ Ev.onClick <| ChangeRoute route
        , E.pointer
        ]
        (E.text str)



-- COMPONENTS


addTaskButton : TodoMenu -> E.Element Msg
addTaskButton menu =
    Input.button
        [ E.width <| E.px 80
        , E.height <| E.px 40
        , E.centerX
        , Bg.color <| E.rgba255 240 30 245 70
        , Border.rounded 8
        , Border.shadow
            { offset = ( 0, 0 )
            , size = 4
            , blur = 1
            , color = E.rgba255 120 20 120 0.7
            }
        ]
        { onPress = Just (UpdateMenu { menu | tasks = menu.tasks ++ [ emptyTask ] })
        , label = E.el [ E.centerX ] <| E.text "+"
        }



-- spoonButton : E.Element Msg
-- spoonButton =
--     Input.button
--         [ E.width <| E.px 40
--         , E.height <| E.px 40
--         , Bg.color <| E.rgba255 240 30 245 30
--         ]
--         { onPress }


inputTask : TodoMenu -> ( Int, Task ) -> E.Element Msg
inputTask menu ( index, task ) =
    let
        (TaskDescription description) =
            task.description

        (TaskName name) =
            task.name
    in
    E.row [ E.width E.fill ]
        [ Input.text [ E.width <| E.fillPortion 1 ]
            { onChange =
                \string ->
                    UpdateMenu { menu | tasks = setAt index { task | name = TaskName string } menu.tasks }
            , text = name
            , placeholder = Just (Input.placeholder [] <| E.text "Dress up")
            , label = Input.labelHidden "Name"
            }
        , Input.text [ E.width <| E.fillPortion 3 ]
            { onChange =
                \string ->
                    UpdateMenu { menu | tasks = setAt index { task | description = TaskDescription string } menu.tasks }
            , text = description
            , placeholder = Just (Input.placeholder [] <| E.text "Put on the nice pants")
            , label = Input.labelHidden "Description"
            }

        --TODO: add buttons
        ]

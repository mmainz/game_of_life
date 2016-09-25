module GameOfLife exposing (..)

import Html exposing (..)
import Html.App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push
import String

type alias Model =
    { phxSocket : Phoenix.Socket.Socket Msg
    , width : Int
    , height : Int
    }

type Msg =
    SetWidth String
    | SetHeight String
    | PhoenixMsg (Phoenix.Socket.Msg Msg)

main : Program Never
main =
    Html.App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

init : ( Model, Cmd Msg )
init =
  ( initModel, Cmd.none )

initModel : Model
initModel =
  { phxSocket = Phoenix.Socket.init "ws://localhost:4000/socket/websocket"
  , width = 0
  , height = 0
  }

view : Model -> Html Msg
view model =
    div []
        [ p [] [text "New Game of Life"]
        , p [] [input [onInput SetWidth, value (toString model.width)] []
               , text "x"
               , input [onInput SetHeight, value (toString model.height)] []
               ]
        , p [] [button [] [text "Create!"]]
        ]

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetWidth width ->
            case String.toInt width of
                Ok int ->
                  ( { model | width = int}
                  , Cmd.none
                  )
                Err _ ->
                  ( model
                  , Cmd.none
                  )

        SetHeight height ->
            case String.toInt height of
                Ok int ->
                  ( { model | height = int}
                  , Cmd.none
                  )
                Err _ ->
                  ( model
                  , Cmd.none
                  )

        PhoenixMsg msg ->
          let
            ( phxSocket, phxCmd ) = Phoenix.Socket.update msg model.phxSocket
          in
            ( { model | phxSocket = phxSocket }
            , Cmd.map PhoenixMsg phxCmd
            )

subscriptions : Model -> Sub Msg
subscriptions model =
  Phoenix.Socket.listen model.phxSocket PhoenixMsg

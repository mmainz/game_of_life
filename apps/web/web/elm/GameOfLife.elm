module GameOfLife exposing (..)

import Html exposing (..)
import Html.App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Encode
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
    | CreateGame
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
    let
        initSocket = Phoenix.Socket.init "ws://localhost:4000/socket/websocket"
        channel = Phoenix.Channel.init "game:lobby"
        (phxSocket, phxCmd) = Phoenix.Socket.join channel initSocket
        initModel =
            { phxSocket = phxSocket
            , width = 0
            , height = 0
            }
    in
        ( initModel, Cmd.map PhoenixMsg phxCmd )

view : Model -> Html Msg
view model =
    div []
        [ p [] [text "New Game of Life"]
        , p [] [input [onInput SetWidth, value (toString model.width)] []
               , text "x"
               , input [onInput SetHeight, value (toString model.height)] []
               ]
        , p [] [button [onClick CreateGame] [text "Create!"]]
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

        CreateGame ->
            let
              payload =
                  Json.Encode.object
                        [ ("width", Json.Encode.string (toString model.width))
                        , ("height", Json.Encode.string (toString model.height))
                        ]
              push' =
                Phoenix.Push.init "create" "game:lobby"
                  |> Phoenix.Push.withPayload payload
              (phxSocket, phxCmd) = Phoenix.Socket.push push' model.phxSocket
            in
              ( { model | phxSocket = phxSocket }
              , Cmd.map PhoenixMsg phxCmd
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

module GameOfLife exposing (..)

import Html exposing (..)
import Html.App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode exposing ((:=))
import Json.Encode
import Phoenix.Channel
import Phoenix.Push
import Phoenix.Socket
import String

type alias Model =
    { phxSocket : Phoenix.Socket.Socket Msg
    , width : Int
    , height : Int
    , name : String
    }

type alias NewGameNotification = { name : String }

newGameNotificationDecoder : Json.Decode.Decoder NewGameNotification
newGameNotificationDecoder =
    Json.Decode.object1 NewGameNotification
        ("name" := Json.Decode.string)

type Msg =
    SetWidth String
    | SetHeight String
    | SetName String
    | CreateGame
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | ReceiveNewGame Json.Encode.Value

main : Program Never
main =
    Html.App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

initSocket : Phoenix.Socket.Socket Msg
initSocket =
    Phoenix.Socket.init "ws://localhost:4000/socket/websocket"
        |> Phoenix.Socket.on "new_game" "game:lobby" ReceiveNewGame

init : ( Model, Cmd Msg )
init =
    let
        channel = Phoenix.Channel.init "game:lobby"
        (phxSocket, phxCmd) = Phoenix.Socket.join channel initSocket
        initModel =
            { phxSocket = phxSocket
            , width = 10
            , height = 10
            , name = "MyGame"
            }
    in
        ( initModel, Cmd.map PhoenixMsg phxCmd )

view : Model -> Html Msg
view model =
    div []
        [ p [] [text "New Game of Life"]
        , p [] [ input [onInput SetWidth, value (toString model.width)] []
               , text "x"
               , input [onInput SetHeight, value (toString model.height)] []
               ]
        , p [] [input [onInput SetName, value model.name] []]
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

        SetName name ->
            ( { model | name = name }
            , Cmd.none
            )

        CreateGame ->
            let
              payload =
                  Json.Encode.object
                        [ ("width", Json.Encode.int model.width)
                        , ("height", Json.Encode.int model.height)
                        , ("name", Json.Encode.string model.name)
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

        ReceiveNewGame raw ->
            case Json.Decode.decodeValue newGameNotificationDecoder raw of
                Ok newGameNotification ->
                    let
                      channel = Phoenix.Channel.init ("game:" ++ newGameNotification.name)
                      (phxSocket, phxCmd) = Phoenix.Socket.join channel model.phxSocket
                    in
                      ( { model | phxSocket = phxSocket }
                      , Cmd.map PhoenixMsg phxCmd
                      )

                Err _ ->
                    ( model
                    , Cmd.none
                    )

subscriptions : Model -> Sub Msg
subscriptions model =
  Phoenix.Socket.listen model.phxSocket PhoenixMsg

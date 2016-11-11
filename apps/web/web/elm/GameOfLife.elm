module GameOfLife exposing (..)

import Html exposing (..)
import Html.App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode exposing ((:=))
import Json.Encode
import Phoenix.Channel
import Phoenix.Socket
import String

type alias Model =
    { phxSocket : Phoenix.Socket.Socket Msg
    , width : Int
    , height : Int
    , name : String
    , games : List String
    , gameState : List (List Bool)
    , currentGame : Maybe String
    }

type alias NewGameNotification = { name : String }

type alias StateUpdate = { state : List (List Bool) }

newGameNotificationDecoder : Json.Decode.Decoder NewGameNotification
newGameNotificationDecoder =
    Json.Decode.object1 NewGameNotification
        ("name" := Json.Decode.string)

stateUpdatedDecoder : Json.Decode.Decoder StateUpdate
stateUpdatedDecoder =
    Json.Decode.object1 StateUpdate
        ("state" := (Json.Decode.list (Json.Decode.list Json.Decode.bool)))

type Msg =
    SetWidth String
    | SetHeight String
    | SetName String
    | CreateGame
    | JoinGame String
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | ReceiveNewGame Json.Encode.Value
    | StateUpdated Json.Encode.Value

type alias Flags =
    { host: String }

main : Program Flags
main =
    Html.App.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

initSocket : String -> Phoenix.Socket.Socket Msg
initSocket host =
    let
        socketPath = (host ++ "/socket/websocket")
    in
        Phoenix.Socket.init socketPath
                |> Phoenix.Socket.on "new_game" "game:lobby" ReceiveNewGame

init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        channel = Phoenix.Channel.init "game:lobby"
        (phxSocket, phxCmd) = Phoenix.Socket.join channel (initSocket flags.host)
        initModel =
            { phxSocket = phxSocket
            , width = 10
            , height = 10
            , name = "MyGame"
            , games = []
            , gameState = []
            , currentGame = Nothing
            }
    in
        ( initModel, Cmd.map PhoenixMsg phxCmd )

view : Model -> Html Msg
view model =
    let
      gameItems = ul [] (List.map gameItem model.games)
      stateTable = table [] (List.map stateRow model.gameState)
      currentGame = case model.currentGame of
                        Just game -> String.dropLeft 5 game
                        Nothing -> ""
    in
      div [] [ div [class "game-controls"]
                   [ newGameForm model
                   , gameItems
                   ]
                   , h1 [] [text currentGame]
             , stateTable
             ]

newGameForm : Model -> Html Msg
newGameForm model =
    div [class "new-game-form"]
        [ p [] [h1 [] [text "New Game of Life"]]
        , p [] [ input [onInput SetWidth, value (toString model.width)] []
               , text "x"
               , input [onInput SetHeight, value (toString model.height)] []
               ]
        , p [] [input [onInput SetName, value model.name] []]
        , p [] [button [onClick CreateGame] [text "Create!"]]
        ]


gameItem : String -> Html Msg
gameItem name =
    li [] [ text name
          , a [class "join-link", onClick (JoinGame name)] [text "Join"]
          ]

stateRow : List Bool -> Html msg
stateRow row =
    tr [] (List.map stateCell row)

stateCell : Bool -> Html msg
stateCell cell =
    td [if cell then class "active-cell" else class "inactive-cell"] []

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
              (leftSocket, leaveCmd) = leaveCurrentGame model
              room = "game:" ++ model.name
              payload =
                  Json.Encode.object
                        [ ("width", Json.Encode.int model.width)
                        , ("height", Json.Encode.int model.height)
                        ]
              channel = Phoenix.Channel.init room
                        |> Phoenix.Channel.withPayload payload
              (joinedSocket, joinCmd) = Phoenix.Socket.join channel model.phxSocket
              phxSocket = Phoenix.Socket.on "state_updated" room StateUpdated joinedSocket
            in
              ( { model | phxSocket = phxSocket
                , currentGame = Just room
                }
              , Cmd.batch [ Cmd.map PhoenixMsg leaveCmd
                          , Cmd.map PhoenixMsg joinCmd
                          ]
              )

        JoinGame game ->
            let
                (leftSocket, leaveCmd) = leaveCurrentGame model
                room = "game:" ++ game
                channel = Phoenix.Channel.init room
                (joinedSocket, joinCmd) = Phoenix.Socket.join channel model.phxSocket
                phxSocket = Phoenix.Socket.on "state_updated" room StateUpdated joinedSocket
            in
              ( { model | phxSocket = phxSocket
                , currentGame = Just room
                }
              , Cmd.batch [ Cmd.map PhoenixMsg leaveCmd
                          , Cmd.map PhoenixMsg joinCmd
                          ]
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
                    ( { model | games = (model.games ++ [newGameNotification.name]) }
                    , Cmd.none
                    )

                Err _ ->
                    ( model
                    , Cmd.none
                    )

        StateUpdated raw ->
            case Json.Decode.decodeValue stateUpdatedDecoder raw of
                Ok stateUpdate ->
                    ( { model | gameState = stateUpdate.state }
                    , Cmd.none
                    )

                Err _ ->
                    ( model
                    , Cmd.none
                    )

leaveCurrentGame model =
    case model.currentGame of
        Just currentGame ->
            Phoenix.Socket.leave currentGame model.phxSocket
        Nothing ->
            (model.phxSocket, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model =
  Phoenix.Socket.listen model.phxSocket PhoenixMsg

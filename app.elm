module App exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import OpenTok
import Task

main : Program Flags Model Msg
main =
  Html.programWithFlags
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

type alias Model =
  { credentials : OpenTok.Credentials
  , status : String
  , isConnected : Bool
  , isPublishing : Bool
  , publisherStreamId : String
  , streamIds : List String
  }

type alias Flags =
  { credentials : OpenTok.Credentials
  }

sendMsg : msg -> Cmd msg
sendMsg msg =
  Task.succeed msg
  |> Task.perform identity

init : Flags -> (Model, Cmd Msg)
init flags =
  (Model flags.credentials "" False False "" [], sendMsg Connect)

subContainerId : String -> String
subContainerId streamId = "subscriberContainer" ++ streamId

type Msg
  = Connect
  | ConnectCallback OpenTok.ConnectCallbackResult
  | Disconnect
  | PublishCallback OpenTok.PublishCallbackResult
  | Subscribe String
  | SubscribeCallback OpenTok.SubscribeCallbackResult
  | Unsubscribe String
  | OnStreamCreated OpenTok.StreamEvent
  | OnStreamDestroyed OpenTok.StreamEvent

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Connect ->
      ( { model | status = "" }
      , OpenTok.connect model.credentials
      )

    ConnectCallback result ->
      ( { model | isConnected = result.success, status = result.message }
      , if result.success
        then (OpenTok.publish (OpenTok.PublishOptions model.credentials.sessionId "publisherContainer"))
        else Cmd.none
      )

    Disconnect ->
      ( { model | status = "", isConnected = False, isPublishing = False, publisherStreamId = "", streamIds = [] }
      , OpenTok.disconnect (OpenTok.DisconnectOptions model.credentials.sessionId)
      )

    PublishCallback result ->
      ( { model | isPublishing = result.success, status = result.message, publisherStreamId = result.streamId }
      , Cmd.none
      )

    Subscribe streamId ->
      ( model
      , OpenTok.subscribe
        (OpenTok.SubscribeOptions model.credentials.sessionId streamId (subContainerId streamId))
      )

    SubscribeCallback result ->
      ( { model | status = result.message }
      , Cmd.none
      )

    Unsubscribe streamId ->
      ( model
      , OpenTok.unsubscribe (OpenTok.UnsubscribeOptions model.credentials.sessionId streamId)
      )

    OnStreamCreated event ->
      ( { model | streamIds = (model.streamIds ++ [event.streamId]) }
      , sendMsg (Subscribe event.streamId)
      )

    OnStreamDestroyed event ->
      ( { model | streamIds = (List.filter (\a -> a /= event.streamId) model.streamIds) }
      , sendMsg (Unsubscribe event.streamId)
      )

streamIdToContainer : String -> Html Msg
streamIdToContainer streamId =
  div []
    [ div [] [text ("Subscriber " ++ streamId)]
    , div [id (subContainerId streamId)] []
    ]

view : Model -> Html Msg
view model =
  div []
    ([ div [] [ text ("Connected: " ++ (if model.isConnected then "Yes" else "No")) ]
    , if model.isConnected
      then (button [onClick Disconnect] [text "Disconnect"])
      else (button [onClick Connect] [ text "Connect" ])
    , div [] [ text model.status ]
    , div []
      [ div [] [text (if model.isPublishing then "Publisher " ++ model.publisherStreamId else "Publisher")]
      , div [id "publisherContainer"] []
      ]
    ] ++ (List.map streamIdToContainer model.streamIds))

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ OpenTok.connectCallback ConnectCallback
    , OpenTok.publishCallback PublishCallback
    , OpenTok.subscribeCallback SubscribeCallback
    , OpenTok.onStreamCreated OnStreamCreated
    , OpenTok.onStreamDestroyed OnStreamDestroyed
    ]

port module OpenTok exposing (..)

type alias Credentials =
  { apiKey : String
  , sessionId : String
  , token : String
  }

type alias ConnectCallbackResult =
  { sessionId : String
  , success : Bool
  , message : String
  }

type alias PublishCallbackResult =
  { sessionId : String
  , streamId : String
  , success : Bool
  , message : String
  }

type alias SubscribeCallbackResult =
  { sessionId : String
  , streamId : String
  , success : Bool
  , message : String
  }

type alias StreamEvent =
  { sessionId : String
  , streamId : String
  }

type alias DisconnectOptions =
  { sessionId : String
  }

type alias PublishOptions =
  { sessionId : String
  , containerId : String
  }

type alias SubscribeOptions =
  { sessionId : String
  , streamId : String
  , containerId : String
  }

type alias UnsubscribeOptions =
  { sessionId : String
  , streamId : String
  }

port connect : Credentials -> Cmd msg
port disconnect : DisconnectOptions -> Cmd msg
port publish : PublishOptions -> Cmd msg
port subscribe : SubscribeOptions -> Cmd msg
port unsubscribe : UnsubscribeOptions -> Cmd msg

port connectCallback : (ConnectCallbackResult -> msg) -> Sub msg
port publishCallback : (PublishCallbackResult -> msg) -> Sub msg
port subscribeCallback : (SubscribeCallbackResult -> msg) -> Sub msg
port onStreamCreated : (StreamEvent -> msg) -> Sub msg
port onStreamDestroyed : (StreamEvent -> msg) -> Sub msg

{--
-- Unused Types:

type alias ResolutionObject =
  { width : Int
  , height : Int
  }

type alias PublisherProperties =
  { audioFallbackEnabled : Bool
  , audioSource : String
  , fitMode : String
  , frameRate : Int
  , height : Int
  , insertDefaultUI : Bool
  , insertMode : String
  , maxResolution : ResolutionObject
  , mirror : Bool
  , name : String
  , publishAudio : Bool
  , publishVideo : Bool
  , resolution : String
  , showControls : Bool
  , usePreviousDeviceSelection : Bool
  , videoSource : String
  , width : Int
  }

type alias SubscriberProperties =
  { audioVolume : Int
  , fitMode : String
  , height : Int
  , insertDefaultUI : Bool
  , insertMode : String
  , preferredFrameRate : Int
  , preferredResolution : ResolutionObject
  , showControls : Bool
  , subscribeToAudio : Bool , subscribeToVideo : Bool
  , testNetwork : Bool
  , width : Int
  }
--}

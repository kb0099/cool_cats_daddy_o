module Joke exposing (..)

import Http
import Json.Decode exposing (..)

type alias Joke = 
  { avatarUrl : String
  , id : String
  , message : String
  }

totalCatImages : number
totalCatImages = 16

imageIdFromMessage : String -> Int
imageIdFromMessage message =
  modBy totalCatImages (String.length message)

imageFromMessage : String -> String
imageFromMessage message =
  let 
    imgId = imageIdFromMessage message
  in
    "http://placekitten.com/452/450?image=" ++ (String.fromInt imgId)

buildJoke : String -> String -> Joke
buildJoke id joke =
  { avatarUrl = (imageFromMessage joke), 
    id = id,
    message = joke
  }

jokeDecoder : Decoder (Joke)
jokeDecoder = Json.Decode.map2 (buildJoke) (field "id" string) (field "joke" string)

jokesDecoder : Decoder (List Joke)
jokesDecoder = (field "results" (Json.Decode.list jokeDecoder))

type alias JokeReceiver = Result Http.Error (List Joke)

jokeRequest : Int -> (JokeReceiver -> msg) -> Cmd.Cmd msg
jokeRequest page jokeReceiver =
    let
        headers =
            [ Http.header "Accept" "application/json"
            ]
    in
    Http.request -- This line is missing from your code
        { method = "GET"
        , headers = headers
        , url = "https://icanhazdadjoke.com/search?page=" ++ (String.fromInt page)
        , body = Http.emptyBody
        , expect = Http.expectJson jokeReceiver jokesDecoder
        , timeout = Nothing
        , tracker = Nothing
        }  

totalJokePages : number
totalJokePages = 21


jokeNumWords: String -> Int
jokeNumWords message = List.length (String.split " " message)

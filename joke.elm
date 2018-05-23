module Joke exposing (..)

import Http
import Json.Decode exposing (..)

type alias Joke = {
  avatarUrl : String,
  id : String,
  message : String
}

totalCatImages : number
totalCatImages = 16

imageIdFromMessage : String -> Int
imageIdFromMessage message =
  (String.length message) % totalCatImages

imageFromMessage : String -> String
imageFromMessage message =
  let 
    imgId = imageIdFromMessage message
  in
    "http://placekitten.com/452/450?image=" ++ (toString imgId)

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

jokeRequest : Int -> Http.Request (List Joke)
jokeRequest page =
    let
        headers =
            [ Http.header "Accept" "application/json"
            ]
    in
    Http.request -- This line is missing from your code
        { method = "GET"
        , headers = headers
        , url = "https://icanhazdadjoke.com/search?page=" ++ (toString page)
        , body = Http.emptyBody
        , expect = Http.expectJson jokesDecoder
        , timeout = Nothing
        , withCredentials = False
        }  

totalJokePages : number
totalJokePages = 21
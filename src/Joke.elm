module Joke exposing (..)

import Http
import Json.Decode exposing (..)
import Bitwise exposing (..)

type alias Joke = 
  { avatarUrl : String
  , id : String
  , message : String
  , wordCount : Int
  , name: String
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
    message = joke,
    wordCount = jokeNumWords joke,
    name = ""
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

--sortBy f lst =
--    List.sortWith (\a b -> compare (f a) (f b)) lst

type SortType =  None | Ascending | Descending

jokeSort: SortType -> (List Joke) -> List Joke
jokeSort sortType jokes = 
  case sortType of
    Ascending ->
      List.sortWith ascending jokes
    Descending ->
      List.sortWith descending jokes
    None ->
      jokes

ascending: Joke -> Joke -> Order
ascending j1 j2 = 
  if (j1.wordCount > j2.wordCount) then   GT
  else if (j1.wordCount < j2.wordCount) then  LT
  else EQ
  
descending j1 j2 = 
  if (j1.wordCount > j2.wordCount) then   LT
  else if (j1.wordCount < j2.wordCount) then  GT
  else EQ

-- f : filter word
-- r : replace with
filterJokes: String -> String -> List Joke -> List Joke
filterJokes f r jokes =
  List.map
    (\j -> {j | wordCount = jokeNumWords j.message})
    (List.map (\j -> {j | message = (String.replace f r) j.message }) jokes)

-- Takes a random list of name and maps to each joke
assignRandomNames: List String -> List Joke -> List Joke
assignRandomNames names jokes =
  List.map (\j -> {j | name = getNameForId j.id names}) jokes


-- uses the hash of id to map it to a random name
-- collisions are ignored for now!
getNameForId: String -> List String -> String
getNameForId id names= 
  let
    h = hash(id)
    indx = remainderBy (List.length names) h 
    elm = List.head (List.drop indx names)
  in
    case elm of
      Just name ->
        name
      Nothing ->
        String.fromInt h ++  " " ++ String.fromInt indx


-- credit: https://github.com/jergason/elm-hash/tree/1.0.0
hash : String -> Int
hash str =
  abs(String.foldl (\c h -> (shiftLeftBy 5 h) + h + Char.toCode c) 5381 str)

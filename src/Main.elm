import Html exposing (Html, button, div, img, text, hr, input)
import Browser
import Html.Attributes exposing(..)
import List exposing (map)
import Http
import Random exposing (..)
import Joke exposing (..)
import Html.Events exposing (onClick, onInput)

import Random.Extra exposing (..)
import Random.List
import Joke exposing (..)
import AllNames exposing (..)

import Debug

main : Program () Model Msg
main =
  Browser.element
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions 
    }

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

-- MODEL

type alias Model = 
  { page : Int
  , jokes : List Joke
  , sortStatus: SortType
  , toReplace: String
  , replaceWith: String
  }

init : () -> (Model, Cmd Msg)
init _ =
  (Model 0 [] None "" "", getPage)

-- UPDATE

type Msg = ReceiveJokes JokeReceiver 
         | ReceivePage Int
         | Sort SortType
         | FilterWords
         | ToReplace String
         | ReplaceWith String
         | RandomizeNames
         | RandomizedNames (List String)    

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ReceiveJokes (Ok newJokes) ->
      ({ model | jokes = List.concat [newJokes, model.jokes] }, Cmd.none)
    ReceiveJokes (Err _) ->
      (model, Cmd.none)
    ReceivePage page ->
      let updatedModel = { model | page = page } 
      in (updatedModel, getJokes page)
    Sort sortType ->
      let 
        m1 = {model | jokes = jokeSort sortType model.jokes}
        updatedModel = {m1 | sortStatus = sortType}
      in (updatedModel, Cmd.none)
    FilterWords ->
      let
        updatedModel = {model | jokes = filterJokes model.toReplace model.replaceWith model.jokes}
      in
        (updatedModel, Cmd.none)
    ToReplace content ->
      ({model | toReplace = content}, Cmd.none)
    ReplaceWith content ->
      ({model | replaceWith = content}, Cmd.none)
    RandomizeNames -> 
      (model, Random.generate RandomizedNames (Random.List.shuffle allNames) )
    RandomizedNames names ->       
        ( {model | jokes = assignRandomNames names model.jokes}, Cmd.none)


-- VIEW
itemStyle : List (Html.Attribute msg)
itemStyle = 
  [ style "display" "inline-block" 
  , style "margin-left" "1vw"
  ]

renderJoke : Joke -> Html Msg
renderJoke joke =
  div [ style "padding" "1vw"
      , style "margin" "1vw"
      , style "border"  "1px solid black"
  ] [
    img (itemStyle ++ [src joke.avatarUrl, width 50, height 50]) [text(joke.avatarUrl)],
    div (itemStyle ++ [style "font-style" "italic"]) [text(joke.id)],
    div (itemStyle ++ [style "font-size" "1.4em", style "font-weight" "bold", style "border" "1px solid orange"])
      [ text("Word Count: " ++ String.fromInt (jokeNumWords joke.message)) ],
    div (itemStyle ++ [style "font-weight" "bold"]) [text(joke.message)],
    div (itemStyle ++ [style "color" "gray", style "font-size" "1.4em", style "font-weight" "bold"]) [text(joke.name)]
  ]

view : Model -> Html Msg
view model =
  div [] [
    button (itemStyle ++ [onClick (Sort Ascending)]) [text("Sort Ascending")],
    button (itemStyle ++ [onClick (Sort Descending)]) [text("Sort Descending")],
    input  [ placeholder "Text to replace", value model.toReplace, onInput ToReplace] [],
    input  [ placeholder "Text to replace with", value model.replaceWith, onInput ReplaceWith ] [],
    button (itemStyle ++ [onClick (FilterWords)]) [text("Replace")],
    button (itemStyle ++ [onClick RandomizeNames]) [text("Randomize Names")],
    hr [] [],
    div [] (List.map renderJoke model.jokes)
  ]

getPage : Cmd Msg
getPage =
  Random.generate ReceivePage (Random.int 0 totalJokePages)

getJokes : Int -> Cmd Msg
getJokes page = jokeRequest page ReceiveJokes

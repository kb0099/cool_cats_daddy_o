import Html exposing (Html, button, div, img, text)
import Html.Attributes exposing(..)
import List exposing (map)
import Http
import Random exposing (..)
import Joke exposing (..)

main : Program Never Model Msg
main =
  Html.program
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

type alias Model = { 
  page : Int,
  jokes : List Joke
}

init : (Model, Cmd Msg)
init =
  (Model 0 [], getPage)

-- UPDATE

type Msg = ReceiveJokes (Result Http.Error (List Joke))
         | ReceivePage Int

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ReceiveJokes (Ok newJokes) ->
      ({ model | jokes = List.concat [newJokes, model.jokes] }, Cmd.none)
    ReceiveJokes (Err _) ->
      (model, Cmd.none)
    ReceivePage page ->
      ({ model | page = page }, getJokes page)

-- VIEW
itemStyle : List (String, String) ->  Html.Attribute msg
itemStyle extra = 
  style (("display", "inline-block") :: ("margin-left", "1vw") :: extra)

renderJoke : Joke -> Html Msg
renderJoke joke =
  div [style [
    ("padding", "1vw"),
    ("margin", "1vw"),
    ("border", "1px solid black")
  ]] [
    img [src joke.avatarUrl, width 50, height 50, itemStyle []] [text(joke.avatarUrl)],
    div [itemStyle [("font-style", "italic")]] [text(joke.id)],
    div [itemStyle [("font-weight", "bold")]] [text(joke.message)]
  ]

view : Model -> Html Msg
view model =
  div [] (List.map renderJoke model.jokes)

getPage : Cmd Msg
getPage =
  Random.generate ReceivePage (Random.int 0 totalJokePages)

getJokes : Int -> Cmd Msg
getJokes page =
  Http.send ReceiveJokes (jokeRequest page)

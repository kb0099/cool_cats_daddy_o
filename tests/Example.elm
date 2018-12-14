module Example exposing (..)

import Expect exposing (Expectation)
import Test exposing (..)
import Joke exposing (..)


suite : Test
suite =
  describe "The Joke module"
    [ describe "imageIdFromMessage" -- Nest as many descriptions as you like.
      [ test "builds avatar id from message length" <|
        \_ ->
          let
            id1 = imageIdFromMessage (String.repeat 50 "x") -- mod 16 = 2
            id2 = imageIdFromMessage (String.repeat 53 "x") -- mod 16 = 5
          in
            Expect.equal [2, 5] [id1, id2]
      ]
      , describe "jokeNumWords"
      [ test "Number of words in some edge cases" <|
        \_ ->
          let 
            len1 = jokeNumWords "sheep"
            len2 = jokeNumWords "Well, the"
            len3 = jokeNumWords "The baa-baa shop."
          in 
            Expect.equal [1, 2, 3] [len1, len2, len3] 
      ]
      , describe "jokeSort"
      [ describe "Ascending" 
        [ test "Order 1" <|
          \_ ->
            let 
              j1 = buildJoke "j1" "one"
              j2 = buildJoke "j2" "two two"
              j3 = buildJoke "j3" "three three three"
            in
              Expect.equal [j1, j2, j3] (jokeSort Ascending [j1, j2, j3])
          , test "Order 2" <|
          \_ ->
            let 
              j1 = buildJoke "j1" "one"
              j2 = buildJoke "j2" "two two"
              j3 = buildJoke "j3" "three three three"
            in
              Expect.equal [j1, j2, j3] (jokeSort Ascending [j2, j1, j3])
          , test "Order 3" <|
          \_ ->
            let 
              j1 = buildJoke "j1" "one"
              j2 = buildJoke "j2" "two two"
              j3 = buildJoke "j3" "three three three"
            in
              Expect.equal [j1, j2, j3] (jokeSort Ascending [j3, j2, j1])
        ]
      , describe "Descending"
        [ test "Order 1" <|
           \_ ->
            let 
              j1 = buildJoke "j1" "one"
              j2 = buildJoke "j2" "two two"
              j3 = buildJoke "j3" "three three three"
            in
              Expect.equal [j3, j2, j1] (jokeSort Descending [j1, j2, j3])
          , test "Order 2" <|
          \_ ->
            let 
              j1 = buildJoke "j1" "one"
              j2 = buildJoke "j2" "two two"
              j3 = buildJoke "j3" "three three three"
            in
              Expect.equal [j3, j2, j1] (jokeSort Descending [j2, j1, j3])
          , test "Order 3" <|
          \_ ->
            let 
              j1 = buildJoke "j1" "one"
              j2 = buildJoke "j2" "two two"
              j3 = buildJoke "j3" "three three three"
            in
              Expect.equal [j3, j2, j1] (jokeSort Descending [j3, j2, j1])
        ]
      ]
      , describe "filterJokes"
      [ test "jokes: j1-j3" <|
        \_ ->
          let
              j1 = buildJoke "j1" "one"
              j2 = buildJoke "j2" "two two"
              j3 = buildJoke "j3" "three three three"
              
          in
            Expect.equal [{j1|message = "One"}] (filterJokes "o" "O" [j1])
      ]

    ]

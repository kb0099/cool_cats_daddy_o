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
            Expect.equal [len1, len2, len3] [1, 2, 3]
      ]
    ]

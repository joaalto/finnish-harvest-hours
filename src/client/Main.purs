module Main where

import Prelude
import Effect (Effect)
import Server as Serv

main :: forall e. Effect Unit
main = Serv.main

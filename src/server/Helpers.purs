module Helpers where

import Prelude

import Data.Function.Uncurried (Fn1)
import Effect (Effect)
import Node.Express.Types (Request)

type User =
  { harvestId :: Int
  , accessToken :: String
  }

foreign import getUserImpl :: Fn1 Request (Effect User)

-- TODO: get these from environment
startDate = "2016-01-01"
harvestOrg = "wunderdog"

harvestUrl :: String
harvestUrl = "https://" <> harvestOrg <> ".harvestapp.com"

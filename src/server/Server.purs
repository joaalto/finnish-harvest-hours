module Server where

import Effect.Ref (Ref)
import Prelude (Unit, bind, discard, pure, ($))

import Affjax as Ax
import Affjax.ResponseFormat as ResponseFormat
import Data.Argonaut (class DecodeJson, decodeJson, getField)
import Data.Function.Uncurried (Fn1, runFn1)
import Data.Int (fromString)
import Data.Maybe (fromMaybe)
import Effect (Effect)
import Effect.Aff.Class (liftAff)
import Effect.Class (liftEffect)
import Effect.Class.Console (logShow)
import Effect.Exception (Error, message)
import HarvestApi (entriesHandler)
import Node.Express.App (App, all, apply, get)
import Node.Express.Handler (Handler, HandlerM(..), next)
import Node.Express.Response (redirect, sendJson, setStatus)
import Node.Express.Types (Application, Request)

foreign import realMain :: (Application -> Effect Unit) -> Effect Unit
foreign import isAuthenticatedImpl :: Fn1 Request (Effect Boolean)

isAuthenticated :: HandlerM Boolean
isAuthenticated = HandlerM \req _ _ -> do
  authenticated <- liftEffect $ runFn1 isAuthenticatedImpl req
  logShow authenticated
  pure authenticated

authHandler :: Handler
authHandler = do
  auth <- isAuthenticated
  case auth of
    true -> next
    false -> redirect "/login"

type AppStateData = {}
type AppState     = Ref AppStateData

data User = User
  { id :: Int
  , name :: String
  , username :: String
  }

instance decodeJsonUser :: DecodeJson User where
  decodeJson json = do
    user <- decodeJson json
    id <- getField user "id"
    name <- getField user "name"
    username <- getField user "username"
    pure $ User { id, name, username }

todosHandler :: Handler
todosHandler = do
  auth <- isAuthenticated
  res <- liftAff $ Ax.get ResponseFormat.json "http://jsonplaceholder.typicode.com/todos" -- :: Aff Json
  sendJson res.body

appSetup :: App
appSetup = do
  all "*" authHandler
  get "/todos" todosHandler
  get "/entriesx" entriesHandler

attach :: Application -> Effect Unit
attach = apply appSetup

main :: Effect Unit
main =
  realMain attach

errorHandler :: AppState -> Error -> Handler
errorHandler state err = do
  setStatus 400
  sendJson {error: message err}

-- initState :: Effect AppState
-- initState = newRef ({} :: AppStateData)

parseInt :: String -> Int
parseInt str = fromMaybe 0 $ fromString str

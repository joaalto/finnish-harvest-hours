module HarvestApi where 

import Affjax (ResponseFormatError)
import Affjax as Ax
import Affjax.ResponseFormat as ResponseFormat
import Data.Argonaut (Json)
import Data.Date (Date, year)
import Data.Either (Either(..))
import Data.Function.Uncurried (runFn1)
import Effect (Effect)
import Effect.Aff.Class (liftAff)
import Effect.Class (liftEffect)
import Effect.Console (logShow)
import Effect.Now (nowDate)
import Helpers (getUserImpl, harvestUrl, startDate)
import Node.Express.Handler (Handler, HandlerM(..), next)
import Node.Express.Response (sendJson)
import Node.Express.Types (Request)
import Prelude (bind, discard, pure, show, ($), (<>))

type Entry = { date :: Date, hours :: Number, taskId :: Int }

-- TODO: format this from today's date
endDate = "2018-11-19"

entriesQuery :: Request -> Effect String
entriesQuery req = do
  today <- nowDate
  logShow $ year today
  user <- liftEffect $ runFn1 getUserImpl req
  liftEffect $ logShow $ "user:" <> show user
  pure $ harvestUrl <>
    "/people/" <> show user.harvestId <>
    "/entries?from=" <> startDate <>
    "&to=" <> endDate <>
    "&access_token=" <> user.accessToken

fetchEntries :: HandlerM (Either ResponseFormatError Json)
fetchEntries = HandlerM \req _ _ -> do
  query <- liftEffect $ entriesQuery req
  liftEffect $ logShow query
  harvestEntries <- liftAff $ Ax.get ResponseFormat.json query
  pure harvestEntries.body 

entriesHandler :: Handler
entriesHandler = do
  resp <- fetchEntries
  case resp of
    Left _ -> next
    Right a -> sendJson a

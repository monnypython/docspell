{-
   Copyright 2020 Eike K. & Contributors

   SPDX-License-Identifier: AGPL-3.0-or-later
-}


module Page.Share.Data exposing (Mode(..), Model, Msg(..), PageError(..), init)

import Api
import Api.Model.ItemLightList exposing (ItemLightList)
import Api.Model.SearchStats exposing (SearchStats)
import Api.Model.ShareSecret exposing (ShareSecret)
import Api.Model.ShareVerifyResult exposing (ShareVerifyResult)
import Comp.ItemCardList
import Comp.PowerSearchInput
import Comp.SearchMenu
import Comp.SharePasswordForm
import Data.Flags exposing (Flags)
import Http


type Mode
    = ModeInitial
    | ModePassword
    | ModeShare


type PageError
    = PageErrorNone
    | PageErrorHttp Http.Error
    | PageErrorAuthFail


type alias Model =
    { mode : Mode
    , verifyResult : ShareVerifyResult
    , passwordModel : Comp.SharePasswordForm.Model
    , pageError : PageError
    , searchMenuModel : Comp.SearchMenu.Model
    , powerSearchInput : Comp.PowerSearchInput.Model
    , searchInProgress : Bool
    , itemListModel : Comp.ItemCardList.Model
    }


emptyModel : Flags -> Model
emptyModel flags =
    { mode = ModeInitial
    , verifyResult = Api.Model.ShareVerifyResult.empty
    , passwordModel = Comp.SharePasswordForm.init
    , pageError = PageErrorNone
    , searchMenuModel = Comp.SearchMenu.init flags
    , powerSearchInput = Comp.PowerSearchInput.init
    , searchInProgress = False
    , itemListModel = Comp.ItemCardList.init
    }


init : Maybe String -> Flags -> ( Model, Cmd Msg )
init shareId flags =
    case shareId of
        Just id ->
            ( emptyModel flags, Api.verifyShare flags (ShareSecret id Nothing) VerifyResp )

        Nothing ->
            ( emptyModel flags, Cmd.none )


type Msg
    = VerifyResp (Result Http.Error ShareVerifyResult)
    | SearchResp (Result Http.Error ItemLightList)
    | StatsResp (Result Http.Error SearchStats)
    | PasswordMsg Comp.SharePasswordForm.Msg
    | SearchMenuMsg Comp.SearchMenu.Msg
    | PowerSearchMsg Comp.PowerSearchInput.Msg
    | ResetSearch
    | ItemListMsg Comp.ItemCardList.Msg

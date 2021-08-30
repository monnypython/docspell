{-
   Copyright 2020 Docspell Contributors

   SPDX-License-Identifier: GPL-3.0-or-later
-}


module Page.UserSettings.Data exposing
    ( Model
    , Msg(..)
    , Tab(..)
    , init
    )

import Comp.ChangePasswordForm
import Comp.EmailSettingsManage
import Comp.ImapSettingsManage
import Comp.NotificationManage
import Comp.OtpSetup
import Comp.ScanMailboxManage
import Comp.UiSettingsManage
import Data.Flags exposing (Flags)
import Data.UiSettings exposing (StoredUiSettings, UiSettings)


type alias Model =
    { currentTab : Maybe Tab
    , changePassModel : Comp.ChangePasswordForm.Model
    , emailSettingsModel : Comp.EmailSettingsManage.Model
    , imapSettingsModel : Comp.ImapSettingsManage.Model
    , notificationModel : Comp.NotificationManage.Model
    , scanMailboxModel : Comp.ScanMailboxManage.Model
    , uiSettingsModel : Comp.UiSettingsManage.Model
    , otpSetupModel : Comp.OtpSetup.Model
    }


init : Flags -> UiSettings -> ( Model, Cmd Msg )
init flags settings =
    let
        ( um, uc ) =
            Comp.UiSettingsManage.init flags settings

        ( otpm, otpc ) =
            Comp.OtpSetup.init flags
    in
    ( { currentTab = Just UiSettingsTab
      , changePassModel = Comp.ChangePasswordForm.emptyModel
      , emailSettingsModel = Comp.EmailSettingsManage.emptyModel
      , imapSettingsModel = Comp.ImapSettingsManage.emptyModel
      , notificationModel = Tuple.first (Comp.NotificationManage.init flags)
      , scanMailboxModel = Tuple.first (Comp.ScanMailboxManage.init flags)
      , uiSettingsModel = um
      , otpSetupModel = otpm
      }
    , Cmd.batch
        [ Cmd.map UiSettingsMsg uc
        , Cmd.map OtpSetupMsg otpc
        ]
    )


type Tab
    = ChangePassTab
    | EmailSettingsTab
    | ImapSettingsTab
    | NotificationTab
    | ScanMailboxTab
    | UiSettingsTab
    | OtpTab


type Msg
    = SetTab Tab
    | ChangePassMsg Comp.ChangePasswordForm.Msg
    | EmailSettingsMsg Comp.EmailSettingsManage.Msg
    | NotificationMsg Comp.NotificationManage.Msg
    | ImapSettingsMsg Comp.ImapSettingsManage.Msg
    | ScanMailboxMsg Comp.ScanMailboxManage.Msg
    | UiSettingsMsg Comp.UiSettingsManage.Msg
    | OtpSetupMsg Comp.OtpSetup.Msg
    | UpdateSettings
    | ReceiveBrowserSettings StoredUiSettings

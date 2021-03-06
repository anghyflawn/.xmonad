import XMonad
import XMonad.Layout
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.UrgencyHook
import XMonad.Util.EZConfig
import XMonad.Util.Run(spawnPipe)
import System.IO
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed
import XMonad.Layout.Renamed
import XMonad.Layout.ThreeColumns
import XMonad.Layout.NoBorders
import XMonad.Actions.NoBorders
import XMonad.Util.Themes
import Graphics.X11
import XMonad.Prompt
import XMonad.Prompt.RunOrRaise
import XMonad.Prompt.Pass

import qualified XMonad.Layout.Dwindle as Dw

myLayoutHook = smartBorders (tiled ||| Mirror tiled ||| tabbed  shrinkText (theme kavonLakeTheme) ||| dwindle ||| multicol )
  where
    tiled = renamed [Replace "Tall"] $ ResizableTall nmaster delta frac []
    nmaster = 1
    delta = 0.03
    frac = 0.5
    dwindle = renamed [Replace "Dwindle"] $ Dw.Dwindle R Dw.CW 1.5 1.1
    multicol = ThreeCol 1 (3/100) (1/2)

myPromptConfig = def { font = "xft:Cousine-12",
                       position = Top,
                       height = 25 }

myKeys = [ 
    ("M-z", sendMessage MirrorShrink),
    ("M-a", sendMessage MirrorExpand),
    ("M-b", sendMessage ToggleStruts),
    ("M-c", spawn "chromium"),
    ("M-y", spawn "~/.local/bin/launch-emacs.sh"),
    ("M-S-y", spawn "systemctl start --user emacs"),
    ("M-p", spawn "dmenu_extended_run"),
    ("<XF86AudioMute>", spawn "amixer -q set Master toggle"),
    ("<XF86PowerOff>", spawn "oblogout"),
    ("<XF86MonBrightnessDown>", spawn "light -U 10"),
    ("<XF86MonBrightnessUp>", spawn "light -A 10"),
    ("M-o", runOrRaisePrompt myPromptConfig ),
    ("M-f", spawn "~/.screenlayout/dual.sh"),
    ("M-S-f", spawn "~/.screenlayout/single.sh"),
    ("M-S-b", withFocused toggleBorder),
    ("M-k", passPrompt myPromptConfig),
    ("M-S-k", passGeneratePrompt myPromptConfig),
    ("M-S-C-k", passRemovePrompt myPromptConfig)]

main = do
  xmproc <- spawnPipe "/usr/bin/xmobar ~/.xmonad/xmobarrc"
  xmonad $ withUrgencyHook NoUrgencyHook $ docks def
    { manageHook = manageDocks <+>
                   composeOne [ isFullscreen -?> doFullFloat,
                                isDialog -?> doCenterFloat,
                                className =? "Oblogout" -?> doFullFloat ] <+>
                   manageHook def,
      layoutHook = avoidStruts $ myLayoutHook,
      logHook = dynamicLogWithPP xmobarPP
                {ppOutput = hPutStrLn xmproc,
                 ppTitle = xmobarColor "green" "" . shorten 90},
      modMask = mod4Mask,
      terminal = "urxvt",
      borderWidth = 2
    } `additionalKeysP` myKeys

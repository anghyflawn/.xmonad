import XMonad
import XMonad.Layout
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Util.EZConfig
import XMonad.Util.Run(spawnPipe)
import System.IO
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed
import XMonad.Layout.Renamed
import XMonad.Layout.ThreeColumns
import XMonad.Layout.NoBorders
import XMonad.Util.Themes
import Graphics.X11
import XMonad.Prompt
import XMonad.Prompt.RunOrRaise

import qualified XMonad.Layout.Dwindle as Dw

myLayoutHook = smartBorders (tiled ||| Mirror tiled ||| tabbed  shrinkText (theme kavonLakeTheme) ||| dwindle ||| multicol )
  where
    tiled = renamed [Replace "Tall"] $ ResizableTall nmaster delta frac []
    nmaster = 1
    delta = 0.03
    frac = 0.5
    dwindle = renamed [Replace "Dwindle"] $ Dw.Dwindle R Dw.CW 1.5 1.1
    multicol = ThreeCol 1 (3/100) (1/2)

myPromptConfig = defaultXPConfig { font = "xft:Inconsolata-12",
                                   position = Top,
                                   height = 22 }


myKeys = [ 
    ("M-z", sendMessage MirrorShrink),
    ("M-a", sendMessage MirrorExpand),
    ("M-b", sendMessage ToggleStruts),
    ("M-c", spawn "chromium"),
    ("M-y", spawn "emacs"),
    ("M-p", spawn "dmenu_extended_run"),
    ("<XF86AudioMute>", spawn "amixer -q set Master toggle"),
    ("M-o", runOrRaisePrompt myPromptConfig ),
    ("M-f", spawn "~/.screenlayout/dual.sh"),
    ("M-S-f", spawn "~/.screenlayout/single.sh") ]

main = do
  xmproc <- spawnPipe "/usr/bin/xmobar ~/.xmobarrc"
  xmonad $ docks def
    { manageHook = manageDocks <+>
                   composeOne [ isFullscreen -?> doFullFloat,
                                isDialog -?> doCenterFloat ] <+>
                   manageHook def,
      layoutHook = avoidStruts $ myLayoutHook,
      logHook = dynamicLogWithPP xmobarPP
                {ppOutput = hPutStrLn xmproc,
                 ppTitle = xmobarColor "green" "" . shorten 90},
      modMask = mod4Mask,
      terminal = "urxvt",
      borderWidth = 2
    } `additionalKeysP` myKeys

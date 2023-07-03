-- xmonad example config file.
--
-- A template showing all available configuration hooks,
-- and how to override the defaults in your own xmonad.hs conf file.
--
-- Normally, you'd only override those defaults you care about.

import Control.Monad (join, when)
import qualified Data.Map as M
import Data.Maybe (maybeToList)
import Data.Monoid ()
import Graphics.X11.ExtraTypes.XF86 (xF86XK_AudioLowerVolume, xF86XK_AudioMute, xF86XK_AudioNext, xF86XK_AudioPlay, xF86XK_AudioPrev, xF86XK_AudioRaiseVolume, xF86XK_MonBrightnessDown, xF86XK_MonBrightnessUp)
import System.Exit ()
import XMonad
import XMonad.Actions.FloatKeys
import XMonad.Hooks.EwmhDesktops (ewmh)
import XMonad.Hooks.ManageDocks
  ( Direction2D (D, L, R, U),
    avoidStruts,
    docks,
    manageDocks,
  )
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.ManageHelpers (doFullFloat, isFullscreen)
import XMonad.Hooks.ServerMode
import XMonad.Layout.Fullscreen
  ( fullscreenEventHook,
    fullscreenFull,
    fullscreenManageHook,
    fullscreenSupport,
  )
import XMonad.Layout.Gaps
  ( Direction2D (D, L, R, U),
    GapMessage (DecGap, IncGap, ToggleGaps),
    gaps,
    setGaps,
  )
import XMonad.Layout.NoBorders
import XMonad.Layout.Spacing (Border (Border), spacingRaw)
import XMonad.Layout.ToggleLayouts
import qualified XMonad.StackSet as W
import XMonad.Util.SpawnOnce (spawnOnce)

-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
myTerminal = "kitty"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
myBorderWidth = 1

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
myModMask = mod4Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
myWorkspaces = ["\63083", "\63288", "\63306", "\61723", "\63107", "\63601", "\63391", "\61713", "\61884"]

-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor = "#3b4252"

myFocusedBorderColor = "#bc96da"

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
firefox = spawn "firefox"

lockscreen = spawn "betterlockscreen -l blur"

myKeys conf@(XConfig {XMonad.modMask = modm}) =
  M.fromList $
    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf),
      -- lock screen
      ((modm, xK_F1), lockscreen),
      -- Audio keys
      ((0, xF86XK_AudioPlay), spawn "playerctl play-pause"),
      ((0, xF86XK_AudioPrev), spawn "playerctl previous"),
      ((0, xF86XK_AudioNext), spawn "playerctl next"),
      ((0, xF86XK_AudioRaiseVolume), spawn "~/bin/volume -i"),
      ((0, xF86XK_AudioLowerVolume), spawn "~/bin/volume -d"),
      ((0, xF86XK_AudioMute), spawn "~/bin/volume -m"),
      -- Brightness keys
      ((0, xF86XK_MonBrightnessUp), spawn "~/bin/bright -i"),
      ((0, xF86XK_MonBrightnessDown), spawn "~/bin/bright -d"),
      -- Screenshot, yet to be implemented

      -- My Stuff
      ((modm, xK_f), firefox),
      ((modm .|. shiftMask, xK_f), sendMessage ToggleLayout), -- full size
      ((modm, xK_p), spawn "setxkbmap latam"),
      ((modm .|. shiftMask, xK_p), spawn "setxkbmap us"),
      ((modm, xK_b), spawn "exec ~/bin/bartoggle"),
      ((modm, xK_z), spawn "exec ~/bin/inhibit_activate"),
      ((modm .|. shiftMask, xK_z), spawn "exec ~/bin/inhibit_deactivate"),
      -- Turn do not disturb on and off
      ((modm, xK_d), spawn "exec ~/bin/do_not_disturb.sh"),
      -- close focused window
      ((modm .|. shiftMask, xK_c), kill),
      -- GAPS!!!
      ((modm .|. controlMask, xK_g), sendMessage ToggleGaps), -- toggle all gaps
      ((modm .|. shiftMask, xK_g), sendMessage $ setGaps [(L, 65), (R, 5), (U, 5), (D, 5)]), -- reset the GapSpec ((modm .|. controlMask, xK_t), sendMessage $ IncGap 10 L), -- increment the left-hand gap
      ((modm .|. shiftMask, xK_t), sendMessage $ DecGap 10 L), -- decrement the left-hand gap
      ((modm .|. controlMask, xK_y), sendMessage $ IncGap 10 U), -- increment the top gap
      ((modm .|. shiftMask, xK_y), sendMessage $ DecGap 10 U), -- decrement the top gap
      ((modm .|. controlMask, xK_u), sendMessage $ IncGap 10 D), -- increment the bottom gap
      ((modm .|. shiftMask, xK_u), sendMessage $ DecGap 10 D), -- decrement the bottom gap
      ((modm .|. controlMask, xK_i), sendMessage $ IncGap 10 R), -- increment the right-hand gap
      ((modm .|. shiftMask, xK_i), sendMessage $ DecGap 10 R), -- decrement the right-hand gap

      -- Rotate through the available layout algorithms
      ((modm, xK_space), sendMessage NextLayout),
      --  Reset the layouts on the current workspace to default
      ((modm .|. shiftMask, xK_space), setLayout $ XMonad.layoutHook conf),
      -- Resize viewed windows to the correct size
      ((modm, xK_n), refresh),
      -- Move focus to the next window
      ((modm, xK_Tab), windows W.focusDown),
      -- Move focus to the next window
      ((modm, xK_j), windows W.focusDown),
      -- Move focus to the previous window
      ((modm, xK_k), windows W.focusUp),
      -- Move focus to the master window
      ((modm, xK_m), windows W.focusMaster),
      -- Swap the focused window and the master window
      ((modm, xK_Return), windows W.swapMaster),
      -- Swap the focused window with the next window
      ((modm .|. shiftMask, xK_j), windows W.swapDown),
      -- Swap the focused window with the previous window
      ((modm .|. shiftMask, xK_k), windows W.swapUp),
      -- Shrink the master area
      ((modm, xK_h), sendMessage Shrink),
      -- Expand the master area
      ((modm, xK_l), sendMessage Expand),
      -- Push window back into tiling
      ((modm, xK_t), withFocused $ windows . W.sink),
      -- Increment the number of windows in the master area
      ((modm, xK_comma), sendMessage (IncMasterN 1)),
      -- Deincrement the number of windows in the master area
      ((modm, xK_period), sendMessage (IncMasterN (-1))),
      -- Toggle the status bar gap
      -- Use this binding with avoidStruts from Hooks.ManageDocks.
      -- See also the statusBar function from Hooks.DynamicLog.
      --
      -- , ((modm              , xK_b     ), sendMessage ToggleStruts)

      -- Quit xmonad
      ((modm .|. shiftMask, xK_q), spawn "~/bin/powermenu.sh"),
      -- Restart xmonad
      ((modm, xK_q), spawn "~/bin/restart")
    ]
      ++
      --
      -- mod-[1..9], Switch to workspace N
      -- mod-shift-[1..9], Move client to workspace N
      --
      [ ((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9],
          (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]
      ]
      ++
      --
      -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
      -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
      --
      [ ((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0 ..],
          (f, m) <- [(W.view, 0), (W.shift, shiftMask)]
      ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
myLayout = avoidStruts (toggleLayouts Full $ tiled ||| Mirror tiled ||| Full)
  where
    -- default tiling algorithm partitions the screen into two panes
    tiled = Tall nmaster delta ratio

    -- The default number of windows in the master pane
    nmaster = 1

    -- Default proportion of screen occupied by master pane
    ratio = 1 / 2

    -- Percent of screen to increment by when resizing panes
    delta = 3 / 100

------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.

myManageHook =
  fullscreenManageHook
    <+> manageDocks
    <+> composeAll
      [ className =? "Discord" --> doShift "5",
        className =? "MPlayer" --> doFloat,
        className =? "Gimp" --> doFloat,
        className =? "Ulauncher" --> doFloat,
        className =? "megasync" --> doFloat,
        className =? "Picture-inPicture" <||> resource =? "Toolkit" --> doFloat,
        resource =? "desktop_window" --> doIgnore,
        resource =? "kdesktop" --> doIgnore,
        isFullscreen --> doFullFloat
      ]

addNETSupported :: Atom -> X ()
addNETSupported x = withDisplay $ \dpy -> do
  r <- asks theRoot
  a_NET_SUPPORTED <- getAtom "_NET_SUPPORTED"
  a <- getAtom "ATOM"
  liftIO $ do
    sup <- join . maybeToList <$> getWindowProperty32 dpy a_NET_SUPPORTED r
    when (fromIntegral x `notElem` sup) $
      changeProperty32 dpy r a_NET_SUPPORTED a propModeAppend [fromIntegral x]

addEWMHFullscreen :: X ()
addEWMHFullscreen = do
  wms <- getAtom "_NET_WM_STATE"
  wfs <- getAtom "_NET_WM_STATE_FULLSCREEN"
  mapM_ addNETSupported [wms, wfs]

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = do
  spawnOnce "feh --bg-scale ~/wallpapers/wall.jpg"
  spawnOnce "eww daemon"
  spawnOnce "eww -c ~/.config/eww/bar open bar"
  spawnOnce "dropbox -i daemon"
  spawnOnce "redshift"
  spawn "xsetroot -cursor_name left_ptr"
  spawn "exec ~/bin/lock.sh"
  spawnOnce "picom"
  spawnOnce "deadd-notification-center"
  spawnOnce "flameshot"
  spawnOnce "systemctl --user enable --now ulauncher"
  spawn "sleep 15 && trayer --edge left --align center --SetDockType true --SetPartialStrut true --expand true --width 10 --height 18 --iconspacing 5 --distancefrom left --distance 25 --transparent false"
  spawnOnce "copyq"
  spawn "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1"

main = xmonad $ fullscreenSupport $ ewmh defaults

defaults =
  def
    { -- simple stuff
      terminal = myTerminal,
      focusFollowsMouse = myFocusFollowsMouse,
      clickJustFocuses = myClickJustFocuses,
      borderWidth = myBorderWidth,
      modMask = myModMask,
      workspaces = myWorkspaces,
      normalBorderColor = myNormalBorderColor,
      focusedBorderColor = myFocusedBorderColor,
      -- key bindings
      keys = myKeys,
      -- hooks, layouts
      manageHook = myManageHook,
      layoutHook = gaps [(L, 65), (R, 5), (U, 5), (D, 5)] $ spacingRaw True (Border 0 0 0 0) True (Border 0 0 0 0) True $ smartBorders $ myLayout,
      -- logHook            = myLogHook,
      startupHook = myStartupHook >> addEWMHFullscreen
    }

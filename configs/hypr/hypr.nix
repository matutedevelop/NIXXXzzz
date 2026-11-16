{ config, pkgs, ... }:
{
  #  <==><==><==> <==><==><==><==><==><==><==><==><==><==><==><==> <==><==><==>
  # __________________
  #< hyprland config (Lua, Hyprland >= 0.57) >
  # ------------------
  #        \   ^__^
  #         \  (oo)\_______
  #            (__)\       )\/\
  #                ||----w |
  #                ||     ||

  wayland.windowManager.hyprland = {
    enable = true;

    # Hyprland 0.57 ya NO lee hyprland.conf, solo hyprland.lua
    configType = "lua";

    # Todo el config va en Lua crudo. Ojo: en strings '' '' de Nix,
    # si algun dia necesitas escribir ${ literal, ponlo como ''${
    extraConfig = ''
      local mod = "SUPER"

      ---------------------------------------------------------------
      -- Autostart (antes exec-once)
      ---------------------------------------------------------------
      hl.on("hyprland.start", function()
        hl.exec_cmd("swaync")
        hl.exec_cmd("waybar")
        hl.exec_cmd("hyprpaper")
        hl.exec_cmd("set-wallpaper")
        hl.exec_cmd("hypridle")
        hl.exec_cmd("hyprlock")
      end)

      ---------------------------------------------------------------
      -- Monitor
      ---------------------------------------------------------------
      hl.monitor({
        output   = "eDP-1",
        mode     = "2560x1600@240",
        position = "0x0",
        scale    = 1,
      })

      ---------------------------------------------------------------
      -- Input / General / Decoration
      ---------------------------------------------------------------
      hl.config({
        input = {
          kb_layout  = "us,es",
          kb_variant = "",
          kb_options = "grp:alt_shift_toggle",
          touchpad = {
            natural_scroll = true,
            tap_to_click   = true,   -- antes tap-to-click
            drag_lock      = 1,      -- ahora es numero (0 off, 1 on, 2 sticky)
          },
        },

        general = {
          border_size      = 1,
          gaps_in          = 30,
          gaps_out         = 100,
          gaps_workspaces  = 3,
          resize_on_border = true,
          col = {
            inactive_border = { colors = { "rgb(0,0,0)", "rgb(120,120,120)" }, angle = 120 },
            active_border   = { colors = { "rgb(100,100,100)", "rgb(0,0,0)" }, angle = 120 },
          },
        },

        decoration = {
          rounding           = 5,
          rounding_power     = 3,
          inactive_opacity   = 0.5,
          active_opacity     = 0.8,
          fullscreen_opacity = 1,
          blur = {
            enabled           = true,
            size              = 6,
            passes            = 4,
            noise             = 0.05,
            ignore_opacity    = true,
            new_optimizations = true,
            xray              = false,
            popups            = true,
          },
        },

        animations = { enabled = true },
      })

      ---------------------------------------------------------------
      -- Animaciones
      ---------------------------------------------------------------
      hl.curve("smooth",  { type = "bezier", points = { {0.25, 0.1}, {0.25, 1.0} } })
      hl.curve("springy", { type = "bezier", points = { {0.05, 0.7}, {0.1,  1.0} } })

      hl.animation({ leaf = "windows",    enabled = true, speed = 3, bezier = "smooth",  style = "slide" })
      hl.animation({ leaf = "border",     enabled = true, speed = 3, bezier = "smooth" })
      hl.animation({ leaf = "fade",       enabled = true, speed = 5, bezier = "smooth" })
      hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "springy", style = "slidevert" })

      ---------------------------------------------------------------
      -- Layer rules (swaync + rofi)
      ---------------------------------------------------------------
      for _, ns in ipairs({ "swaync-notification-window", "swaync-control-center" }) do
        hl.layer_rule({ match = { namespace = ns }, animation = "slide", blur = true, ignore_alpha = 0.5 })
      end
      hl.layer_rule({ match = { namespace = "rofi" }, animation = "popin", blur = true, ignore_alpha = 0.5 })

      ---------------------------------------------------------------
      -- Binds
      ---------------------------------------------------------------
      local exec = hl.dsp.exec_cmd

      -- bindr (se dispara al soltar)
      hl.bind("SUPER + SHIFT + Control_R",
        exec("rofi -show calc -modi calc -no-show-match -no-sort"), { release = true })

      hl.bind(mod .. " + F",         exec("zen"))
      hl.bind(mod .. " + B",         exec("waybar"))
      hl.bind("SHIFT + B",           exec("pkill waybar"))  -- ojo: esto se come la B mayuscula al escribir
      hl.bind(mod .. " + SHIFT + M", exec("pactl set-sink-mute @DEFAULT_SINK@ toggle"))
      hl.bind(mod .. " + T",         exec("wezterm"))
      hl.bind(mod .. " + SHIFT + S", exec("hyprshot -m region"))
      hl.bind("ALT + SPACE",         exec("rofi -show drun"))
      hl.bind(mod .. " + Q",         hl.dsp.window.close())
      hl.bind("ALT + Tab",           exec("rofi -show window"))
      hl.bind(mod .. " + SHIFT + E", exec("rofi -show filebrowser"))
      hl.bind(mod .. " + E",         exec("nemo"))
      hl.bind(mod .. " + M",         exec("rofi-audio"))
      hl.bind(mod .. " + L",         exec("hyprlock"))
      hl.bind(mod .. " + left",      exec("playerctl previous"))
      hl.bind(mod .. " + right",     exec("playerctl next"))
      hl.bind(mod .. " + R",         exec("hyprshade on /home/arroio/.config/hypr/shaders/readmode.glsl"))
      hl.bind(mod .. " + K",         exec("rofi-bluetooth"))
      hl.bind(mod .. " + up",        exec("pactl set-sink-volume @DEFAULT_SINK@ +15%"))
      hl.bind(mod .. " + down",      exec("pactl set-sink-volume @DEFAULT_SINK@ -15%"))
      hl.bind("ALT + up",            exec("brightnessctl --device=intel_backlight set +10%"))
      hl.bind("ALT + down",          exec("brightnessctl --device=intel_backlight set 10%-"))

      -- Navegacion (ojo: SHIFT+H/J/K/L te bloquea escribir esas mayusculas)
      hl.bind("SHIFT + H", hl.dsp.focus({ direction = "left" }))
      hl.bind("SHIFT + J", hl.dsp.focus({ direction = "down" }))
      hl.bind("SHIFT + K", hl.dsp.focus({ direction = "up" }))
      hl.bind("SHIFT + L", hl.dsp.focus({ direction = "right" }))

      -- Redimensionar
      hl.bind(mod .. " + CTRL + h", hl.dsp.window.resize({ x = -50, y = 0,   relative = true }))
      hl.bind(mod .. " + CTRL + l", hl.dsp.window.resize({ x = 50,  y = 0,   relative = true }))
      hl.bind(mod .. " + CTRL + k", hl.dsp.window.resize({ x = 0,   y = -50, relative = true }))
      hl.bind(mod .. " + CTRL + j", hl.dsp.window.resize({ x = 0,   y = 50,  relative = true }))

      -- Mover ventanas
      hl.bind("ALT + H", hl.dsp.window.move({ direction = "left" }))
      hl.bind("ALT + J", hl.dsp.window.move({ direction = "down" }))
      hl.bind("ALT + K", hl.dsp.window.move({ direction = "up" }))
      hl.bind("ALT + L", hl.dsp.window.move({ direction = "right" }))

      hl.bind(mod .. " + 0", hl.dsp.window.fullscreen())
      hl.bind(mod .. " + p", hl.dsp.window.float({ action = "toggle" }))

      -- Workspaces 1-9 por keycode (code:10 .. code:18)
      for i = 1, 9 do
        local key = "code:" .. (9 + i)
        hl.bind(mod .. " + " .. key,             hl.dsp.focus({ workspace = i }))
        hl.bind(mod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
      end

      ---------------------------------------------------------------
      -- Gestos
      ---------------------------------------------------------------
      local function run(cmd) return function() hl.exec_cmd(cmd) end end

      hl.gesture({ fingers = 3, direction = "vertical", action = "workspace" })
      hl.gesture({ fingers = 4, direction = "left",  action = run("playerctl previous") })
      hl.gesture({ fingers = 4, direction = "right", action = run("playerctl next") })
      hl.gesture({ fingers = 4, direction = "up",    action = run("playerctl volume 0") })
      hl.gesture({ fingers = 4, direction = "down",  action = "float" })  -- antes era "exec togglefloating", que no hacia nada
      hl.gesture({ fingers = 3, direction = "right", action = run("playerctl volume .2+") })
      hl.gesture({ fingers = 3, direction = "left",  action = run("playerctl volume .2-") })
    '';
  };

  # Hyprland ya genero su hyprland.lua default; esto deja que home-manager lo pise
  # en vez de fallar con "existing file is in the way".
  xdg.configFile."hypr/hyprland.lua".force = true;

  home.sessionVariables.NIXOS_OZONE_WL = "1";

  #  <==><==><==> <==><==><==><==><==><==><==><==><==><==><==><==> <==><==><==>
  # __________________
  #< End hyprland config >
  # ------------------
  #        \   ^__^
  #         \  (oo)\_______
  #            (__)\       )\/\
  #                ||----w |
  #                ||     ||
}


#oldie
# { config, pkgs, ... }:
# {
#
#   #  <==><==><==> <==><==><==><==><==><==><==><==><==><==><==><==> <==><==><==> 
#
#   #  <==><==><==> <==><==><==><==><==><==><==><==><==><==><==><==> <==><==><==> 
#
#   #  <==><==><==> <==><==><==><==><==><==><==><==><==><==><==><==> <==><==><==> 
#   # __________________
#   #< hyperland config >
#   # ------------------
#   #        \   ^__^
#   #         \  (oo)\_______
#   #            (__)\       )\/\
#   #                ||----w |
#   #                ||     ||
#   wayland.windowManager.hyprland = {
#     enable = true;
#
#     configType = "hyprlang";
#
#
#     settings = {
#       "$mod" = "SUPER";
#
#
#
#
#
#
#       exec-once = [
#         "swaync"
#         "waybar"
#         "hyprpaper"
#         "set-wallpaper"
#         "hypridle"
#         "hyprlock"
#       ];
#
#       # Monitor config
#       monitor = "eDP-1, 2560x1600@240, 0x0,1";
#
#       # === === === === === === === === === === === === === === === === === === 
#       # General === === === === === === === === === === === === === === === === 
#       # === === === === === === === === === === === === === === === === === === 
#
#       input = {
#         kb_layout = "us,es";
#         kb_variant = "";
#         kb_options = "grp:alt_shift_toggle";
#       };
#
#
#
#
#
#       general = {
#
#
#
#
#         "border_size" = "1";
#
#         "gaps_in" = "30";
#
#         "gaps_out" = "100";
#
#         "gaps_workspaces" = "3";
#
#         "resize_on_border" = "true";
#
#         #"col.inactive_border" = "rgba(0,0,0,75) rgba(123,135,135,90) 60deg";
#         "col.inactive_border" = "rgb(0,0,0) rgb(120,120,120) 120deg";
#
#
#         "col.active_border" = "rgb(100,100,100) rgb(0,0,0) 120deg";
#
#       };
#
#
#
#       # === === === === === === === === === === === === === === === === === === 
#       # Decoration === === === === === === === === === === === === === === === === 
#       # === === === === === === === === === === === === === === === === === === 
#
#       decoration = {
#
#         "rounding" = "5";
#
#         "rounding_power" = "3";
#
#         "inactive_opacity" = "0.5";
#
#         "active_opacity" = "0.8";
#
#         "fullscreen_opacity" = "1";
#
#         blur = {
#
#           "enabled" = "true";
#           "size" = "6";
#           "passes" = "4";
#           "noise" = ".05";
#           "ignore_opacity" = "true";
#           "new_optimizations" = "true";
#           "xray" = "false";
#           "popups" = "true";
#
#
#         };
#
#       };
#
#
#
#
#
#
#       animations = {
#         enabled = "yes";
#
#         bezier = [
#           "smooth, 0.25, 0.1, 0.25, 1.0"
#           "springy, 0.05, 0.7, 0.1, 1.0"
#         ];
#
#         animation = [
#           "windows, 1, 3, smooth, slide"
#           "border, 1, 3, smooth"
#           "fade, 1, 5, smooth"
#           "workspaces, 1, 4, springy, slidevert"
#         ];
#       };
#
#
#       # windowrule = [
#       #   "opacity 0.9 0.5, ^(discord)$"
#       #   "opacity 0.7 0.4, ^(zathura)$"
#       #   "opacity 1.0 1.0, ^(dataspell)$"
#       #   "opacity 0.7 0.5, ^(Spotify)$"
#       #   "opacity 0.8 1.0, ^(wezterm)$"
#       # ];
#
#
#
#
#
#       layerrule = [
#         "animation slide, match:namespace swaync-notification-window"
#         "blur on, match:namespace  swaync-notification-window"
#         "ignore_alpha 0.5, match:namespace swaync-notification-window"
#         "animation slide, match:namespace swaync-control-center"
#         "blur on, match:namespace swaync-control-center"
#         "ignore_alpha 0.5, match:namespace swaync-control-center"
#         "animation popin, match:namespace rofi"
#         "blur on, match:namespace rofi"
#         "ignore_alpha 0.5, match:namespace rofi"
#       ];
#
#
#
#       bindr = [
#         "SUPER_SHIFT, Control_R, exec, rofi -show calc -modi calc -no-show-match -no-sort"
#       ];
#
#       bind = [
#         "$mod,F, exec, zen"
#         "$mod,B, exec, waybar"
#         "SHIFT,B, exec, pkill waybar"
#         "$mod SHIFT,M, exec, pactl set-sink-mute @DEFAULT_SINK@ toggle"
#         "$mod,T, exec, wezterm"
#         "$mod SHIFT,S, exec, hyprshot -m region"
#         "ALT, SPACE, exec, rofi -show drun"
#         "$mod,Q, killactive"
#         "ALT, Tab, exec, rofi -show window"
#         "$mod SHIFT,E, exec, rofi -show filebrowser"
#         "$mod,E, exec,  nemo"
#         "$mod,M, exec, rofi-audio"
#         "$mod,L, exec, hyprlock"
#         "$mod,left, exec, playerctl previous"
#         "$mod,right, exec, playerctl next"
#         "$mod, R, exec, hyprshade on /home/arroio/.config/hypr/shaders/readmode.glsl"
#         "$mod, K, exec, rofi-bluetooth"
#         "$mod,up, exec, pactl set-sink-volume @DEFAULT_SINK@ +15%"
#         "$mod,down, exec, pactl set-sink-volume @DEFAULT_SINK@ -15%"
#         "ALT, up, exec, brightnessctl --device=intel_backlight set +10%"
#         "ALT, down, exec, brightnessctl --device=intel_backlight set 10%-"
#
#         # Dispatchers === === === === === === ===
#
#
#         # Navegacion <==> <==> <==> <==> <==>
#         "SHIFT, H, movefocus, l"
#         "SHIFT, J, movefocus, d"
#         "SHIFT, K, movefocus, u"
#         "SHIFT, L, movefocus, r"
#
#
#
#
#
#         # Mover ventanas <==> <==> <==> <==> <==>
#
#
#         "$mod CTRL, h, resizeactive, -50 0"
#         "$mod CTRL, l, resizeactive, 50 0"
#         "$mod CTRL, k, resizeactive, 0 -50"
#         "$mod CTRL, j, resizeactive, 0 50"
#
#
#         # Mover ventanas <==> <==> <==> <==> <==>
#
#         "ALT, H, movewindow, l"
#         "ALT, J, movewindow, d"
#         "ALT, K, movewindow, u"
#         "ALT, L, movewindow, r"
#
#         "$mod, 0, fullscreen"
#         "$mod, p, togglefloating"
#
#         # Scroll con flechas
#
#         #         "CONTROL, down, exec, wlrctl pointer scroll 120 0 "
#         #         "CONTROL, up, exec, wlrctl pointer scroll -120 0"
#
#
#         # Move to workspace
#         #"$mod ALT, 1, movetoworkspace, 1"
#         #"$mod ALT, 2, movetoworkspace, 2"
#         #"$mod ALT, 3, movetoworkspace, 3"
#         #"$mod ALT, 4, movetoworkspace, 4"
#         #"$mod ALT, 5, movetoworkspace, 5"
#         #"$mod ALT, 6, movetoworkspace, 6"
#         #"$mod ALT, 7, movetoworkspace, 7"
#         #"$mod ALT, 8, movetoworkspace, 8"
#         #"$mod ALT, 9, movetoworkspace, 9"
#
#
#
#
#       ] ++ (
#         builtins.concatLists (builtins.genList
#           (i:
#             let
#               ws = i + 1;
#             in
#             [
#               "$mod, code:1${toString i}, workspace, ${toString ws}"
#               "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
#               #"ALT, comma, code:1${toString i}, movetoworkspace, ${toString ws}"
#
#               # "$mod, ${toString ws}, workspace, ${toString ws}"
#               # "$mod SHIFT, ${toString ws}, movetoworkspace, ${toString ws}"
#
#             ])
#           9)
#       );
#
#
#       input.touchpad = {
#         natural_scroll = true;
#         tap-to-click = true;
#         drag_lock = true;
#       };
#
#       gesture = [
#
#         "3,vertical,workspace"
#         "4,left,dispatcher,exec, playerctl previous"
#         "4,right,dispatcher,exec, playerctl next"
#         "4,up,dispatcher,exec, playerctl volume 0"
#         "4,down,dispatcher,exec, togglefloating"
#         "3,right,dispatcher,exec, playerctl volume .2+"
#         "3,left,dispatcher,exec, playerctl volume .2-"
#
#       ];
#
#
#
#
#
#
#
#
#
#     };
#   };
#
#   home.sessionVariables.NIXOS_OZONE_WL = "1";
#
#
#
#
#
#   #  <==><==><==> <==><==><==><==><==><==><==><==><==><==><==><==> <==><==><==> 
#   # __________________
#   #< End hyperland config >
#   # ------------------
#   #        \   ^__^
#   #         \  (oo)\_______
#   #            (__)\       )\/\
#   #                ||----w |
#   #                ||     ||
#
# }

{ pkgs }:


pkgs.writeShellScriptBin "set-wallpaper" ''
      export HOME="''${HOME:-/home/arroio}"

      # Si se pasa un argumento y el archivo existe, usa ese; de lo contrario, elige uno al azar.
      if [ -n "$1" ] && [ -f "$1" ]; then
        WALLPAPER="$1"
      else
        WALLPAPER=$(${pkgs.findutils}/bin/find "$HOME/Pictures/Wallpapers" -type f \( -iname "*.jpg" -o -iname "*.png" \) | ${pkgs.coreutils}/bin/shuf -n 1)
      fi

      if [ -z "$WALLPAPER" ]; then
        echo "No wallpaper found!" >> /tmp/hyprpaper.log
        exit 1
      fi

      echo "Selected wallpaper: $WALLPAPER" >> /tmp/hyprpaper.log
      # ${pkgs.procps}/bin/pgrep hyprpaper >/dev/null || hyprpaper & sleep .5
      # ${pkgs.hyprland}/bin/hyprctl hyprpaper preload "$WALLPAPER"
      # ${pkgs.hyprland}/bin/hyprctl hyprpaper wallpaper ",$WALLPAPER"
     if ! ${pkgs.procps}/bin/pgrep -x hyprpaper >/dev/null; then
        hyprpaper & disown
      fi

      # Espera hasta ~10 s a que hyprpaper acepte comandos
      for _ in $(seq 1 50); do
        ${pkgs.hyprland}/bin/hyprctl hyprpaper preload "$WALLPAPER" >/dev/null 2>&1
        OUT=$(${pkgs.hyprland}/bin/hyprctl hyprpaper wallpaper ",$WALLPAPER" 2>&1)
        if [ "$OUT" = "ok" ]; then
          echo "Wallpaper aplicado" >> /tmp/hyprpaper.log
          break
        fi
        sleep 0.2
      done
      [ "$OUT" = "ok" ] || echo "hyprpaper no respondió: $OUT" >> /tmp/hyprpaper.log

      export PATH="${pkgs.matugen}/bin:${pkgs.expect}/bin:${pkgs.rofi}/bin:${pkgs.gnused}/bin:${pkgs.gnugrep}/bin:$PATH"
      LOGFILE=/tmp/matugen.log

      EXPECT_SCRIPT=$(mktemp)
      cat > "$EXPECT_SCRIPT" <<'EOF'
      log_user 0
      set timeout 5
      spawn matugen image [lindex $argv 0] --type scheme-fidelity
      expect -re "Enter to select:\r\n(.*)"
      set raw $expect_out(1,string)
      send_user "$raw"
      send "\x03"
      expect eof
  EOF

      RAW=$(expect "$EXPECT_SCRIPT" "$WALLPAPER")
      rm -f "$EXPECT_SCRIPT"

      mapfile -t COLORS < <(echo "$RAW" | sed -r 's/\x1B\[[0-9;]*[a-zA-Z]//g' | grep -oE '#[0-9a-fA-F]{6}')

      if [ "''${#COLORS[@]}" -eq 0 ]; then
        matugen image "$WALLPAPER" --type scheme-fidelity --source-color-index 0 --fallback-color "#808080" > "$LOGFILE" 2>&1
      else
        # Creamos un arreglo con las opciones formateadas con marcado Pango
        ROFI_OPTS=()
        for c in "''${COLORS[@]}"; do
          # El span dibujará el fondo de color y luego añadimos el código hexadecimal
          ROFI_OPTS+=("<span background='$c'>      </span> $c")
        done

        # Pasamos -markup-rows para que Rofi interprete el HTML/Pango
        CHOICE=$(printf '%s\n' "''${ROFI_OPTS[@]}" | rofi -dmenu -markup-rows -p "Color fuente")

        # Rofi devuelve la línea completa, así que extraemos solo el color hex
        CHOSEN_COLOR=$(echo "$CHOICE" | grep -oE '#[0-9a-fA-F]{6}')

        if [ -n "$CHOSEN_COLOR" ]; then
          INDEX=0
          for i in "''${!COLORS[@]}"; do
            if [ "''${COLORS[$i]}" = "$CHOSEN_COLOR" ]; then
              INDEX=$i
              break
            fi
          done
          matugen image "$WALLPAPER" --type scheme-fidelity --source-color-index "$INDEX" > "$LOGFILE" 2>&1
        else
          # Si el usuario presiona Escape (CHOICE vacío), usamos el índice 0 por defecto
          matugen image "$WALLPAPER" --type scheme-fidelity --source-color-index 0 > "$LOGFILE" 2>&1
        fi
      fi

      ${pkgs.procps}/bin/pkill waybar
      waybar & disown
''

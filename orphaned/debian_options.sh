read_param "Do you want to install and enable pulseaudio? (Y/n): " '' pulseaudio yes_or_no
read_param "Do you want to install and enable bluetooth? (Y/n): " '' bluetooth yes_or_no
read_param "Do you want to add printers support? (Y/n): " '' printers yes_or_no

#---

if [[ $graphics == "1" ]]; then
  msg_print note "Wayland is not supported now. Do NOT choose it."
  while ! [[ $graphics_type == "xorg" || $graphics_type == "wayland" ]]; do
    read_param "Enter type of graphics (xorg/wayland): " "xorg" graphics_type text
  done
  msg_print note "DE - Desktop environment, WM - window manager, M - manual."
  while ! [[ $desktop_type == "DE" || $desktop_type == "WM" || $desktop_type == "M" ]]; do
    read_param "Enter desktop type (DE/WM/M): " "DE" desktop_type text
  done
  if [[ $desktop_type != "M" ]]; then
    if [[ $graphics_type == "xorg" ]]; then
      if [[ $desktop_type == "DE" ]]; then
        msg_print note "Avaliable DEs: plasma, xfce4, cinnamon, gnome."
        read_param "Enter DE name: " "xfce4" desktop_de text
      else
        msg_print note "Avaliable WMs: icewm, fvwm, jvm."
        read_param "Do you want to install addational software: " "icewm" desktop_wm text
      fi
    else
      return_err "Wayland is not supported now!"
    fi
    msg_print note "Addational software."
    #read_param "Do you want to install firefox? (Y/n): " '' firefox_soft yes_or_no
    #read_param "Do you want to install chromium? (Y/n): " '' chromium_soft yes_or_no
    #read_param "Do you want to install office software? (Y/n): " '' office_soft yes_or_no
    #read_param "Do you want to install administration software? (Y/n): " '' admin_soft yes_or_no
  else
    read_param "Enter desktop package(s) or nothing: " "xfce4 xfce4-goodies" desktop_packages text_empty
  fi
  [[ $dm_install == "0" ]] && msg_print note "Default DM will be disabled."
fi
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, options, ... }:

# let
#   extensions = (with pkgs.vscode-extensions; [
#       bbenoist.Nix
#       ms-azuretools.vscode-docker
#       ms-vscode-remote.remote-ssh
#     ]) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [{
#       name = "remote-ssh-edit";
#       publisher = "ms-vscode-remote";
#       version = "0.47.2";
#       sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g";
#   }];
#   vscode-with-extensions = pkgs.vscode-with-extensions.override {
#     vscodeExtensions = extensions;
#   };
# in
let
  username = "burkostya";
  terminal = "hyper";
in
{
  imports = [ 
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    <home-manager/nixos>
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "nodev";

  time.timeZone = "Europe/Moscow";

  networking = {
    hostName = "thinkpad";
    networkmanager.enable = true;
    useDHCP = false;
    interfaces.enp0s31f6.useDHCP = true;
    interfaces.wlp4s0.useDHCP = true;
    interfaces.wwp0s20f0u6i12.useDHCP = true;
    nameservers = [ "8.8.8.8" "1.1.1.1" "9.9.9.9" ];
    timeServers = options.networking.timeServers.default;
  };

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "vscode"
    "slack" "skypeforlinux"
    "obsidian"
    "vista-fonts"
  ];
  services = {
    dbus = {
      enable = true;
      packages = [ pkgs.gnome3.dconf ];
    };
    xserver = {
      enable = true;
      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
          i3lock
        ];
      };
      layout = "us, ru";
      xkbOptions = "grp:caps_toggle";
      libinput = {
        enable = true;
        touchpad.disableWhileTyping = true;
      };
    };

    # TODO: research options
    picom.enable = true;
    unclutter-xfixes.enable = true;
    printing.enable = true;
    gnome3.gnome-keyring.enable = true;

    upower.enable = true;
  };

  systemd.services.upower.enable = true;

  # Enable sound.
  sound.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget vim git firefox gosu ntp
    jack2
    python39
    graphviz
    unifont
  ] ++ [
    # vscode-with-extensions
  ];

  # disable root
  users.users.root.hashedPassword = "*";

  users.mutableUsers = false;
  users.users."${username}" = {
    passwordFile = "/etc/nixos/nixos.password";
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    uid = 1000;
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users."${username}" = { config, lib, pkgs, ... }: {
    home.packages = with pkgs; [
      font-awesome-ttf
      material-design-icons fira-code fira-code-symbols 
      siji vistafonts twemoji-color-font roboto roboto-mono liberation_ttf ttf_bitstream_vera 
      noto-fonts noto-fonts-emoji nerdfonts
      betterlockscreen
      hyper
      tdesktop slack skype
      pavucontrol
      obsidian
    ];
    services = {
      flameshot.enable = true;
      polybar = {
        enable = true;
        script = "polybar top &";
        settings = {
          colors = {
            background.text = "#222";
            background.alt = "#444";
            foreground.text = "#dfdfdf";
            foreground.alt = "#555";
            primary = "#ffb52a";
            secondary = "#e60053";
            alert = "#bd2c40";
            blue = "#7aa6da";
            red = "#d54e53";
          };
          "bar/top" = {
            monitor = "\${env:MONITOR:eDP1}";
            width = "100%";
            height = 48;
            dpi = 192;
            radius = 0;
            fixed.center = false;
            background = "\${colors.background}";
            foreground = "\${colors.foreground}";
            line.size = 3;
            line.color = "#f00";
            border.size = 0;
            border.color = "#00000000";
            padding.left = 0;
            padding.right = 1;
            module.margin.left = 1;
            module.margin.right = 2;
            font = [
              "fixed:pixelsize=10;1"
              "Symbols Nerd Font:size=10;1"
              "Noto Sans Symbols2:size=8;0"
              "Material Design Icons:size=8;0"
              "Font Awesome 5 Brands:size=8;0"
              "Font Awesome 5 Free:size=8;0"
              "Font Awesome 5 Free Solid:size=8;0"
              "Siji:pixelsize=10;1"
            ];
            modules.left = "i3";
            modules.right = "filesystem volume xkeyboard memory cpu eth temperature date battery";
            tray.position = "right";
            tray.padding = 2;
            tray.maxsize = 32;
            cursor.click = "pointer";
            cursor.scroll = "ns-resize";
          };
          "module/xwindow" = {
            type = "internal/xwindow";
            label = "%title:0:30:...%";
          };
          "module/xkeyboard" = {
            type = "internal/xkeyboard";
            format.text = "<label-indicator>";
            format.prefix.foreground = "\${colors.foreground-alt}";
            format.prefix.underline = "\${colors.secondary}";
            label.indicator.padding = 2;
            label.indicator.margin = 1;
            label.indicator.background = "\${colors.secondary}";
            label.indicator.underline = "\${colors.secondary}";
          };
          "module/filesystem" = {
            type = "internal/fs";
            interval = 25;
            mount = [ "/" ];
            label.mounted = "%{F#0a81f5}%mountpoint%%{F-}: %percentage_used%%";
            label.unmounted.text = "%mountpoint% not mounted";
            label.unmounted.foreground = "\${colors.foreground-alt}";
          };
          "module/i3" = {
            type = "internal/i3";
            format = "<label-state> <label-mode>";
            index.sort = true;
            wrapping.scroll = false;
            label.mode.padding = 2;
            label.mode.foreground = "#000";
            label.mode.background = "\${colors.primary}";
            label.focused.text = "%name%";
            label.focused.background = "\${colors.background-alt}";
            label.focused.underline = "\${colors.primary}";
            label.focused.padding = 2;
            label.unfocused.text = "%name%";
            label.unfocused.padding = 2;
            label.visible.text = "%name%";
            label.visible.background = "\${self.label-focused-background}";
            label.visible.underline = "\${self.label-focused-underline}";
            label.visible.padding = "\${self.label-focused-padding}";
            label.urgent.text = "%name%";
            label.urgent.background = "\${colors.alert}";
            label.urgent.padding = 2;
          };
          "module/cpu" = {
            type = "internal/cpu";
            interval = 2;
            format.prefix.text = " ";
            format.prefix.foreground = "\${colors.foreground-alt}";
            format.underline = "\${colors.red}";
            label = "%percentage:2%%";
          };
          "module/memory" = {
            type = "internal/memory";
            interval = 2;
            format.prefix.text = " ";
            format.prefix.foreground = "\${colors.foreground-alt}";
            format.underline = "#4bffdc";
            label = "%percentage_used%%";
          };
          "module/eth" = {
            type = "internal/network";
            interface = "enp0s31f6";
            interval = 3.0;
            format.connected.underline = "#55aa55";
            format.connected.prefix.text = " ";
            format.connected.prefix.foreground = "\${colors.foreground-alt}";
            label.connected = "%local_ip%";
          };
          "module/date" = {
            type = "internal/date";
            interval = 1;
            date = "%Y-%m-%d";
            time = "%H:%M:%S";
            format.prefix.text = "";
            format.prefix.foreground = "\${colors.foreground-alt}";
            format.underline = "\${colors.blue}";
            label = "%date% %time%";
          };
          "module/battery" = {
            type = "internal/battery";
            battery = "BAT0";
            adapter = "AC";
          };
          "module/volume" = {
            type = "internal/pulseaudio";
            master.soundcard = "default";
            speaker.soundcard = "default";
            headphone.soundcard = "default";
            master.mixer = "Master";
            speaker.mixer = "Speaker";
            headphone.mixer = "Headphone";
            headphone.id = 9;
            mapped = true;
            format.volume = "<ramp-volume> <label-volume>";
            ramp.volume = [ "🔈" "🔉" "🔊" ];
            label.muted.text = "🔇";
            label.muted.foreground = "#666";
            click.right = "pavucontrol &";
          };
          "module/temperature" = {
            type = "internal/temperature";
            thermal.zone = 0;
            warn.temperature = 60;
            format.text = "<ramp> <label>";
            format.underline = "#f50a4d";
            format.warn.text = "<ramp> <label-warn>";
            format.warn.underline = "\${self.format-underline}";
            label.text = "%temperature-c%";
            label.warn.text = "%temperature-c%";
            label.warn.foreground = "\${colors.secondary}";
            ramp.text = [ "" "" "" ];
            ramp.foreground = "\${colors.foreground-alt}";
          };
          "settings" = {
            screenchange.reload = true;
          };
          "global/wm" = {
            margin.top = 5;
            margin.bottom = 5;
          };
        };
      };
      screen-locker = {
        enable = true;
        inactiveInterval = 300;
        lockCmd = "${pkgs.betterlockscreen}/bin/betterlockscreen -l dim";
        xautolockExtraOptions = [
          "Xautolock.killer: systemctl suspend"
        ];
      };
      picom = {
        enable = true;
        activeOpacity = "1.0";
        inactiveOpacity = "0.8";
        backend = "glx";
        fade = true;
        fadeDelta = 5;
        opacityRule = [ "100:name *= 'i3lock'" ];
        shadow = true;
        shadowOpacity = "0.75";
      };
    };
    programs = {
      ssh = {
        enable = true;
      };
      rofi = {
        enable = true;
        terminal = "${pkgs.hyper}/bin/hyper";
      };
      fish = {
        enable = true;
      };
      autojump = {
        enable = true;
        enableFishIntegration = true;
      };
      git = {
        enable = true;
        userName = "Konstantin Burykin";
        userEmail = "burkostya@gmail.com";
        delta.enable = true;
        extraConfig = {
          core.editor = "vim";
          color = {
            ui = true;
            branch = true;
            diff = true;
            interactive = true;
            status = true;
          };
          push.default = "simple";
        };
      };
      i3status.enable = true;
      alacritty = {
        enable = true;
        settings = {
          env = {
            TERM = "xterm-256color";
          };
          window = {
            dimensions = {
              columns = 80;
              lines = 24;
            };
            dynamic_title = true;
            padding = {
              x = 2;
              y = 2;
            };
            decorations = "full";
          };
          draw_bold_text_with_bright_colors = true;
          font = {
            normal.family = "monospace";
            bold.family = "monospace";
            italic.family = "monospace";
            size = 10.0;
            offset = { x = 0; y = 0; };
            glyph_offset = { x = 0; y = 0; };
            use_thin_strokes = true;
          };
          colors = {
            primary = {
              background = "0x202020";
              foreground = "0xeaeaea";
            };
            cursor = {
              text = "0x000000";
              cursor = "0xffffff";
            };
            normal = {
              black =   "0x000000";
              red =     "0xd54e53";
              green =   "0xb9ca4a";
              yellow =  "0xe6c547";
              blue =    "0x7aa6da";
              magenta = "0xc397d8";
              cyan =    "0x70c0ba";
              white =   "0xffffff";
            };
            bright = {
              black =   "0x666666";
              red =     "0xff3334";
              green =   "0x9ec400";
              yellow =  "0xe7c547";
              blue =    "0x7aa6da";
              magenta = "0xb77ee0";
              cyan =    "0x54ced6";
              white =   "0xffffff";
            };
            dim = {
              black =   "0x333333";
              red =     "0xf2777a";
              green =   "0x99cc99";
              yellow =  "0xffcc66";
              blue =    "0x6699cc";
              magenta = "0xcc99cc";
              cyan =    "0x66cccc";
              white =   "0xdddddd";
            };
          };
          bell = {
            animation = "EaseOutExpo";
            duration = 0;
          };
          background_opacity = 1;
          mouse_bindings = [
            { mouse = "Middle"; action = "PasteSelection"; }
          ];
          mouse = {
            double_click.threshold = 300;
            triple_click.threshold = 300;
          };
          hide_when_typing = false;
          url = {
            launcher = "xdg-open";
            modifiers = "Control";
          };
          scrolling = {
            history = 10000;
            multiplier = 1;
          };
          selection.semantic_escape_chars = ",│`|:\"' ()[]{}<>";
          cursor = {
            style = "Block";
            unfocused_hollow = true;
          };
          live_config_reload = true;
          key_bindings = [
            { key = "V";        mods = "Control|Shift";     action = "Paste";               }
            { key = "C";        mods = "Control|Shift";     action = "Copy";                }
            { key = "Q";        mods = "Command";           action = "Quit";                         }
            { key = "W";        mods = "Command";           action = "Quit";                         }
            { key = "Insert";   mods = "Shift";             action = "PasteSelection";               }
            { key = "Key0";     mods = "Control";           action = "ResetFontSize";                }
            { key = "Equals";   mods = "Control";           action = "IncreaseFontSize";             }
            { key = "Minus";    mods = "Control";           action = "DecreaseFontSize";             }
            { key = "Home";                    chars = "\x1bOH";   mode = "AppCursor";   }
            { key = "Home";                    chars = "\x1b[H";   mode = "~AppCursor";  }
            { key = "End";                     chars = "\x1bOF";   mode = "AppCursor";   }
            { key = "End";                     chars = "\x1b[F";   mode = "~AppCursor";  }
            { key = "PageUp";   mods = "Shift";   chars = "\x1b[5;2~";                   }
            { key = "PageUp";   mods = "Control"; chars = "\x1b[5;5~";                   }
            { key = "PageUp";                  chars = "\x1b[5~";                     }
            { key = "PageDown"; mods = "Shift";   chars = "\x1b[6;2~";                   }
            { key = "PageDown"; mods = "Control"; chars = "\x1b[6;5~";                   }
            { key = "PageDown";                chars = "\x1b[6~";                     }
            { key = "Tab";      mods = "Shift";   chars = "\x1b[Z";                      }
            { key = "Back";                    chars = "\x7f";                        }
            { key = "Back";     mods = "Alt";     chars = "\x1b\x7f";                    }
            { key = "Insert";                  chars = "\x1b[2~";                     }
            { key = "Delete";                  chars = "\x1b[3~";                     }
            { key = "Left";     mods = "Shift";   chars = "\x1b[1;2D";                   }
            { key = "Left";     mods = "Control"; chars = "\x1b[1;5D";                   }
            { key = "Left";     mods = "Alt";     chars = "\x1b[1;3D";                   }
            { key = "Left";                    chars = "\x1b[D";   mode = "~AppCursor";  }
            { key = "Left";                    chars = "\x1bOD";   mode = "AppCursor";   }
            { key = "Right";    mods = "Shift";   chars = "\x1b[1;2C";                   }
            { key = "Right";    mods = "Control"; chars = "\x1b[1;5C";                   }
            { key = "Right";    mods = "Alt";     chars = "\x1b[1;3C";                   }
            { key = "Right";                   chars = "\x1b[C";   mode = "~AppCursor";  }
            { key = "Right";                   chars = "\x1bOC";   mode = "AppCursor";   }
            { key = "Up";       mods = "Shift";   chars = "\x1b[1;2A";                   }
            { key = "Up";       mods = "Control"; chars = "\x1b[1;5A";                   }
            { key = "Up";       mods = "Alt";     chars = "\x1b[1;3A";                   }
            { key = "Up";                      chars = "\x1b[A";   mode = "~AppCursor";  }
            { key = "Up";                      chars = "\x1bOA";   mode = "AppCursor";   }
            { key = "Down";     mods = "Shift";   chars = "\x1b[1;2B";                   }
            { key = "Down";     mods = "Control"; chars = "\x1b[1;5B";                   }
            { key = "Down";     mods = "Alt";     chars = "\x1b[1;3B";                   }
            { key = "Down";                    chars = "\x1b[B";   mode = "~AppCursor";  }
            { key = "Down";                    chars = "\x1bOB";   mode = "AppCursor";   }
            { key = "F1";                      chars = "\x1bOP";                      }
            { key = "F2";                      chars = "\x1bOQ";                      }
            { key = "F3";                      chars = "\x1bOR";                      }
            { key = "F4";                      chars = "\x1bOS";                      }
            { key = "F5";                      chars = "\x1b[15~";                    }
            { key = "F6";                      chars = "\x1b[17~";                    }
            { key = "F7";                      chars = "\x1b[18~";                    }
            { key = "F8";                      chars = "\x1b[19~";                    }
            { key = "F9";                      chars = "\x1b[20~";                    }
            { key = "F10";                     chars = "\x1b[21~";                    }
            { key = "F11";                     chars = "\x1b[23~";                    }
            { key = "F12";                     chars = "\x1b[24~";                    }
            { key = "F1";       mods = "Shift";   chars = "\x1b[1;2P";                   }
            { key = "F2";       mods = "Shift";   chars = "\x1b[1;2Q";                   }
            { key = "F3";       mods = "Shift";   chars = "\x1b[1;2R";                   }
            { key = "F4";       mods = "Shift";   chars = "\x1b[1;2S";                   }
            { key = "F5";       mods = "Shift";   chars = "\x1b[15;2~";                  }
            { key = "F6";       mods = "Shift";   chars = "\x1b[17;2~";                  }
            { key = "F7";       mods = "Shift";   chars = "\x1b[18;2~";                  }
            { key = "F8";       mods = "Shift";   chars = "\x1b[19;2~";                  }
            { key = "F9";       mods = "Shift";   chars = "\x1b[20;2~";                  }
            { key = "F10";      mods = "Shift";   chars = "\x1b[21;2~";                  }
            { key = "F11";      mods = "Shift";   chars = "\x1b[23;2~";                  }
            { key = "F12";      mods = "Shift";   chars = "\x1b[24;2~";                  }
            { key = "F1";       mods = "Control"; chars = "\x1b[1;5P";                   }
            { key = "F2";       mods = "Control"; chars = "\x1b[1;5Q";                   }
            { key = "F3";       mods = "Control"; chars = "\x1b[1;5R";                   }
            { key = "F4";       mods = "Control"; chars = "\x1b[1;5S";                   }
            { key = "F5";       mods = "Control"; chars = "\x1b[15;5~";                  }
            { key = "F6";       mods = "Control"; chars = "\x1b[17;5~";                  }
            { key = "F7";       mods = "Control"; chars = "\x1b[18;5~";                  }
            { key = "F8";       mods = "Control"; chars = "\x1b[19;5~";                  }
            { key = "F9";       mods = "Control"; chars = "\x1b[20;5~";                  }
            { key = "F10";      mods = "Control"; chars = "\x1b[21;5~";                  }
            { key = "F11";      mods = "Control"; chars = "\x1b[23;5~";                  }
            { key = "F12";      mods = "Control"; chars = "\x1b[24;5~";                  }
            { key = "F1";       mods = "Alt";     chars = "\x1b[1;6P";                   }
            { key = "F2";       mods = "Alt";     chars = "\x1b[1;6Q";                   }
            { key = "F3";       mods = "Alt";     chars = "\x1b[1;6R";                   }
            { key = "F4";       mods = "Alt";     chars = "\x1b[1;6S";                   }
            { key = "F5";       mods = "Alt";     chars = "\x1b[15;6~";                  }
            { key = "F6";       mods = "Alt";     chars = "\x1b[17;6~";                  }
            { key = "F7";       mods = "Alt";     chars = "\x1b[18;6~";                  }
            { key = "F8";       mods = "Alt";     chars = "\x1b[19;6~";                  }
            { key = "F9";       mods = "Alt";     chars = "\x1b[20;6~";                  }
            { key = "F10";      mods = "Alt";     chars = "\x1b[21;6~";                  }
            { key = "F11";      mods = "Alt";     chars = "\x1b[23;6~";                  }
            { key = "F12";      mods = "Alt";     chars = "\x1b[24;6~";                  }
            { key = "F1";       mods = "Super";   chars = "\x1b[1;3P";                   }
            { key = "F2";       mods = "Super";   chars = "\x1b[1;3Q";                   }
            { key = "F3";       mods = "Super";   chars = "\x1b[1;3R";                   }
            { key = "F4";       mods = "Super";   chars = "\x1b[1;3S";                   }
            { key = "F5";       mods = "Super";   chars = "\x1b[15;3~";                  }
            { key = "F6";       mods = "Super";   chars = "\x1b[17;3~";                  }
            { key = "F7";       mods = "Super";   chars = "\x1b[18;3~";                  }
            { key = "F8";       mods = "Super";   chars = "\x1b[19;3~";                  }
            { key = "F9";       mods = "Super";   chars = "\x1b[20;3~";                  }
            { key = "F10";      mods = "Super";   chars = "\x1b[21;3~";                  }
            { key = "F11";      mods = "Super";   chars = "\x1b[23;3~";                  }
            { key = "F12";      mods = "Super";   chars = "\x1b[24;3~";                  }
            { key = "PageUp";   action = "ScrollPageUp";   }
            { key = "PageDown"; action = "ScrollPageDown"; }
            { key = "L";        mods = "Control|Shift"; action = "ClearHistory";   }
            { key = "L";        mods = "Control|Shift"; chars = "\x0c";          }
          ];
        };
      };
      vscode = {
        enable = true;
        # package = pkgs.vscodium;
        extensions = with pkgs.vscode-extensions; [
          # "alefragnani.project-manager"
          alygin.vscode-tlaplus
          # "arashsahebolamri.alloy"
          # "atlassian.atlascode"
          bbenoist.Nix
          # "bungcip.better-toml"
          # "casualjim.gotemplate"
          # "dart-code.flutter"
          # "davidnussio.vscode-jq-playground"
          dbaeumer.vscode-eslint
          # "dhoeric.ansible-vault"
          donjayamanne.githistory
          eamodio.gitlens
          # "eg2.tslint"
          # "eg2.vscode-npm-script"
          # "grapecity.gc-excelviewer"
          # "gruntfuggly.todo-tree"
          # hashicorp.terraform
          hookyqr.beautify
          # "humao.rest-client"
          # "joaompinto.vscode-graphviz"
          # "kumar-harsh.graphql-for-vscode"
          # "lunaryorn.fish-ide"
          # "mongodb.mongodb-vscode"
          golang.Go
          ms-azuretools.vscode-docker
          pkief.material-icon-theme
          # "samuelcolvin.jinjahtml"
          skyapps.fish-vscode
          # "svelte.svelte-vscode"
          # "taoyu.prism-language"
          vscodevim.vim
          # "xabikos.JavaScriptSnippets"
          # "zbr.vscode-ansible"
          # "zhuangtongfa.Material-theme"
          # "Zignd.html-css-class-completion"
          # "zxh404.vscode-proto3"
        ];
        userSettings = {
          "window.menuBarVisibility" = "toggle";
          "telemetry.enableTelemetry" = false;
          "telemetry.enableCrashReporter" = false;
          # "window.zoomLevel" = 0.4;
          "window.titleBarStyle" = "custom";
          "explorer.confirmDragAndDrop" = false;
          "gitlens.advanced.messages" = {
            "suppressShowKeyBindingsNotice" = true;
          };
          "workbench.iconTheme" = "material-icon-theme";
          "workbench.colorTheme" = "One Dark Pro";
          "workbench.startupEditor" = "none";
          "vim.useSystemClipboard" = true;
          "vim.insertModeKeyBindings" = [{
            "before" = ["j" "j"];
            "after" = ["<Esc>"];
          }];
          "vim.handleKeys" = {
            "<C-w>" = false;
          };
          "vim.normalModeKeyBindingsNonRecursive" = [
              {
                  "before" = [";"];
                  "commands" = [ "workbench.action.showCommands" ];
              }
              {
                  "before" = ["Z" "Z"];
                  "commands"= [ ":wq" ];
              }
              {
                  "before" = ["q"];
                  "commands" = [ "cursorWordPartRight" ];
              }
              {
                  "before" = ["Q"];
                  "commands" = [ "cursorWordPartStartLeft" ];
              }
              {
                  "before" = ["g" "s"];
                  "commands" = [ "git.stageSelectedRanges" ];
              }
              {
                  "before" = ["g" "c"];
                  "commands" = [ "git.commitStaged" ];
              }
              {
                  "before" = ["g" "p"];
                  "commands" = [ "git.push" ];
              }
          ];
          "git.autofetch" = true;
          "git.confirmSync" = false;
          "editor.fontFamily" = "'Fira Code Retina', 'Material Design Icons', 'Font Awesome 5 Brands', 'Font Awesome 5 Free', 'Font Awesome 5 Free Solid', 'Droid Sans Mono', 'monospace', monospace, 'Droid Sans Fallback'";
          "editor.fontLigatures" = true;
          "editor.fontSize" = 15;
          "files.associations" = {
            "*.html" = "html";
          };
          "go.lintTool" = "golangci-lint";
          "go.enableCodeLens" = {
            "references" = false;
            "runtest" = true;
          };
          "go.useLanguageServer" = true;
          "go.languageServerExperimentalFeatures" = {
            "format" = true;
            "autoComplete" = true;
            "diagnostics" = true;
            "documentLink" = true;
          };
          "gopls" = {
            "usePlaceholders" = true;
            "staticcheck" = false;
          };
          "go.addTags" = {
            "tags" = "json";
            "options" = "json=omitempty";
            "promptForTags" = false;
            "transform" = "snakecase";
          };
        };
      };
    };
    xsession = {
      enable = true;

      # initExtra = ''
      #   nitrogen --restore &
      #   pasystray &
      #   blueman-applet &
      #   nm-applet --sm-disable --indicator &
      # '';

      windowManager.i3 = {
        enable = true;
        config = {
          assigns = {
            "1:code" = [
              { class="^Code$"; }
              { class="^jetbrains-goland$"; }
            ];
            "3:web" = [
              { class="^Firefox$"; }
            ];
            "4:msg" = [
              { class="^TelegramDesktop$"; }
              { class="^Slack$"; }
            ];
            "5:db" = [
              { class="^jetbrains-datagrip$"; }
            ];
            "7:design" = [
              { class="^Dia$"; }
              { class="yEd$"; }
            ];
            "10:doc" = [
              { class="^obsidian$"; }
            ];
          };
          startup = [
            { command = "systemctl --user restart polybar"; always = true; notification = false; }
            { command = "firefox"; workspace = "3:web"; }
            # TODO: find out how to install deadd-notification-center
            # { command = "deadd-notification-center"; always = true; notification = false; }
          ];
          terminal = terminal;
          window = {
            border = 1;
            commands = [
              { command = "resize set width 300px"; criteria = { class = "Dia"; window_role="toolbox_window"; }; }
              { command = "move container to workspace 6:ssh, focus"; criteria = { class = "Alacritty"; title="^[mosh]"; }; }
            ];
          };
          colors = {
            focused = {
              border = "#707070";
              background = "#707070";
              text = "#ffffff";
              indicator = "#333333";
              childBorder = "#707070";
            };
            focusedInactive = {
              border = "#353535";
              background = "#353535";
              text = "#DDDDDD";
              indicator = "#333333";
              childBorder = "#353535";
            };
            unfocused = {
              border = "#2A2A2A";
              background = "#2A2A2A";
              text = "#AAAAAA";
              indicator = "#333333";
              childBorder = "#2A2A2A";
            };
            urgent = {
              border = "#2A2A2A";
              background = "#2A2A2A";
              text = "#DDDDDD";
              indicator = "#333333";
              childBorder = "#2A2A2A";
            };
          };
          menu = "${pkgs.rofi}/bin/rofi";
          modifier = "Mod4";
          keybindings = 
            let
              modifier = config.xsession.windowManager.i3.config.modifier;
              menu = config.xsession.windowManager.i3.config.menu;
            in lib.mkOptionDefault {
              "${modifier}+d" = "exec --no-startup-id ${menu} -show run";
              "${modifier}+h" = "focus left";
              "${modifier}+j" = "focus down";
              "${modifier}+k" = "focus up";
              "${modifier}+l" = "focus right";
              "${modifier}+Shift+h" = "move left";
              "${modifier}+Shift+j" = "move down";
              "${modifier}+Shift+k" = "move up";
              "${modifier}+Shift+l" = "move right";
              "${modifier}+g" = "split h";
              "${modifier}+Shift+s" = "sticky toggle";
              "${modifier}+1" = "workspace 1:code";
              "${modifier}+2" = "workspace 2:term";
              "${modifier}+3" = "workspace 3:web";
              "${modifier}+4" = "workspace 4:msg";
              "${modifier}+5" = "workspace 5:db";
              "${modifier}+6" = "workspace 6:ssh";
              "${modifier}+7" = "workspace 7:design";
              "${modifier}+8" = "workspace 8";
              "${modifier}+9" = "workspace 9";
              "${modifier}+0" = "workspace 10";
              "${modifier}+Shift+1" = "move container to workspace 1:code";
              "${modifier}+Shift+2" = "move container to workspace 2:term";
              "${modifier}+Shift+3" = "move container to workspace 3:web";
              "${modifier}+Shift+4" = "move container to workspace 4:msg";
              "${modifier}+Shift+5" = "move container to workspace 5:db";
              "${modifier}+Shift+6" = "move container to workspace 6:ssh";
              "${modifier}+Shift+7" = "move container to workspace 7:design";
              "${modifier}+Shift+8" = "move container to workspace 8";
              "${modifier}+Shift+9" = "move container to workspace 9";
              "${modifier}+Shift+0" = "move container to workspace 10";
              "${modifier}+Tab" = "workspace back_and_forth";
            };
          modes = {
            resize = {
              "h" = "resize shrink width 10 px or 10 ppt";
              "j" = "resize grow height 10 px or 10 ppt";
              "k" = "resize shrink height 10 px or 10 ppt";
              "l" = "resize grow width 10 px or 10 ppt";
              "Return" = "mode default";
              "Escape" = "mode default";
            };
          };
        };
      };
      pointerCursor = { 
        size = 32;
        package = pkgs.vanilla-dmz;
        name = "Vanilla-DMZ";
      }; 
    }; 
    xdg = {
      enable = true;
      configFile = {
        ".config/flameshot/flameshot.ini".text = ''
          [General]
          contrastOpacity=200
          disabledTrayIcon=true
          drawColor=#ff0000
          drawThickness=0
          filenamePattern=%F-%T
          savePath=/home/${username}/screenshots
          showDesktopNotification=false
          showHelp=false
          uiColor=#007bc7
        '';
        ".ideavimrc".text = ''
          inoremap jj <ESC>
          set clipboard=unnamed,unnamedplus,ideaput
        '';
        ".vimrc".text = ''
          inoremap jj <ESC>
          set clipboard=unnamed,unnamedplus
        '';
      };
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}
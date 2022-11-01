# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "livingroom"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.utf8";
    LC_IDENTIFICATION = "de_DE.utf8";
    LC_MEASUREMENT = "de_DE.utf8";
    LC_MONETARY = "de_DE.utf8";
    LC_NAME = "de_DE.utf8";
    LC_NUMERIC = "de_DE.utf8";
    LC_PAPER = "de_DE.utf8";
    LC_TELEPHONE = "de_DE.utf8";
    LC_TIME = "de_DE.utf8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.stevenson = {
    isNormalUser = true;
    description = "stevenson";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDjDDJYkUuWrZJFcDhXpo7/qky3d6Y5XOGQS5YicRN1pQXd96uTzDSjap4smjOOlx6WJIGcQYZsVXA0bsOXIaBRKcp90e14YB1L3LvqItPYDvuA/7URgkmvJ1YNloAkXWS2JyYUPX+ZzNlDXcfoJ3wc8+7moZSCEZvSB2FnEEiKaBjlUzOEdP+NQBXT+Piwy6Uf2VxGnPCCuoCytAtVzEFqWS/f4jkl/cUuwCZbL+hYrepOHMk8h4645q3Fu6NGWjvGt5f+TYhFI9P9Wgu1LKa1zHhywGWpmWW3HF3lOnDd8vTQlFPm8nLi4rVuQ4T1Q9i+w520+nqE4JVb5pC5v0tm1h2SWG0svQ3wmEyRuW29o9RTyrTlY2M9CwDX7VzUqbn1jix8e44EUeoEm9FJ/uC5pp75kugCNfyDDwHcDdDF5VzU4exjQ6bDVdN3uVYxlpOpyLAV4/gQiy/eTwfJHltX6JiPhJaWRKatJ6s3OJkVDUqmbmyyTFxuFJOcD82S/8qmCzrBCVsRUcBhrvVbd9LFY/hdXHxope6ts9IUSZ66Wkuc2mdOtfxGCpKJlmWFXCZP8v4p5CT89UluQS0CerSEK/8ID6ybEJDRZkwYGv22iYkjcssH5+ZBYpGZwNdr6o1lbigWkHzJviCeBe0N0Ccs8COdvWJykURp/+vtyLnBIQ== cameron@workstation"
    ];
  };

  # Enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "stevenson";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    cifs-utils
    (retroarch.override {
      cores = [
        libretro.genesis-plus-gx
        libretro.snes9x
        libretro.mgba
        libretro.mupen64plus
        libretro.desmume
        libretro.nestopia
      ];
    })
    libretro.genesis-plus-gx
    libretro.snes9x
    libretro.mgba
    libretro.mupen64plus
    libretro.desmume
    libretro.nestopia
  ];

  fileSystems."/mnt/games" = {
      device = "//10.10.10.9/Games";
      fsType = "cifs";
      options = let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

      in ["${automount_opts},guest"];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    kbdInteractiveAuthentication = false;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Automatic upgrades
    system.autoUpgrade.enable = true;
  #  system.autoUpgrade.allowReboot = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}

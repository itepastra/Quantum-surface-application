{
  alsa-lib,
  buildPackages,
  dbus,
  godot_src,
  fetchpatch,
  fontconfig,
  glib,
  installShellFiles,
  lib,
  libGL,
  libpulseaudio,
  libX11,
  libXcursor,
  libXext,
  libXfixes,
  libXi,
  libXinerama,
  libxkbcommon,
  libXrandr,
  libXrender,
  perl,
  pkg-config,
  scons,
  speechd-minimal,
  stdenv,
  udev,
  vulkan-loader,
  wayland,
  wayland-scanner,
  withAlsa ? true,
  withDbus ? true,
  withFontconfig ? true,
  withPlatform ? "linuxbsd",
  withPrecision ? "single",
  withPulseaudio ? true,
  withSpeechd ? true,
  withTouch ? true,
  withUdev ? true,
  # Wayland in Godot requires X11 until upstream fix is merged
  # https://github.com/godotengine/godot/pull/73504
  withWayland ? true,
  withX11 ? true,
}:
assert lib.asserts.assertOneOf "withPrecision" withPrecision [
  "single"
  "double"
];
let
  version = "4.4.1-stable";
  mkSconsFlagsFromAttrSet = lib.mapAttrsToList (
    k: v: if builtins.isString v then "${k}=${v}" else "${k}=${builtins.toJSON v}"
  );

  arch = stdenv.hostPlatform.linuxArch;

  dottedVersion = lib.replaceStrings [ "-" ] [ "." ] version;

  mkTarget =
    target:
    let
      editor = target == "editor";
      suffix = lib.optionalString (!editor) "-template";
      binary = lib.concatStringsSep "." (
        [
          "godot"
          withPlatform
          target
        ]
        ++ lib.optional (withPrecision != "single") withPrecision
        ++ [ arch ]
      );
      attrs = finalAttrs: rec {
        pname = "godot${suffix}";
        inherit version;

        src = godot_src;

        outputs = [
          "out"
        ]
        ++ lib.optional (editor) "man";
        separateDebugInfo = true;

        # Set the build name which is part of the version. In official downloads, this
        # is set to 'official'. When not specified explicitly, it is set to
        # 'custom_build'. Other platforms packaging Godot (Gentoo, Arch, Flatpack
        # etc.) usually set this to their name as well.
        #
        # See also 'methods.py' in the Godot repo and 'build' in
        # https://docs.godotengine.org/en/stable/classes/class_engine.html#class-engine-method-get-version-info
        BUILD_NAME = "nixpkgs";

        # From: https://github.com/godotengine/godot/blob/4.2.2-stable/SConstruct
        sconsFlags = mkSconsFlagsFromAttrSet {
          # Options from 'SConstruct'
          precision = withPrecision; # Floating-point precision level
          production = true; # Set defaults to build Godot for use in production
          platform = withPlatform;
          inherit target;
          debug_symbols = true;

          # Options from 'platform/linuxbsd/detect.py'
          alsa = withAlsa;
          dbus = withDbus; # Use D-Bus to handle screensaver and portal desktop settings
          fontconfig = withFontconfig; # Use fontconfig for system fonts support
          pulseaudio = withPulseaudio; # Use PulseAudio
          speechd = withSpeechd; # Use Speech Dispatcher for Text-to-Speech support
          touch = withTouch; # Enable touch events
          udev = withUdev; # Use udev for gamepad connection callbacks
          wayland = withWayland; # Compile with Wayland support
          x11 = withX11; # Compile with X11 support

          # aliasing bugs exist with hardening+LTO
          # https://github.com/godotengine/godot/pull/104501
          ccflags = "-fno-strict-aliasing";
          linkflags = "-Wl,--build-id";

          use_sowrap = false;

          module_mono_enabled = false;
        };

        enableParallelBuilding = true;

        strictDeps = true;

        patches = lib.optionals (lib.versionOlder version "4.4") [
          (fetchpatch {
            name = "wayland-header-fix.patch";
            url = "https://github.com/godotengine/godot/commit/6ce71f0fb0a091cffb6adb4af8ab3f716ad8930b.patch";
            hash = "sha256-hgAtAtCghF5InyGLdE9M+9PjPS1BWXWGKgIAyeuqkoU=";
          })
          # Fix a crash in the mono test project build. It no longer seems to
          # happen in 4.4, but an existing fix couldn't be identified.
          ./CSharpLanguage-fix-crash-in-reload_assemblies-after-.patch
        ];

        postPatch = ''
          # this stops scons from hiding e.g. NIX_CFLAGS_COMPILE
          perl -pi -e '{ $r += s:(env = Environment\(.*):\1\nenv["ENV"] = os.environ: } END { exit ($r != 1) }' SConstruct

          substituteInPlace thirdparty/glad/egl.c \
            --replace-fail \
              'static const char *NAMES[] = {"libEGL.so.1", "libEGL.so"}' \
              'static const char *NAMES[] = {"${lib.getLib libGL}/lib/libEGL.so"}'

          substituteInPlace thirdparty/glad/gl.c \
            --replace-fail \
              'static const char *NAMES[] = {"libGLESv2.so.2", "libGLESv2.so"}' \
              'static const char *NAMES[] = {"${lib.getLib libGL}/lib/libGLESv2.so"}' \

          substituteInPlace thirdparty/glad/gl{,x}.c \
            --replace-fail \
              '"libGL.so.1"' \
              '"${lib.getLib libGL}/lib/libGL.so"'

          substituteInPlace thirdparty/volk/volk.c \
            --replace-fail \
              'dlopen("libvulkan.so.1"' \
              'dlopen("${lib.getLib vulkan-loader}/lib/libvulkan.so"'
        '';

        depsBuildBuild = lib.optionals (stdenv.buildPlatform != stdenv.hostPlatform) [
          buildPackages.stdenv.cc
          pkg-config
        ];

        buildInputs =
          lib.optional withAlsa alsa-lib
          ++ lib.optional (withX11 || withWayland) libxkbcommon
          ++ lib.optionals withX11 [
            libX11
            libXcursor
            libXext
            libXfixes
            libXi
            libXinerama
            libXrandr
            libXrender
          ]
          ++ lib.optionals withWayland [
            # libdecor
            wayland
          ]
          ++ lib.optionals withDbus [
            dbus
          ]
          ++ lib.optionals withFontconfig [
            fontconfig
          ]
          ++ lib.optional withPulseaudio libpulseaudio
          ++ lib.optionals withSpeechd [
            speechd-minimal
            glib
          ]
          ++ lib.optional withUdev udev;

        nativeBuildInputs = [
          installShellFiles
          perl
          pkg-config
          scons
        ]
        ++ lib.optionals withWayland [ wayland-scanner ];

        installPhase = ''
          runHook preInstall

          mkdir -p "$out"/{bin,libexec}
          cp -r bin/* "$out"/libexec

          cd "$out"/bin
          ln -s ../libexec/${binary} godot${lib.versions.majorMinor version}${suffix}
          ln -s godot${lib.versions.majorMinor version}${suffix} godot${lib.versions.major version}${suffix}
          ln -s godot${lib.versions.major version}${suffix} godot${suffix}
          cd -
        ''
        + (
          if editor then
            ''
              installManPage misc/dist/linux/godot.6

              mkdir -p "$out"/share/{applications,icons/hicolor/scalable/apps}
              cp misc/dist/linux/org.godotengine.Godot.desktop \
                "$out/share/applications/org.godotengine.Godot${lib.versions.majorMinor version}${suffix}.desktop"

              substituteInPlace "$out/share/applications/org.godotengine.Godot${lib.versions.majorMinor version}${suffix}.desktop" \
                --replace-fail "Exec=godot" "Exec=$out/bin/godot${suffix}" \
                --replace-fail "Godot Engine" "Godot Engine ${lib.versions.majorMinor version}"
              cp icon.svg "$out/share/icons/hicolor/scalable/apps/godot.svg"
              cp icon.png "$out/share/icons/godot.png"
            ''
          else
            let
              template =
                (lib.replaceStrings
                  [ "template" ]
                  [
                    {
                      linuxbsd = "linux";
                    }
                    .${withPlatform}
                  ]
                  target
                )
                + "."
                + arch;
            in
            ''
              templates="$out"/share/godot/export_templates/${dottedVersion}
              mkdir -p "$templates"
              ln -s "$out"/libexec/${binary} "$templates"/${template}
            ''
        )
        + ''
          runHook postInstall
        '';

        passthru = lib.optionalAttrs editor {
          export-template = mkTarget "template_release";
        };

        requiredSystemFeatures = [
          # fixes: No space left on device
          "big-parallel"
        ];

        meta = {
          changelog = "https://github.com/godotengine/godot/releases/tag/${version}";
          description = "Free and Open Source 2D and 3D game engine";
          homepage = "https://godotengine.org";
          license = lib.licenses.mit;
          platforms = [
            "x86_64-linux"
            "aarch64-linux"
            "i686-linux"
          ];
          maintainers = with lib.maintainers; [
            shiryel
            corngood
          ];
          mainProgram = "godot${suffix}";
        };
      };

      unwrapped = stdenv.mkDerivation (attrs);

      wrapper = unwrapped;
    in
    wrapper;
in
mkTarget "editor"

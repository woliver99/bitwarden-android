{
  pkgs ? import <nixpkgs> {
    config = {
      allowUnfree = true;
      android_sdk.accept_license = true;
    };
  },
}:

let
  androidComposition = pkgs.androidenv.composeAndroidPackages {
    buildToolsVersions = [
      "36.0.0"
      "35.0.0"
      "34.0.0"
    ];
    platformVersions = [
      "37"
      "36"
      "35"
      "34"
      "33"
    ];

    includeNDK = false;
    includeEmulator = false;
    includeSystemImages = false;
  };

  androidSdk = androidComposition.androidsdk;

in
pkgs.mkShell {
  buildInputs = [
    pkgs.git
    pkgs.jdk21
    androidSdk
  ];

  shellHook = ''
    export ANDROID_HOME=${androidSdk}/libexec/android-sdk
    export ANDROID_SDK_ROOT=$ANDROID_HOME
    export JAVA_HOME=${pkgs.jdk21.home}
    export GRADLE_OPTS="-Dorg.gradle.project.android.aapt2FromMavenOverride=$ANDROID_SDK_ROOT/build-tools/36.0.0/aapt2"

    export PATH=$ANDROID_HOME/platform-tools:$PATH
  '';
}

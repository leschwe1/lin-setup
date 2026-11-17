
#!/usr/bin/env bash
set -Eeuo pipefail

REPO="massCodeIO/massCode"
INSTALL_DIR="$HOME/.local/opt/masscode"
ICON_DIR="$HOME/.local/share/icons"
DESKTOP_DIR="$HOME/.local/share/applications"
APPIMAGE="$INSTALL_DIR/massCode.AppImage"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

# Check dependencies
for cmd in curl jq sha256sum; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Missing dependency: $cmd"
        echo "Install with: sudo dnf install curl jq coreutils"
        exit 1
    fi
done

# Obtain AppImage: use supplied file, or download latest stable release
if [[ $# -ge 1 ]]; then
    SOURCE_APPIMAGE="$1"

    if [[ ! -f "$SOURCE_APPIMAGE" ]]; then
        echo "AppImage not found: $SOURCE_APPIMAGE"
        exit 1
    fi

    cp "$SOURCE_APPIMAGE" "$TMP_DIR/massCode.AppImage"
else
    echo "Checking latest massCode release..."

    RELEASE="$(curl -fsSL \
        -H "Accept: application/vnd.github+json" \
        "https://api.github.com/repos/$REPO/releases/latest")"

    VERSION="$(jq -r '.tag_name' <<< "$RELEASE")"

    # Explicitly block the known compromised release
    if [[ "$VERSION" == "v6.2.0" ]]; then
        echo "Refusing to install compromised release $VERSION"
        exit 1
    fi

    ASSET="$(jq -ce \
        '[.assets[] | select(.name | endswith(".AppImage"))] | first // empty' \
        <<< "$RELEASE")"

    if [[ -z "$ASSET" ]]; then
        echo "No AppImage found in release $VERSION"
        exit 1
    fi

    URL="$(jq -r '.browser_download_url' <<< "$ASSET")"
    DIGEST="$(jq -r '.digest // empty' <<< "$ASSET")"

    echo "Downloading massCode $VERSION..."
    curl -fL --retry 3 "$URL" -o "$TMP_DIR/massCode.AppImage"

    if [[ "$DIGEST" == sha256:* ]]; then
        EXPECTED="${DIGEST#sha256:}"
        echo "$EXPECTED  $TMP_DIR/massCode.AppImage" | sha256sum -c -
    else
        echo "Warning: GitHub did not provide a SHA-256 digest."
    fi
fi

# Install AppImage
echo "Installing massCode..."
mkdir -p "$INSTALL_DIR" "$ICON_DIR" "$DESKTOP_DIR"

install -Dm755 "$TMP_DIR/massCode.AppImage" "$APPIMAGE"

# Extract AppImage contents to obtain the icon
echo "Extracting application icon..."
mkdir -p "$TMP_DIR/extracted"
(
    cd "$TMP_DIR/extracted"
    "$APPIMAGE" --appimage-extract >/dev/null
)

EXTRACTED="$TMP_DIR/extracted/squashfs-root"
ICON_SOURCE="$EXTRACTED/usr/share/icons/hicolor/256x256/apps/masscode.png"

if [[ ! -f "$ICON_SOURCE" ]]; then
    ICON_SOURCE="$EXTRACTED/masscode.png"
fi

if [[ ! -f "$ICON_SOURCE" ]]; then
    echo "Could not find massCode icon in the AppImage."
    exit 1
fi

install -Dm644 "$ICON_SOURCE" "$ICON_DIR/masscode.png"

# Create desktop application launcher
cat > "$DESKTOP_DIR/masscode.desktop" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=massCode
Comment=Code snippet manager
Exec="$APPIMAGE"
Icon=$ICON_DIR/masscode.png
Terminal=false
Categories=Development;Utility;
StartupNotify=true
EOF

# Refresh desktop application database if available
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$DESKTOP_DIR" || true
fi

echo
echo "massCode installed successfully!"
echo "AppImage: $APPIMAGE"
echo "Icon:     $ICON_DIR/masscode.png"
echo "Launcher: $DESKTOP_DIR/masscode.desktop"
echo
echo "You can now launch massCode from your application menu."

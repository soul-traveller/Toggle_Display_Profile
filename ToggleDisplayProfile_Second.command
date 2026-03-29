#!/bin/bash

###############################################################################
# Toggle_Display_Profile.command
# Version: 1.2
# Author: Knut Larsson
#
# PURPOSE:
# Select and apply ICC profiles from a list using ArgyllCMS (dispwin).
#
# HOW IT WORKS:
# - Profiles are defined as file names in PROFILES array
# - PROFILE_DIR defines where the profiles are stored
# - Each profile has a matching description in DESCRIPTIONS
# - Script remembers last used profile via /tmp/icc_state
# - Each run shows a popup dialog with all defined profiles in variable PROFILES.
# - Current profile is highlighted with "(current)" suffix
# - Next profile in the array is preselected for quick switching
# - User selects a profile and clicks OK to apply it
# - Clicking Cancel shows a message and closes the terminal
# - Script remembers last used profile via shared state file using script-specific tag
#
# PROFILE CONFIGURATION:
# 1. Set DISPLAY_NUMBER that shall switch profiles. 1 = Primary Display, 2 = Secondary Display.
#    Run command "dispwin -d" to detect which screen to use, if uncertain.
# 2. Set PROFILE_DIR (supports $HOME and spaces in paths)
# 3. Add profile FILE NAMES (not full paths) to PROFILES array
# 4. Add matching descriptions in DESCRIPTIONS array
#
# IMPORTANT:
# - The sequence of DESCRIPTIONS MUST match PROFILES
#
# DESCRIPTION STRING (recommended content):
# - Color space (sRGB / AdobeRGB / etc.)
# - White point (e.g. 6500K / D65)
# - Luminance (e.g. 100 cd/m²)
# - Gamma (e.g. 2.2 / 2.4)
#
# Example:
#    " - BenQ T2200HD \n - sRGB Color Space \n - D65 \n - 120 cd/m² \n - Gamma sRGB \n - cLUT-Matrix \n - Calibrated with DisplayCAL using ColorMunki."
#
# USAGE:
# 1. Save as:
#    Toggle_Display_Profile.command
#
# 2. Make executable:
#    chmod +x Toggle_Display_Profile.command
#
# 3. Run:
#    - Double-click in Finder
#    - Create alias
#    - Bind to keyboard shortcut (Automator / Shortcuts)
#
# 4. The Automator app file "Toggle Display Profile.app"
#    - Asks for command file location and store it, if not stored already.
#    - If path to script changes the app will ask for the command script path again.
#    - Runs command script.
#
# NOTES:
# - Requires ArgyllCMS (dispwin)
# - Ensure monitor mode (CAL1/CAL2) matches profile
# - Dialog shows all profiles with current one marked "(current)"
# - Next profile is preselected for convenient switching
#
###############################################################################

# --- USER CONFIG -------------------------------------------------------------

# DISPLAY_NUMBER:
# Specifies which display dispwin should target.
# Typically:
#   1 = primary display
#   2 = secondary display
# NOTE: Must match ArgyllCMS display numbering (not macOS UI numbering)
DISPLAY_NUMBER="2"

# PROFILE_DIR:
# Base directory where ICC profiles are stored.
# Supports $HOME and paths with spaces.
PROFILE_DIR="$HOME/Library/ColorSync/Profiles"

# PROFILES:
# Array of ICC profile FILE NAMES (not full paths).
# These will be combined with PROFILE_DIR.
PROFILES=(
    "ID160FH_120cdm2_D6500_sRGB_M-S_XYZLUT+MTX_1158_DCal_Colormunki_26.01.31-04.44.icc"
    "ID160FH_120cdm2_D5000_sRGB_S_XYZLUT+MTX_4954_DisplayCal_SpyderX_26.01.27-23.39.icc"
    "ID160FH_80cdm2_D6500_GsRGB_cLUT_461_i1Profiler_i1DP_2026-03-28.icc"
    "ID160FH_100cdm2_D6500_GsRGB_cLUT_461_i1Profiler_i1DP_2026-03-28.icc"
)

# DESCRIPTIONS:
# Human-readable descriptions corresponding to PROFILES.
# Array MUST be same length as PROFILES and same order.
DESCRIPTIONS=(
    " - ID160FH \n - AdobeRGB Color Space \n - D65 \n - 120 cd/m² \n - Gamma sRGB \n - cLUT-Matrix \n - Calibrated with DisplayCAL using ColorMunki. \n\nSet the following: \n - Screen settings: \n     - Sorftware Brightness: 50 \n     - Sorftware Contrast: 100 \n     - Tablet Brightness: 73 \n     - No RGB Available"
    " - ID160FH \n - AdobeRGB Color Space \n - D50 \n - 120 cd/m² \n - Gamma sRGB \n - cLUT-Matrix \n - Calibrated with DisplayCAL using SpyderX. \n\nSet the following: \n - Screen settings: \n     - Sorftware Brightness: 50 \n     - Sorftware Contrast: 100 \n     - Tablet Brightness: 84 \n     - No RGB Available"
    " - ID160FH \n - AdobeRGB Color Space \n - D65 \n - 80 cd/m² \n - Gamma sRGB \n - cLUT \n - Calibrated with i1Profiler using i1Display Pro. \n\nSet the following: \n - Screen settings: \n     - Sorftware Brightness: 50 \n     - Sorftware Contrast: 100 \n     - Tablet Brightness: 43 \n     - No RGB Available"
    " - ID160FH \n - AdobeRGB Color Space \n - D65 \n - 100 cd/m² \n - Gamma sRGB \n - cLUT \n - Calibrated with i1Profiler using i1Display Pro. \n\nSet the following: \n - Screen settings: \n     - Sorftware Brightness: 50 \n     - Sorftware Contrast: 100 \n     - Tablet Brightness: 63 \n     - No RGB Available"
)

# STATE_FILE:
# Stores current index between runs (persistent toggle state)
STATE_FILE="$HOME/Library/Application Support/ToggleDisplayProfile/icc_state"
mkdir -p "$(dirname "$STATE_FILE")"

# Unique tag based on script filename
SCRIPT_TAG="$(basename "$0")"

# --- ERROR HANDLER -----------------------------------------------------------

# error_exit(description, exit_code, details)
# Centralized error reporting:
# - Shows terminal + popup message
# - Includes optional diagnostic output
error_exit() {
    local description="$1"
    local code="$2"
    local details="$3"

    local FULL_MSG="Error: $description\nExit code: $code"

    if [ -n "$details" ]; then
        FULL_MSG="$FULL_MSG\nDetails:\n$details"
    fi

    echo -e "❌ $FULL_MSG"

    # Display macOS popup dialog
    osascript <<EOF
display dialog "$FULL_MSG" with title "Toggle Display Profile:" buttons {"OK"} default button "OK"
EOF

    exit "$code"
}

# --- CHECK ARGYLLCMS ---------------------------------------------------------

# Ensure dispwin is available in PATH
if ! command -v dispwin >/dev/null 2>&1; then
    error_exit "ArgyllCMS (dispwin) not found" 1 "Install with: brew install argyll-cms"
fi

# --- VALIDATE ARRAYS ---------------------------------------------------------

# Ensure PROFILES and DESCRIPTIONS arrays match
if [ ${#PROFILES[@]} -ne ${#DESCRIPTIONS[@]} ]; then
    error_exit "PROFILES and DESCRIPTIONS arrays must be same length" 2 ""
fi

# Ensure at least one profile exists
if [ ${#PROFILES[@]} -eq 0 ]; then
    error_exit "No profiles defined in PROFILES array" 6 ""
fi

TOTAL=${#PROFILES[@]}

# --- VALIDATE PROFILE DIRECTORY ---------------------------------------------

# Expand path and validate directory exists
if [ ! -d "$PROFILE_DIR" ]; then
    error_exit "Profile directory not found" 3 "$PROFILE_DIR"
fi

# --- DETECT CURRENT PROFILE ---------------------------------------------------

# Read current index from state file using script-specific tag
if [ -f "$STATE_FILE" ]; then
    CURRENT_INDEX=$(grep "^$SCRIPT_TAG=" "$STATE_FILE" | cut -d'=' -f2)

    if ! [[ "$CURRENT_INDEX" =~ ^[0-9]+$ ]] || [ "$CURRENT_INDEX" -ge "$TOTAL" ]; then
        CURRENT_INDEX=0
    fi
else
    CURRENT_INDEX=0
fi

# --- BUILD PROFILE LIST FOR DIALOG -------------------------------------------

PROFILE_LIST=()
for i in "${!PROFILES[@]}"; do
    if [ "$i" -eq "$CURRENT_INDEX" ]; then
        PROFILE_LIST+=("${PROFILES[$i]} (current)")
    else
        PROFILE_LIST+=("${PROFILES[$i]}")
    fi
done

# --- CALCULATE PRESELECTED PROFILE -------------------------------------------

# Preselect the next profile in the array (wraps around)
NEXT_PRESELECT=$(( (CURRENT_INDEX + 1) % TOTAL ))
PRESELECTED_PROFILE="${PROFILE_LIST[$NEXT_PRESELECT]}"

# --- SHOW PROFILE SELECTION DIALOG -------------------------------------------

# Convert bash array to AppleScript list
IFS=$'\n'
APPLESCRIPT_LIST=$(printf '"%s",' "${PROFILE_LIST[@]}" | sed 's/,$//')
unset IFS

# Show dialog with profile selection and capture result
SELECTED_PROFILE_RAW=$(osascript <<EOF 2>/dev/null
try
    tell application "Terminal"
        activate
    end tell
    tell application "System Events" to set frontmost of process "Terminal" to true
    set profileList to {$APPLESCRIPT_LIST}
    set selectedProfile to choose from list profileList with prompt "Toggle Display Profile:\n\nSelect ICC profile to apply:" with multiple selections allowed default items {"$PRESELECTED_PROFILE"}
    if selectedProfile is false then
        tell application "Terminal"
            activate
        end tell
        tell application "System Events" to set frontmost of process "Terminal" to true
        display dialog "Profile selection cancelled." with title "Toggle Display Profile:" buttons {"OK"} default button "OK" giving up after 2
        tell application "Terminal"
            activate
        end tell
        tell application "System Events" to set frontmost of process "Terminal" to true
        return "CANCELLED"
    else
        return item 1 of selectedProfile
    end if
on error
    tell application "Terminal"
        activate
    end tell
    tell application "System Events" to set frontmost of process "Terminal" to true
    display dialog "Profile selection cancelled." with title "Toggle Display Profile:" buttons {"OK"} default button "OK" giving up after 2
    tell application "Terminal"
        activate
    end tell
    tell application "System Events" to set frontmost of process "Terminal" to true
    return "CANCELLED"
end try
EOF
)

# Check if user cancelled
if [ "$SELECTED_PROFILE_RAW" = "CANCELLED" ]; then
    echo "❌ Dialog cancelled by user"
    osascript <<EOF 2>/dev/null
tell application "Terminal"
    activate
end tell
tell application "System Events" to set frontmost of process "Terminal" to true
tell application "Terminal" to close window 1 saving no
EOF
    exit 0
fi

# Remove "(current)" suffix to get actual profile name
SELECTED_PROFILE_NAME="${SELECTED_PROFILE_RAW// (current)/}"

# --- FIND SELECTED PROFILE INDEX ---------------------------------------------

SELECTED_INDEX=-1
for i in "${!PROFILES[@]}"; do
    if [ "${PROFILES[$i]}" = "$SELECTED_PROFILE_NAME" ]; then
        SELECTED_INDEX=$i
        break
    fi
done

if [ "$SELECTED_INDEX" -eq -1 ]; then
    error_exit "Selected profile not found in PROFILES array" 11 "$SELECTED_PROFILE_NAME"
fi

# --- VALIDATE PROFILE FILE ---------------------------------------------------

PROFILE_PATH="$PROFILE_DIR/$SELECTED_PROFILE_NAME"
DESCRIPTION="${DESCRIPTIONS[$SELECTED_INDEX]}"

# Check file exists
if [ ! -f "$PROFILE_PATH" ]; then
    error_exit "Profile file not found" 4 "$PROFILE_PATH"
fi

# Check file is readable
if [ ! -r "$PROFILE_PATH" ]; then
    error_exit "Profile file not readable" 8 "$PROFILE_PATH"
fi

# Ensure valid ICC extension
case "$SELECTED_PROFILE_NAME" in
    *.icc|*.ICM|*.icm|*.ICC) ;;
    *) error_exit "Invalid profile type (must be .icc or .icm)" 5 "$SELECTED_PROFILE_NAME" ;;
esac

# --- VALIDATE DISPLAY NUMBER -------------------------------------------------

# Ensure DISPLAY_NUMBER is numeric
if ! [[ "$DISPLAY_NUMBER" =~ ^[0-9]+$ ]]; then
    error_exit "DISPLAY_NUMBER must be numeric" 9 "$DISPLAY_NUMBER"
fi

# --- APPLY PROFILE (ARGYLL dispwin) -----------------------------------------
# -d number : target display index. 1=Primary Display
# -I : Install profile for display and use its calibration

DISPWIN_OUTPUT=$(dispwin -d "$DISPLAY_NUMBER" -I "$PROFILE_PATH" 2>&1)
DISPWIN_EXIT=$?

# Check execution result
if [ $DISPWIN_EXIT -ne 0 ]; then
    error_exit "Failed to apply ICC profile (dispwin)" $DISPWIN_EXIT "$DISPWIN_OUTPUT"
fi

# Optional: detect warnings in output
if echo "$DISPWIN_OUTPUT" | grep -qi "warning"; then
    echo "⚠️ dispwin warning detected:"
    echo "$DISPWIN_OUTPUT"
fi

# --- SAVE STATE --------------------------------------------------------------

# Save state using script-specific tag (update or append)
# Shared state file will now look like. Tag based no script file-name:
#  - Toggle_Display_Profile.command=1
#  - Another_Display_Profile.command=0
#  - Third_Screen_Profile.command=2
# ✔ Each script reads only its own entry
# ✔ Multiple scripts safely share one file
if [ -f "$STATE_FILE" ]; then
    grep -v "^$SCRIPT_TAG=" "$STATE_FILE" > "$STATE_FILE.tmp"
    echo "$SCRIPT_TAG=$SELECTED_INDEX" >> "$STATE_FILE.tmp"
    mv "$STATE_FILE.tmp" "$STATE_FILE"
else
    echo "$SCRIPT_TAG=$SELECTED_INDEX" > "$STATE_FILE"
fi

if [ $? -ne 0 ]; then
    error_exit "Failed to write state file" 10 "$STATE_FILE"
fi

# --- SUCCESS MESSAGE ---------------------------------------------------------

MESSAGE="Applied Screen Profile:\n$SELECTED_PROFILE_NAME\n\nDescription:\n$DESCRIPTION"

echo "✅ $MESSAGE"

osascript <<EOF
display dialog "$MESSAGE" with title "Toggle Display Profile:" buttons {"OK"} default button "OK"
EOF

exit 0

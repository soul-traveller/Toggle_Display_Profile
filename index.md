# Toggle Display Profile Scripts — User Guide
**Version:** 1.2<br>
**Platform:** macOS<br>
**Author:** Knut Larsson<br>

`Toggle Display Profile` provides interactive bash scripts for quickly switching between ICC display profiles on macOS using ArgyllCMS dispwin. Two versions are included: one for the primary display and one for the secondary display, along with macOS Automator app files for convenient access.

---

## 📑 Table of Contents

- [Overview](#overview)
- [Scripts and Applications](#scripts-and-applications)
- [Features](#features)
- [When to Use These Scripts](#when-to-use-these-scripts)
- [Installation](#installation)
  - [Getting Started](#getting-started)
  - [Dependencies](#dependencies)
  - [Script Placement](#script-placement)
  - [Execution Permissions for macOS (Important)](#execution-permissions-for-macos-important)
  - [Configuring Profile Lists](#configuring-profile-lists)
- [Usage](#usage)
  - [Using the .command Scripts Directly](#using-the-command-scripts-directly)
  - [Using the Automator Apps](#using-the-automator-apps)
  - [Adding to macOS Dock](#adding-to-macos-dock)
- [Example Scenarios](#example-scenarios)
- [Files and Folder Structure](#files-and-folder-structure)
- [Configuration Parameters](#configuration-parameters)
- [How It Works](#how-it-works)
- [Important Notes and Best Practices](#important-notes-and-best-practices)
- [Troubleshooting](#troubleshooting)

---

## Overview

These scripts provide a **quick and convenient way to switch between ICC display profiles** on macOS. They are designed for users who need to frequently change display profiles for different workflows or display modes.

The scripts are particularly useful for:

- **Multi-mode displays**: Monitors with switchable gamut modes (sRGB, AdobeRGB, etc.) that require matching ICC profiles
- **Wide-gamut displays**: Displays with AdobeRGB or wider gamuts working on sRGB content
- **Multiple luminance profiles**: Switching between profiles calibrated for different brightness levels
- **Dual-monitor setups**: Independent profile management for primary and secondary displays
- **Color-critical workflows**: Photography, design, and print preparation requiring accurate color representation

The scripts remember your last selected profile and preselect the next one in the list for rapid toggling, making frequent profile changes effortless.

---

## Scripts and Applications

The Toggle Display Profile project provides two bash scripts and two macOS Automator applications.

### Bash Scripts

#### `ToggleDisplayProfile_Main.command`
- **Target:** Primary Display (DISPLAY_NUMBER = 1)
- **Purpose:** Switch ICC profiles on the main/primary display
- **How to use:** Double-click in Finder after setting execute permissions, or run from Terminal

#### `ToggleDisplayProfile_Second.command`
- **Target:** Secondary Display (DISPLAY_NUMBER = 2)
- **Purpose:** Switch ICC profiles on a secondary/second display
- **How to use:** Double-click in Finder after setting execute permissions, or run from Terminal

Both scripts are identical in functionality and features, differing only in the `DISPLAY_NUMBER` configuration.

### Automator Applications

#### `Toggle Display Profile-Main.app`
- **Target:** Primary Display
- **Purpose:** macOS application wrapper for the Main script
- **Features:**
  - Asks for the location of the `.command` script on first run
  - Stores the script path for future use
  - Provides clickable application access
  - Can be added to macOS Dock or Applications folder

#### `Toggle Display Profile-Second.app`
- **Target:** Secondary Display
- **Purpose:** macOS application wrapper for the Second script
- **Features:** Same as Main app, but for the secondary display

**Note:** The Automator apps will prompt for the `.command` script location on first run or if the stored path becomes invalid (e.g., if you move the script). This allows flexibility in script placement.

**IMPORTANT:** Sometimes the Automator .app files may be interpreted by macOS as faulty when trying to run them. In this case a "damaged" error could appear because macOS applies a `com.apple.quarantine` attribute to downloaded files, which, when combined with signature changes during compression/extraction, triggers security.

**If this happens:** Remove Quarantine Attribute 
After downloading, run this command in Terminal to remove the restriction, replacing `/path/to/app` with the actual path to your Automator app file:

```bash
xattr -dr com.apple.quarantine "/path/to/app/Toggle Display Profile.app"
```

---

## Features

**General Features**

- Quick profile switching via interactive dialog
- Persistent state remembers last selected profile
- Next profile preselected for convenient toggling
- Current profile highlighted with "(current)" marker
- Support for multiple displays (independent scripts)
- Detailed profile descriptions with calibration settings
- Error handling with clear messages
- macOS popup dialogs for user interaction

**Profile Management**

- Unlimited profiles per display (defined in script configuration)
- Human-readable descriptions for each profile
- Support for all ICC/ICM profile types
- Automatic profile validation before application
- Shared state file allows multiple scripts to coexist

**User Experience**

- Intuitive AppleScript-based dialog interface
- Terminal window closes automatically on cancellation
- Success messages with full profile details
- Screen brightness/contrast settings included in descriptions
- Quick access via Automator apps or keyboard shortcuts

---

## When to Use These Scripts

### Multi-Mode Displays

Many modern monitors have switchable display modes that change the color gamut:

- **sRGB mode**: Standard color space for web and general content
- **AdobeRGB mode**: Wider gamut for photography and print workflows
- **DCI-P3 mode**: Cinema and video production color space

**Problem:** When you switch the monitor's hardware mode, the software ICC profile must also change to match. Otherwise, colors will be displayed incorrectly.

**Solution:** Use these scripts to quickly apply the matching ICC profile whenever you change the monitor mode.

### Wide-Gamut Displays on sRGB Content

Displays with wide color gamuts (e.g., 99% AdobeRGB) will show oversaturated colors when displaying sRGB content without proper color management.

**Problem:** Working on sRGB images on an AdobeRGB display causes colors to appear saturated and inaccurate.

**Solution:** Use ICC profiles with **Perceptual intent** that force out-of-gamut colors into the sRGB color space. Set your software (Photoshop, Krita, GIMP) to manage colors with this profile using perceptual intent.

### Multiple Luminance Profiles

Different workflows require different screen brightness levels:

- **Daytime work**: Higher luminance (e.g., 120 cd/m²)
- **Nighttime work**: Lower luminance (e.g., 80 cd/m²)
- **Print proofing**: Specific luminance matching print viewing conditions

**Solution:** Create and switch between profiles calibrated for different luminance levels.

### Dual-Monitor Workflows

When using two displays with different characteristics:

- Primary display: Wide-gamut monitor for color-critical work
- Secondary display: Standard monitor for reference or tools

**Solution:** Use the Main script for the primary display and the Second script for the secondary display, each with its own set of profiles.

---

## Installation

### Getting Started

1. **Download or clone** the Toggle Display Profile repository
2. **Place the folder** in a convenient location (Desktop, Documents, etc.)
3. **Install dependencies** (see [Dependencies](#dependencies))
4. **Configure profile lists** (see [Configuring Profile Lists](#configuring-profile-lists))
5. **Set execute permissions** (see [Execution Permissions for macOS (Important)](#execution-permissions-for-macos-important))
6. **Copy or drag .app files** to Dock or to Applications folder (if desired).   
   Alternatively, make keyboard shortcut to .app files.
7. **Run the script** to verify it works

### Dependencies

The scripts require **ArgyllCMS** to be installed on your system.

**Install ArgyllCMS via Homebrew (recommended):**

```bash
brew install argyll-cms
```

**Verify installation:**

```bash
dispwin -?
```

If `dispwin` is found, ArgyllCMS is properly installed.

**Alternative installation:**

Download from [ArgyllCMS website](https://www.argyllcms.com/) and follow the installation instructions for macOS.

### Script Placement

You may place the Toggle Display Profile folder **in any location**:

- Desktop
- Documents
- External drive
- Project-specific folder

The scripts and Automator apps will work from any location. The Automator apps will ask for the script location on first run and remember it.

### Execution Permissions for macOS (Important)

On modern macOS versions, a script must have the **execute bit** set to run.

After setting permissions, you can run scripts by:   

 - Double-clicking them in Finder
 - Running them from Terminal with `./ToggleDisplayProfile_Main.command`
 - Using supplied .app files

**Option 1: Set Execute Bit Using Terminal (recommended)**

1. Open Terminal
2. Navigate to the Toggle Display Profile folder:

   ```bash
   cd "/path/to/Toggle_Display_Profile"
   ```
3. Set execute permissions for both scripts:   

	```bash
	chmod +x ToggleDisplayProfile_Main.command   
	chmod +x ToggleDisplayProfile_Second.command   
	```
4. Verify (optional):

   ```bash
   ls -l *.command
   ```  
   Expected output:
   
   ```
   -rwxr-xr-x@ ToggleDisplayProfile_Main.command
   -rwxr-xr-x@ ToggleDisplayProfile_Second.command
   ```

**Option 2: Set Execute Bit Using Finder**

1. Right-click (or Ctrl+click) on the `.command` file
2. Select "Open"
3. Click "Open" in the security dialog
4. This may work in many cases without using Terminal

### Configuring Profile Lists

Before using the scripts, you need to configure them with your ICC profiles.

**Edit the script configuration:**

1. Open the `.command` file in a text editor (TextEdit, VS Code, etc.)
2. Locate the **USER CONFIG** section (around line 67)
3. Modify the following parameters:

**Key Parameters:**

- **`DISPLAY_NUMBER`**: Display to target (1 = primary, 2 = secondary)
  - This is pre-selected for the two supplied .command scripts.
  - Main script: Set to "1"
  - Second script: Set to "2"
  - Run `dispwin -d` to detect available displays if uncertain

- **`PROFILE_DIR`**: Directory containing ICC profiles
  - Default: `$HOME/Library/ColorSync/Profiles`
  - Supports `$HOME` and paths with spaces
  - Example: `"$HOME/Library/ColorSync/Profiles"`

- **`PROFILES`**: Array of ICC profile file names (not full paths)
  - Add profile filenames only (e.g., `"MyProfile.icc"`)
  - One profile per line in the array
  - Profile names should have a naming convention suitable for your workflow and containing important indicators that needed to understand the difference between them.
  - Example:

    ```bash
    PROFILES=(
        "BenQ_T2200HD_sRGB_D65_120cdm2.icc"
        "BenQ_T2200HD_AdobeRGB_D65_120cdm2.icc"
        "BenQ_T2200HD_sRGB_D65_80cdm2.icc"
    )
    ```

- **`DESCRIPTIONS`**: Human-readable descriptions for each profile
  - Must match the order and length of `PROFILES` array
  - Include color space, white point, luminance, gamma, calibration details
  - Include screen settings (brightness, contrast, RGB values)
  - Use `\n` for line breaks within descriptions
  - Example:

    ```bash
    DESCRIPTIONS=(
        " - BenQ T2200HD \n - sRGB Color Space \n - D65 \n - 120 cd/m² \n - Gamma sRGB \n - cLUT-Matrix \n - Calibrated with DisplayCAL using ColorMunki. \n\nSet the following: \n - Screen settings: \n     - Brightness: 50 \n     - Contrast: 83 \n     - Red: 89 \n     - Green: 88 \n     - Blue: 95"
        " - BenQ T2200HD \n - AdobeRGB Color Space \n - D65 \n - 120 cd/m² \n - Gamma 2.2 \n - Matrix \n - Calibrated with i1Profiler using i1Display Pro."
    )
    ```

**Important:** The `DESCRIPTIONS` array **must** have the same number of entries as `PROFILES`, and the order must match exactly.

**Configuration Files:**

The scripts and .app files automatically create configuration files at:

```
$HOME/Library/Application Support/ToggleDisplayProfile/
```
The file `icc_state` remembers the last selected profile for each .command script.   
The file `config ` remembers the location of the .command script when using the .app files.

Multiple scripts can share these files safely using script-specific tags. Only criteria is that the file names of the .command script and the .app file must be unique for each screen they are used for.

---

## Usage

### Using the .command Scripts Directly

**Method 1: Double-click in Finder**

1. Navigate to the Toggle Display Profile folder in Finder
2. Double-click `ToggleDisplayProfile_Main.command` or `ToggleDisplayProfile_Second.command`
3. A Terminal window will open
4. An AppleScript dialog will appear with your profile list
5. Select a profile and click "OK"
6. The profile will be applied to the target display
7. A success message will show the applied profile and description

**Method 2: Run from Terminal**

1. Open Terminal
2. Navigate to the script folder:

   ```bash
   cd "/path/to/Toggle_Display_Profile"
   ```
3. Run the script:

   ```bash
   ./ToggleDisplayProfile_Main.command
   ```
   or
   
   ```bash
   ./ToggleDisplayProfile_Second.command
   ```

**Dialog Behavior:**

- All profiles are listed with the current profile marked "(current)"
- The next profile in the list is preselected for quick switching
- Click "OK" to apply the selected profile
- Click "Cancel" to close without changes (Terminal will close automatically)

### Using the Automator Apps

**First Run:**

1. Double-click `Toggle Display Profile-Main.app` or `Toggle Display Profile-Second.app` (or click once if icon is in the Dock).
2. The app will ask for the location of the corresponding `.command` script.  
3. Navigate to the Toggle Display Profile folder.  
4. Select the appropriate `.command` file:   
   - Main app → `ToggleDisplayProfile_Main.command`.  
   - Second app → `ToggleDisplayProfile_Second.command`.  

5. The app will store this path and run the script

**Subsequent Runs:**

1. Double-click the app (or click once if icon is in the Dock).   
2. It will automatically run the stored script.  
3. The profile selection dialog will appear.  
4. Select and apply a profile as usual.  

**If Script Path Changes:**

If you move the `.command` script to a new location, or delete the "State file" (see earlier chapter) the app will ask for the new path on the next run.

### Adding to macOS Dock

For quick access, you can add the Automator apps to your macOS Dock:

**Using macOS Menu Bar (macOS Ventura and later):**

1. Open **System Settings** → **Desktop & Dock**
2. Enable "Automatically hide and show the Dock" (optional)
3. Create an alias of the app:
   - Right-click the app → "Make Alias"
4. Drag the alias to your Desktop or a convenient location
5. Drag the alias to the right side of the Dock
6. The app will appear in the Dock for quick access

**Alternative: Add to Dock**

1. Drag the `.app` file to the Dock
2. Right-click the Dock icon → Options → "Keep in Dock"
3. Click the Dock icon to quickly run the app

**Alternative: Keyboard Shortcut**

You can create a keyboard shortcut using Automator or third-party tools:

1. Open Automator
2. Create a new "Quick Action" or "Application"
3. Add "Run Shell Script" action
4. Enter: `open "/path/to/Toggle Display Profile-Main.app"`
5. Save as "Toggle Main Profile" or similar
6. In System Settings → Keyboard → Keyboard Shortcuts, assign a shortcut

---

## Example Scenarios

### Scenario 1: Switching Monitor Modes

**Setup:**
- Monitor: BenQ PD3200U with switchable sRGB/AdobeRGB modes
- Two ICC profiles: one for sRGB mode, one for AdobeRGB mode

**Workflow:**

1. **For web design (sRGB):**
   - Switch monitor to sRGB mode via monitor controls
   - Run `Toggle Display Profile-Main.app`
   - Select the sRGB profile
   - Work on web content with accurate colors

2. **For photography (AdobeRGB):**
   - Switch monitor to AdobeRGB mode via monitor controls
   - Run `Toggle Display Profile-Main.app`
   - Select the AdobeRGB profile
   - Edit photos with wider color gamut

**Result:** Colors are displayed accurately for each workflow mode.

### Scenario 2: Wide-Gamut Display for sRGB Work

**Setup:**
- Display: Wacom Cintiq Pro 24 (99% AdobeRGB gamut)
- ICC profile with Perceptual intent for sRGB content
- Software: Photoshop set to manage colors with this profile

**Workflow:**

1. Open Photoshop
2. Set color management to use the ICC profile made with Perceptual intent for sRGB (typically done with ArgyllCMS).
3. Run `Toggle Display Profile-Main.app`
4. Select the ICC profile with sRGB Perceptual intent.
5. Work on sRGB images
6. Colors appear correctly (not oversaturated)

**Result:** sRGB images display accurately on the wide-gamut display.

### Scenario 3: Day/Night Luminance Switching

**Setup:**
- Monitor calibrated for two luminance levels:
  - Daytime: 120 cd/m²
  - Nighttime: 80 cd/m²
- Two corresponding ICC profiles

**Workflow:**

1. **Daytime work:**
   - Run `Toggle Display Profile-Main.app`
   - Select the 120 cd/m² profile
   - Work comfortably in bright environment

2. **Nighttime work:**
   - Run `Toggle Display Profile-Main.app`
   - Select the 80 cd/m² profile
   - Work comfortably in dim environment

**Result:** Appropriate brightness for ambient lighting conditions.

### Scenario 4: Dual-Monitor Setup

**Setup:**
- Primary display: Wide-gamut monitor for color-critical work
- Secondary display: Standard monitor for tools and reference
- Different profile sets for each display

**Workflow:**

1. **Configure primary display:**
   - Use `ToggleDisplayProfile_Main.command` with wide-gamut profiles
   - Create app: `Toggle Display Profile-Main.app`

2. **Configure secondary display:**
   - Use `ToggleDisplayProfile_Second.command` with standard profiles
   - Create app: `Toggle Display Profile-Second.app`

3. **Switch profiles independently:**
   - Run Main app to change primary display profile
   - Run Second app to change secondary display profile

**Result:** Each display has appropriate profiles for its purpose.

---

## Files and Folder Structure

```
Toggle_Display_Profile/
├── ToggleDisplayProfile_Main.command           # Bash script for primary display
├── ToggleDisplayProfile_Second.command         # Bash script for secondary display
├── Toggle Display Profile-Main.app/            # Automator app for primary display
├── Toggle Display Profile-Second.app/          # Automator app for secondary display
├── README.md                                   # Basic project description
├── index.md                                    # This user guide
configuration

User Data (created automatically):
└── ~/Library/Application Support/ToggleDisplayProfile/
    └── icc_state                               # Persistent state file
    └── config                                  # Persistent command path
```

**State File Format:**

The `icc_state` file stores the last selected profile index for each script:

```
ToggleDisplayProfile_Main.command=1
ToggleDisplayProfile_Second.command=0
```

Each line uses the script filename as a tag, allowing multiple scripts to share the same state file.

Similar logic is used for config file tags.

---

## Configuration Parameters

**DISPLAY_NUMBER**

- **Purpose:** Specifies which display `dispwin` should target
- **Values:** 
  - `1` = Primary display
  - `2` = Secondary display
- **Detection:** Run `dispwin -d` to list available displays
- **Note:** Must match ArgyllCMS display numbering (not macOS UI numbering)

**PROFILE_DIR**

- **Purpose:** Base directory where ICC profiles are stored
- **Default:** `$HOME/Library/ColorSync/Profiles`.  
- **Supports:** `$HOME` expansion and paths with spaces
- **Examples:**

  - `"$HOME/Library/ColorSync/Profiles"`
  - `"$HOME/Documents/MyProfiles"`

**PROFILES**

- **Purpose:** Array of ICC profile file names (not full paths)
- **Format:** One filename per line, enclosed in quotes
- **Example:**

  ```bash
  PROFILES=(
      "Profile1.icc"
      "Profile2.icc"
      "Profile3.icc"
  )
  ```

**DESCRIPTIONS**

- **Purpose:** Human-readable descriptions for each profile
- **Format:** One description per line, enclosed in quotes
- **Requirements:** Must match `PROFILES` array length and order
- **Recommended content:**
  - Monitor/model name
  - Color space (sRGB, AdobeRGB, etc.)
  - White point (D65, D50, etc.)
  - Luminance (cd/m²)
  - Gamma (2.2, sRGB, etc.)
  - Profile type (cLUT-Matrix, Matrix, XYZLUT)
  - Calibration tool and instrument
  - Screen settings (brightness, contrast, RGB values)

---

## How It Works

### Script Execution Flow

1. **Initialization**
   - Check for ArgyllCMS (`dispwin`) availability
   - Validate `PROFILES` and `DESCRIPTIONS` arrays match
   - Verify profile directory exists
   - Create state file directory if needed

2. **State Detection**
   - Read current profile index from state file using script tag
   - If no state exists or is invalid, default to index 0 (first profile)

3. **Dialog Preparation**
   - Build profile list with current profile marked "(current)"
   - Calculate next profile index (wraps around to beginning)
   - Preselect next profile for convenient toggling

4. **User Interaction**
   - Show AppleScript dialog with profile list
   - Wait for user selection or cancellation
   - If cancelled, display message and close Terminal

5. **Profile Application**
   - Validate selected profile file exists and is readable
   - Verify profile has valid ICC/ICM extension
   - Validate `DISPLAY_NUMBER` is numeric
   - Run `dispwin -d <DISPLAY_NUMBER> -I <PROFILE_PATH>` to apply profile
   - Check for warnings in `dispwin` output

6. **State Persistence**
   - Update state file with new profile index
   - Use script-specific tag to avoid conflicts
   - Handle shared state file with multiple scripts

7. **Success Feedback**
   - Display success message in Terminal
   - Show macOS popup dialog with profile name and description
   - Exit cleanly

### ArgyllCMS dispwin Command

The scripts use the following ArgyllCMS `dispwin` command:

```bash
dispwin -d <DISPLAY_NUMBER> -I <PROFILE_PATH>
```

**Parameters:**

- `-d <DISPLAY_NUMBER>`: Target display index (1 or 2)
- `-I`: Install profile for display and use its calibration

**Output Handling:**

- Success: Profile applied, state updated
- Error: Popup dialog with error message and details
- Warning: Displayed in Terminal if detected

### State File Management

The state file uses a simple tag-based format:

```
<script_tag>=<profile_index>
```

**Example:**

```
ToggleDisplayProfile_Main.command=2
ToggleDisplayProfile_Second.command=0
```

**Update Process:**

1. Read entire state file
2. Remove existing entry for current script tag
3. Append new entry with updated index
4. Write back to file

This allows multiple scripts to safely share one state file.

---

## Important Notes and Best Practices

### Profile Calibration

- **Ensure monitor hardware mode matches the profile:** If your monitor has switchable modes (sRGB, AdobeRGB, etc.), switch the hardware mode before applying the matching ICC profile.
- **Use appropriate calibration tools:** Profiles should be created with a colorimeter/spectrophotometer (X-Rite i1Display Pro, Colormunki Display, i1Studio, Datacolor SpyderX etc.) with tools like DisplayCAL, i1Profiler, Calibrite, or Datacolor software.
- **Match luminance settings:** The screen brightness/contrast settings listed in profile descriptions should be set on the monitor for accurate color reproduction.

### Color Management in Applications

- **Enable color management:** In applications like Photoshop, Krita, or GIMP, ensure color management is enabled.
- **Use correct rendering intent:** For wide-gamut displays working on sRGB content, use **Perceptual intent** to map out-of-gamut colors appropriately.
- **Select the right profile:** Make sure your application is using the currently applied ICC profile as the working space or display profile.

### Script Configuration

- **Keep descriptions accurate:** Update profile descriptions whenever you recalibrate or create new profiles.
- **Match array lengths:** Always ensure `PROFILES` and `DESCRIPTIONS` arrays have the same number of entries.
- **Use correct display numbers:** Run `dispwin -d` to verify display numbering if you're unsure which number corresponds to which display.

### Workflow Tips

- **Preselect next profile:** The script automatically preselects the next profile in the list, making it easy to cycle through profiles quickly.
- **Use Automator apps:** The .app files provide convenient clickable access and can be added to the Dock.
- **Create keyboard shortcuts:** For the fastest access, create keyboard shortcuts to launch the Automator apps.

### Performance and Reliability

- **Profile validation:** The script validates profile files before application, preventing errors from missing or invalid files.
- **Error handling:** Clear error messages are displayed in both Terminal and popup dialogs for easy troubleshooting.
- **State persistence:** The last selected profile is remembered between runs, maintaining your workflow state.

---

## Troubleshooting

### Script won't run

**Problem:** Double-clicking the `.command` file doesn't open it.

**Solutions:**

1. **Check execute permissions:**

   ```bash
   ls -l ToggleDisplayProfile_Main.command
   ```
   Look for `-rwxr-xr-x` (execute bit set). If not set:
   
   ```bash
   chmod +x ToggleDisplayProfile_Main.command
   ```

2. **Try Ctrl+right-click → Open:**

   - Right-click (or Ctrl+click) the file
   - Select "Open"
   - Click "Open" in the security dialog

3. **Run from Terminal:**

   ```bash
   ./ToggleDisplayProfile_Main.command
   ```

### Script does not find ArgyllCMS

**Problem:** Error message "ArgyllCMS (dispwin) not found"

**Solutions:**

1. **Verify ArgyllCMS is installed:**

   ```bash
   brew list argyll-cms
   ```

2. **Install ArgyllCMS:**

   ```bash
   brew install argyll-cms
   ```

3. **Verify dispwin is available:**

   ```bash
   dispwin -?
   ```

4. **Check PATH variable:**

   ```bash
   echo $PATH | grep argyll
   ```

### Profile file not found

**Problem:** Error message "Profile file not found"

**Solutions:**

1. **Verify profile directory:**
   - Check `PROFILE_DIR` in the script
   - Ensure the directory exists: `ls "$HOME/Library/ColorSync/Profiles"`

2. **Verify profile filename:**
   - Check `PROFILES` array in the script
   - Ensure filenames match exactly (case-sensitive)
   - Verify files exist: `ls "$HOME/Library/ColorSync/Profiles/*.icc"`

3. **Check for typos:**
   - Profile filenames in `PROFILES` array must match actual filenames
   - No extra spaces or quotes

### Profile not applied correctly

**Problem:** Profile appears to apply but colors don't change

**Solutions:**

1. **Verify display number:**
   - Run `dispwin -d` to list displays
   - Ensure `DISPLAY_NUMBER` matches the target display

2. **Check monitor hardware mode:**
   - If monitor has switchable modes, ensure hardware mode matches profile
   - Example: sRGB profile requires sRGB hardware mode

3. **Restart applications:**
   - Some applications need to be restarted to recognize new profiles
   - macOS may need a moment to update color management

4. **Verify profile is valid:**
   - Open profile in ColorSync Utility to verify it's valid
   - Check profile description and intended use

### Dialog doesn't appear

**Problem:** Terminal opens but no profile selection dialog appears

**Solutions:**

1. **Check AppleScript permissions:**
   - System Settings → Privacy & Security → Automation
   - Ensure Terminal has permission to control System Events

2. **Check for Terminal focus issues:**
   - The script attempts to bring Terminal to front
   - Check if dialog is hidden behind other open windows

3. **Run from Terminal directly:**

   ```bash
   ./ToggleDisplayProfile_Main.command
   ```
   Watch for error messages in Terminal output

### Automator app asks for script location repeatedly

**Problem:** The .app asks for the script location every time it's run

**Solutions:**

1. **Check configuration path:**
   - The app stores the script path in config file.
   - If the script moved, the app will ask for the new location.
   - The app must have write permission to configuration path to remember path.

2. **Keep script in consistent location:**
   - Place scripts in a permanent location
   - Avoid moving scripts after initial configuration

3. **Reconfigure app:**
   - When prompted, select the correct `.command` file
   - The app will remember the new path

### State file issues

**Problem:** Script doesn't remember last selected profile

**Solutions:**

1. **Check state file location:**

   ```bash
   ls -la "$HOME/Library/Application Support/ToggleDisplayProfile/"
   ```

2. **Verify state file contents:**

   ```bash
   cat "$HOME/Library/Application Support/ToggleDisplayProfile/icc_state"
   ```

3. **Check permissions:**

   ```bash
   ls -l "$HOME/Library/Application Support/ToggleDisplayProfile/icc_state"
   ```
   Should be readable and writable

4. **Delete state file to reset:**

   ```bash
   rm "$HOME/Library/Application Support/ToggleDisplayProfile/icc_state"
   ```
   Script will recreate it on next run

### Multiple displays not working correctly

**Problem:** Both scripts seem to affect the same display

**Solutions:**

1. **Verify display numbering:**

   ```bash
   dispwin -d
   ```
   This lists all displays with their ArgyllCMS numbers

2. **Check DISPLAY_NUMBER settings:**
   - Main script should have `DISPLAY_NUMBER="1"`
   - Second script should have `DISPLAY_NUMBER="2"`

3. **Test each script independently:**
   - Run Main script, observe which display changes
   - Run Second script, observe which display changes
   - Adjust `DISPLAY_NUMBER` if needed

---

**End of User Guide**

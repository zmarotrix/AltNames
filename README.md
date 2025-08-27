# AltNames for Vanilla WoW (1.12)

A lightweight addon that displays a character's "main" name next to their alt's name in chat, making it easier to identify who you're talking to.

## Features

-   **Automatic Main Detection**: Automatically scans your guild roster and identifies mains based on public notes (e.g., "John's alt").
-   **Manual Override**: Easily set any player's main character by right-clicking their name in chat, whether they are in your guild or not.
-   **Seamless Chat Integration**: Displays the main's name as a prefix in all major chat channels (Guild, Party, Raid, Say, Whisper, World, etc.).
-   **Persistent Storage**: Remembers the relationships you set between alts and mains.
-   **Lightweight**: Minimal memory and CPU usage.

---

## How It Works

The addon uses two methods to associate an alt with a main:

1.  **Automatic Guild Scan (Primary Method)**
    The addon reads the public notes in your guild roster. If a note for a character named `AltChar` is set to something like `"MainChar alt"` or `"MainChar's alt"`, the addon will automatically learn that `AltChar` is an alt of `MainChar`. This scan occurs when you log in and whenever the guild roster is updated.

2.  **Manual Set via Right-Click (Secondary Method)**
    You can manually create or override any association. Simply right-click a player's name in any chat window and select **"Set Main Name"** from the context menu. A popup will appear asking you to enter the name of their main character. This is useful for friends outside your guild or for guild members who don't use the public note convention.

Once an association is made, whenever that alt speaks, their message will be prefixed with their main's name. For example:

> **Original:** `[Guild] [AltChar]: LFG for Stratholme`
>
> **With AltNames:** `[Guild] [MainChar]: [AltChar]: LFG for Stratholme`

---

## Installation

1.  Download the latest version of the addon.
2.  Unzip the downloaded file.
3.  Copy the `AltNames` folder into your `World of Warcraft\Interface\AddOns` directory.
4.  Restart World of Warcraft.

---

## Usage

### Setting a Main Automatically (for Guild Members)

-   Ask your guild members to set the public note on their alt characters to the format `MainName alt`.
-   For example, if your main is `MyPaladin` and you are on your alt `MyRogue`, your guild note for `MyRogue` should be `MyPaladin alt`.
-   The addon will automatically detect this and display `MyPaladin` whenever `MyRogue` speaks.

### Setting a Main Manually

1.  Right-click the name of the alt character in any chat channel.
2.  Click **"Set Main Name"** in the menu that appears.
3.  In the pop-up box, type the name of their main character.
4.  Click **"Accept"**.

### Removing or Changing a Main

1.  Follow the steps for setting a main manually.
2.  **To change:** Enter the new main's name and click "Accept".

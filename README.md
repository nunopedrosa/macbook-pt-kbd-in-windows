# MacBook Portuguese keyboard in Windows / UTM

Windows' built-in Portuguese (Portugal) layout is the PC Portuguese layout. Apple's Portuguese Mac layout moves several keys around the right side of the keyboard. This project keeps Windows' Portuguese layout for the base and letters, then uses an AutoHotkey v2 helper to remap the Mac-specific positions.

## Install

1. Install **AutoHotkey v2** in the Windows VM from [autohotkey.com](https://www.autohotkey.com/).
2. Copy both `Install-MacBookPortugueseLayout.ps1` and `MacBookPortugueseDeadKeys.ahk` into the VM, in the same folder.
3. Open Windows PowerShell in that folder and run:

   ```powershell
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Install-MacBookPortugueseLayout.ps1
   ```

The installer adds Portuguese (Portugal), makes it the default input layout, starts the helper, and adds the helper to the Windows Startup folder. It does not need administrator access. Use `-AddOnly` to add Portuguese without changing the current default.

## Mac-specific mappings

- Key immediately right of `Ç`: dead `~`; Shift gives dead `^`. Typing a vowel after it composes `ã`, `õ`, `â`, `ê`, `î`, `ô`, or `û`. Space types the accent by itself.
- Key immediately left of Backspace: `+` / `*`.
- Key immediately right of `P`: `º` / `ª`.
- Key beside Enter: `\` / `|`.
- Upper-left key: grave accent / `~`.
- ISO key beside left Shift: `<` / `>`.
- Right Alt (AltGr) keeps the Mac Portuguese bracket, brace, fraction, not-sign, diaeresis, grave, and breve mappings on the corresponding keys.

*NOTE*: Through UTM in Windows, Both option keys operate differently. Left option + 3 outputs the € symbol. Right option outputs the £ symbol.

The helper composes the common tilde, circumflex, diaeresis, grave, and breve vowel combinations. Other letters are emitted after the accent unchanged. A pending accent prints by itself after 5 seconds if no letter follows; Space emits it immediately and Escape cancels it.

## UTM ISO key

UTM documents that some QEMU VMs swap the ISO key beside left Shift with the leftmost number-row key. If `<` / `>` appear on the wrong key, enable **Swap the leftmost key ...** in the VM's UTM settings, then restart the VM. See [UTM input settings](https://docs.getutm.app/preferences/macos/#input).

The Windows base layout is Microsoft's Portuguese profile `0816:00000816` ([profile reference](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/default-input-locales-for-windows-language-packs?view=windows-11)); the helper remaps the Mac-specific physical keys on top of it.


Configure Auto-Start with Windows 11

To make sure this script boots completely silently in the background every single time your VM turns on without forcing you to click it manually:
1. Press the Windows Key + R to open the Run window.
2. Type shell:startup and hit Enter. This opens your account's hidden Windows Startup directory.
3. Right-click your MacBookPortugueseLayout.ahk file and select Show more options -> Create shortcut.
4. Cut and paste that newly created shortcut straight into the Startup folder you opened in Step 2.
5. You're done! On your next login, the engine activates instantly.
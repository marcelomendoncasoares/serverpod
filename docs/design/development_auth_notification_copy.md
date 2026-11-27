# Copy from development notifications

Follow-up exploration for the text-only notification implementation. No Copy
callback, clipboard write, app registration, or additional dependency is shipped
by this change.

## Findings

| Platform | Smallest plausible enhancement | Limit |
| --- | --- | --- |
| Windows 11 | Let Windows recognize the verification code and offer its own Copy button. | OS heuristic, not an application contract; not yet confirmed on the tested host. |
| WSL → Windows | The same Windows detection, since delivery is a Windows toast. | Same OS and language limits as native Windows. |
| Linux desktop | `notify-send --action=copy=Copy`, then copy only after its action result. | Needs action support, a clipboard mechanism, and a process waiting for the user. |
| macOS | An actionable notification with an application-owned handler. | The current AppleScript `display notification` command does not expose a custom action callback. |

### Windows: try the OS feature first

Microsoft introduced automatic Copy buttons for detected verification codes in
Windows 11. Its announcement describes detection as best effort; the release
documentation identifies an English-language limitation. This is a promising
zero-dependency bonus, but cannot be promised for every OS version, locale,
notification wording, or sender. See the [Windows announcement][windows-copy]
and [release documentation][windows-release].

Two dummy notifications were submitted using the production helper: the current
`Login code: 824691` wording and `Your verification code is 752306.` Both calls
succeeded. Visual confirmation of an OS-provided Copy button is pending; command
success does not establish that the button appeared or copied the code.

Adding our own button is a different scope. Toast actions deliver arguments to an
activation handler; a button label does not itself write the clipboard. The
documented console-app route uses the Windows App SDK and registers a COM
activation handler. Reusing PowerShell's existing sender for text does not give
the Dart runner its own registered callback. See [toast actions][windows-actions]
and [console notification activation][windows-console].

### Linux: an optional capability

The installed libnotify 0.8.3 `notify-send --help` confirms that `--action` implies
waiting and returns the selected action name on stdout. The desktop protocol
defines `ActionInvoked`, but implementations may omit interactive actions. See
the [Desktop Notifications Specification][linux-actions].

A potential implementation would detect action support and an available clipboard
utility, offer Copy only when both are present, and copy the code after receiving
the matching action. The current eight-second helper deadline is for submission,
so an interaction process would need a separate bounded lifetime and cancellation
on restart, expiry, dismissal, and code replacement. Neither `wl-copy` nor
`xclip` is installed in the test environment, and it has no Linux notification
daemon. No interactive Linux Copy behavior has been validated.

### macOS: outside the simple command

AppleScript's [display notification][apple-script] accepts text, title, subtitle,
and sound. Custom actions use notification categories and an application handler
in [UserNotifications][apple-actions]. That adds an application lifecycle and
distribution work beyond the current command-only implementation. A dialog with
a Copy button would be a separate, more intrusive UX.

## Recommendation

Keep text delivery as the common baseline. Treat Windows' automatic Copy as a
possible OS-provided bonus, and validate it before changing wording specifically
for detection. A Linux-only optional action is feasible to investigate on a real
desktop. A consistent application-owned Copy button across all platforms would
be a separate helper/activation project, not a small change to the current script.

For any future callback, use an opaque notification identifier mapped to a
short-lived code in the runner, never a command or URL containing the code.
Copy only after an explicit click; ignore callbacks after disposal, replacement,
or expiry. Preserve the existing activation guards and never auto-overwrite the
user's clipboard when a code arrives.

[windows-copy]: https://blogs.windows.com/windows-insider/2023/03/08/announcing-windows-11-insider-preview-build-23403/
[windows-release]: https://support.microsoft.com/en-gb/servicing/os/configuration-updates/2023/05/may-24-2023-windows-configuration-update
[windows-actions]: https://learn.microsoft.com/en-us/uwp/schemas/tiles/toastschema/element-action
[windows-console]: https://learn.microsoft.com/en-us/windows/apps/develop/notifications/app-notifications/app-notifications-console
[linux-actions]: https://specifications.freedesktop.org/notification/latest-single/
[apple-script]: https://developer.apple.com/library/archive/documentation/LanguagesUtilities/Conceptual/MacAutomationScriptingGuide/DisplayNotifications.html
[apple-actions]: https://developer.apple.com/documentation/usernotifications/declaring-your-actionable-notification-types

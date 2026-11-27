# Copy from development notifications

Follow-up exploration for the text-only notification implementation. No Copy
callback, clipboard write, app registration, or additional dependency is shipped
by this change.

## Findings

| Platform | Smallest plausible enhancement | Limit |
| --- | --- | --- |
| Windows 11 | Let Windows recognize the verification code and offer its own Copy button. | Button observed on the tested host; clipboard result and wording-specific behavior remain unverified. |
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
succeeded. The user confirmed seeing a Copy button. The exact wording that
triggered it and the resulting clipboard content were not reported, so this
establishes button visibility, not completed copy behavior.

The sender label was Windows PowerShell, as expected when using its installed
identity. The user also reported that the notifications were absent from
Notification Center after the banners disappeared. The implementation requests
one-minute expiration, compared with ten minutes in the original probe. A
controlled comparison using the production helper found both entries in Windows
history at 36 seconds; at 76 seconds, only the ten-minute control remained. The
user also confirmed seeing the entries in Notification Center. This verifies
expiration separately from banner dismissal; it does not establish the timing
of the earlier observation. Sender branding and retention are separate concerns.

Adding our own button is a different scope. Toast actions deliver arguments to an
activation handler; a button label does not itself write the clipboard. The
documented console-app route uses the Windows App SDK and registers a COM
activation handler. Reusing PowerShell's existing sender for text does not give
the Dart runner its own registered callback. See [toast actions][windows-actions]
and [console notification activation][windows-console].

### Clicking the notification body

The notification itself can be the click target: Windows exposes an
[Activated event][windows-activated]. The current one-shot helper does not
subscribe and exits after submission, so clicking its text does not copy.
Windows' automatic Copy button is independent of this event.

A local prototype successfully subscribed with built-in PowerShell 5.1 and
.NET. `Register-ObjectEvent` rejects WinRT events on the tested machine; calling
`add_Activated` directly with a managed delegate succeeds. The delegate signals
the waiting PowerShell thread, which can run `Set-Clipboard` after the click.
This uses no companion executable, downloaded module, or app registration, but
does require a longer-lived process and Windows-specific scripting.

Subscription success alone does not establish delivery from Notification
Center. Microsoft's [desktop sample][windows-desktop-sample] uses COM activation
for that path. In the live experiment, the user clicked the notification body
from Notification Center while the ten-minute listener was still running.
No activation event arrived and no clipboard write was attempted; the user
confirmed that nothing was copied. Separately invoking the delegate confirmed
that it signals the listener, without accessing the clipboard. Banner clicks
were not tested. The unregistered listener therefore does not satisfy the
Notification Center requirement on this host.

Reliable body-click handling needs a supported activation route, such as an
application-owned COM activator. It can be headless: a window or Flutter app is
not required. It does add Windows registration, callback handling, and cleanup,
beyond the current one-shot command. No such registration or callback is shipped
by this change.

### Linux: an optional capability

The installed libnotify 0.8.3 `notify-send --help` confirms that `--action` implies
waiting and returns the selected action name on stdout. The desktop protocol
defines `ActionInvoked`, but implementations may omit interactive actions. See
the [Desktop Notifications Specification][linux-actions].

For a body click, the same specification reserves the `default` action key;
`notify-send --action=default=Copy` is a candidate on desktops supporting actions.
The desktop decides how to render and invoke it, so behavior needs validation.

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
for detection. The unregistered Windows listener failed the Notification Center
interaction; do not ship it as click-to-copy. A registered, headless Windows
activation route and Linux's default action remain possible follow-ups. A
consistent click-to-copy experience across all platforms needs platform-specific
activation and clipboard handling.

For any future callback, use an opaque notification identifier mapped to a
short-lived code in the runner, never a command or URL containing the code.
Copy only after an explicit click; ignore callbacks after disposal, replacement,
or expiry. Preserve the existing activation guards and never auto-overwrite the
user's clipboard when a code arrives.

[windows-copy]: https://blogs.windows.com/windows-insider/2023/03/08/announcing-windows-11-insider-preview-build-23403/
[windows-release]: https://support.microsoft.com/en-gb/servicing/os/configuration-updates/2023/05/may-24-2023-windows-configuration-update
[windows-actions]: https://learn.microsoft.com/en-us/uwp/schemas/tiles/toastschema/element-action
[windows-console]: https://learn.microsoft.com/en-us/windows/apps/develop/notifications/app-notifications/app-notifications-console
[windows-activated]: https://learn.microsoft.com/en-us/uwp/api/windows.ui.notifications.toastnotification.activated?view=winrt-26100
[windows-desktop-sample]: https://github.com/microsoft/Windows-classic-samples/blob/main/Samples/DesktopToasts/CPP/DesktopToastsSample.cpp
[linux-actions]: https://specifications.freedesktop.org/notification/latest-single/
[apple-script]: https://developer.apple.com/library/archive/documentation/LanguagesUtilities/Conceptual/MacAutomationScriptingGuide/DisplayNotifications.html
[apple-actions]: https://developer.apple.com/documentation/usernotifications/declaring-your-actionable-notification-types

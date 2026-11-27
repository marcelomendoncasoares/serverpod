# Local development authentication notifications

When an agent runs the server, the user may never see its terminal. The local
runner can also deliver email verification codes as desktop notifications, while
keeping the existing terminal alerts and normal code verification.

## Opt-in and compatibility

```dart
ServerpodCloudEmailIdpConfig(
  appDisplayName: 'My app',
  enableDevelopmentNotifications: true,
)
```

The flag defaults to false. New-project templates explicitly enable it. Existing
projects retain their current behavior until they opt in. This option covers the
default cloud email provider's registration, password-reset, and OTP-login
senders; custom email callbacks are unchanged.

There is no widget in the Flutter application, authentication bypass, fixed code,
public code endpoint, new native dependency, or companion application.

## Activation boundary

All of these must hold before a server publishes a notification:

- The email configuration opts in and its resolved mode is `development`.
- The actual Serverpod instance runs in `development`. A configuration override
  cannot enable notifications in a production instance.
- The configured API public host is a literal loopback address or `localhost`.
- The session has a request whose actual socket peer is loopback. Forwarding
  headers are never used as proof of a local client.
- The request URL and a single Host header identify the same loopback host and
  listener port. Wildcard bind addresses and localhost-looking domains fail.
- Any Origin is a single HTTP(S) loopback origin without credentials, a path,
  query, or fragment. An absent Origin supports native clients; `null` does not.
- No `Forwarded`, `X-Forwarded-*`, or `X-Real-IP` header is present.
- The process has a valid ephemeral capability supplied by its local runner.

The runner creates a fresh capability for each child process and only consumes
events with that capability. It clears inherited capabilities outside development
mode, in CI, and in SSH sessions. Staging and production continue ordinary email
delivery even when the flag is true; test mode continues logging.

Loopback does not prove how traffic reached the machine. A transparent tunnel
that rewrites all context to look local cannot reliably be detected by Host or
Origin checks. These guards prevent accidental remote use; they are not a
security boundary against other processes already running as the developer.
Remote development, containers or WSL networking that presents a non-loopback
peer, and non-local device testing keep the normal email/log workflow.

## Transport and delivery

The shared protocol is a bounded, typed payload on the server's existing VM
service connection. It is not copied into runner log history or attach snapshots.
The runner owns delivery, so an attached terminal is unnecessary and adding a
second terminal cannot replay a notification. Normal development code logs
continue to exist as before.

Platform commands use existing OS facilities:

| Host | Command | Notes |
| --- | --- | --- |
| macOS | `/usr/bin/osascript` | Plain `display notification`; text passed as arguments. |
| Windows | Windows PowerShell / WinRT toast | Uses the installed PowerShell sender identity; JSON input, XML text nodes. |
| WSL | Windows PowerShell through interop | Finds Windows drive mounts even when Windows is missing from PATH. |
| Linux desktop | `notify-send` | Requires the utility and a desktop notification service. |

No shell interprets user data. Helper output is drained without logging codes.
Subprocesses have an eight-second deadline and are terminated on child teardown.
While a helper runs, only the newest pending notification is retained. OS policy
can hide banners or disable notifications; failures never change auth responses.
Codes may remain in OS history or previews. Windows requests one-minute expiry;
other platforms apply their own retention policy. Code validity still comes from
the auth provider and is never extended by a notification.

The initial manual probes confirmed Notification Center delivery on macOS,
Windows-native Dart, and Linux Dart through WSL. The production helper was also
verified through a real guarded email callback and VM event, including a Windows
localhost HTTP request into the WSL server. Windows history retained the exact
payloads, including Unicode text sent by native Windows Dart. A real Ubuntu desktop remains
to be verified. No permission prompt appeared on the tested Mac; this does not
establish first-use behavior for a fresh account. Copy actions are a separate
enhancement, not part of this first increment.

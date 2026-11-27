import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

/// A text notification command, with content kept separate from script syntax.
class DesktopNotificationCommand {
  const DesktopNotificationCommand(
    this.executable,
    this.arguments, {
    this.input,
  });

  final String executable;
  final List<String> arguments;
  final String? input;

  /// Resolves existing OS tools. Returns null on unsupported/headless hosts.
  static DesktopNotificationCommand? resolve({
    required String title,
    required String body,
    String? operatingSystem,
    Map<String, String>? environment,
    String? wslPowerShell,
  }) {
    final os = operatingSystem ?? Platform.operatingSystem;
    final env = environment ?? Platform.environment;
    if (os == 'macos') {
      return DesktopNotificationCommand('/usr/bin/osascript', [
        '-l',
        'AppleScript',
        '-',
        title,
        body,
      ], input: _appleScript);
    }
    if (os == 'windows' || (os == 'linux' && wslPowerShell != null)) {
      final root = env['SystemRoot'] ?? env['WINDIR'];
      if (os == 'windows' && (root == null || root.isEmpty)) return null;
      final executable =
          wslPowerShell ??
          p.windows.join(
            root!,
            'System32',
            'WindowsPowerShell',
            'v1.0',
            'powershell.exe',
          );
      final encoded = base64Encode(
        _powerShell.codeUnits
            .expand((unit) => [unit & 255, unit >> 8])
            .toList(),
      );
      return DesktopNotificationCommand(
        executable,
        [
          '-NoLogo',
          '-NoProfile',
          '-NonInteractive',
          '-EncodedCommand',
          encoded,
        ],
        input: jsonEncode({
          'title': title,
          'body': body,
          'group':
              'Serverpod-${title.hashCode.toUnsigned(32).toRadixString(16)}',
        }),
      );
    }
    if (os == 'linux' &&
        (env['DISPLAY']?.isNotEmpty == true ||
            env['WAYLAND_DISPLAY']?.isNotEmpty == true)) {
      return DesktopNotificationCommand('notify-send', [
        '--app-name=Serverpod',
        '--expire-time=15000',
        '--',
        title,
        const HtmlEscape().convert(body),
      ]);
    }
    return null;
  }
}

/// Best-effort desktop delivery without installing or registering an app.
///
/// Each process is bounded and is killed on timeout or runner disposal. Output
/// is drained without logging it: helper errors can include the supplied code.
class DesktopNotifier {
  DesktopNotifier({this.timeout = const Duration(seconds: 8)});

  final Duration timeout;
  final Set<Process> _processes = {};
  bool _closed = false;

  Future<bool> show({required String title, required String body}) async {
    final command = DesktopNotificationCommand.resolve(
      title: title,
      body: body,
      wslPowerShell: _wslPowerShell(),
    );
    if (command == null) return false;
    return execute(command);
  }

  /// Executes a resolved command without a shell. Used by all platform paths.
  Future<bool> execute(DesktopNotificationCommand command) async {
    if (_closed) return false;
    Process? process;
    try {
      process = await Process.start(command.executable, command.arguments);
      if (_closed) {
        _terminate(process);
        return false;
      }
      _processes.add(process);
      final output = Future.wait([
        process.stdout.drain<void>(),
        process.stderr.drain<void>(),
      ]);
      final current = process;
      final completion = () async {
        if (command.input case final input?) current.stdin.write(input);
        await current.stdin.close();
        final code = await current.exitCode;
        await output;
        return code == 0;
      }();
      return await completion.timeout(
        timeout,
        onTimeout: () {
          _terminate(current);
          return false;
        },
      );
    } on Exception {
      if (process != null) _terminate(process);
      return false;
    } finally {
      _processes.remove(process);
    }
  }

  void close() {
    _closed = true;
    for (final process in _processes) {
      _terminate(process);
    }
  }

  static void _terminate(Process process) {
    process.kill(
      Platform.isWindows ? ProcessSignal.sigterm : ProcessSignal.sigkill,
    );
  }

  static String? _wslPowerShell() {
    if (!Platform.isLinux) return null;
    try {
      final release = File('/proc/sys/kernel/osrelease').readAsStringSync();
      if (!release.toLowerCase().contains('microsoft')) return null;
      // WSL may exclude Windows executables from PATH, or mount Windows on a
      // drive other than C. Do not use WSL_DISTRO_NAME as the only detector.
      for (final drive in Directory('/mnt').listSync().whereType<Directory>()) {
        if (!RegExp(r'^[a-zA-Z]$').hasMatch(p.basename(drive.path))) continue;
        final executable = p.join(
          drive.path,
          'Windows',
          'System32',
          'WindowsPowerShell',
          'v1.0',
          'powershell.exe',
        );
        if (File(executable).existsSync()) return executable;
      }
    } on FileSystemException {
      // No accessible Windows tool: normal log delivery remains available.
    }
    return null;
  }
}

const _appleScript = '''
on run argv
  display notification (item 2 of argv) with title (item 1 of argv)
end run
''';

// An existing Windows PowerShell sender avoids app installation/registration.
// This intentionally has no activation action or clipboard side effect.
const _powerShell = r'''
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Console]::InputEncoding = [Text.UTF8Encoding]::new($false)
[Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)
$data = [Console]::In.ReadToEnd() | ConvertFrom-Json
$null = [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]
$null = [Windows.UI.Notifications.ToastNotification, Windows.UI.Notifications, ContentType = WindowsRuntime]
$null = [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]
$appId = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
$notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($appId)
if ($notifier.Setting.ToString() -ne 'Enabled') { exit 1 }
$xml = New-Object Windows.Data.Xml.Dom.XmlDocument
$xml.LoadXml('<toast duration="long"><visual><binding template="ToastGeneric"><text></text><text></text></binding></visual><audio silent="true"/></toast>')
$nodes = $xml.GetElementsByTagName('text')
$null = $nodes.Item(0).AppendChild($xml.CreateTextNode($data.title))
$null = $nodes.Item(1).AppendChild($xml.CreateTextNode($data.body))
$toast = [Windows.UI.Notifications.ToastNotification]::new($xml)
$toast.Tag = 'auth'
$toast.Group = $data.group
$toast.ExpirationTime = [DateTimeOffset]::Now.AddMinutes(1)
$notifier.Show($toast)
''';

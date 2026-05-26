import 'dart:io';

import 'package:cli_tools/cli_tools.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cli/src/generated/version.dart';
import 'package:serverpod_cli/src/runner/serverpod_command.dart';
import 'package:serverpod_cli/src/util/sdk_path.dart';
import 'package:serverpod_cli/src/util/serverpod_cli_logger.dart';
import 'package:serverpod_cli/src/version_delegate/cached_cli.dart';
import 'package:serverpod_cli/src/version_delegate/process_forwarder.dart';
import 'package:serverpod_cli/src/version_delegate/project_serverpod_version.dart';

const _delegatedEnvVar = 'SERVERPOD_CLI_DELEGATED';
const _noDelegateEnvVar = 'SERVERPOD_CLI_NO_DELEGATE';

/// Commands that must always run on the globally installed entry CLI.
const _excludedSubcommands = {
  'create',
  'quickstart',
  'upgrade',
  'version',
  'analyze-pubspecs',
  'generate-pubspecs',
};

/// Global flags that take a value and must be skipped when extracting the
/// subcommand name.
const _globalValueFlags = {
  '--experimental-features',
};

/// Global boolean flags that must not consume the next argument as a value.
const _globalBooleanFlags = {
  '--verbose',
  '--quiet',
  '--version',
  '--interactive',
  '--no-interactive',
  '--help',
  '-v',
  '-q',
  '-h',
};

/// Returns `true` when delegation ran and the entry process should exit.
Future<bool> maybeDelegateToProjectCli(List<String> args) async {
  if (Platform.environment.containsKey(_delegatedEnvVar)) {
    return false;
  }

  if (Platform.environment[_noDelegateEnvVar] == '1') {
    return false;
  }

  if (_hasGlobalVersionFlag(args)) {
    return false;
  }

  final subcommand = extractSubcommand(args);
  if (subcommand != null && _excludedSubcommands.contains(subcommand)) {
    return false;
  }

  final result = resolveProjectServerpodVersion();
  switch (result) {
    case ProjectServerpodVersionNotFound():
    case ProjectServerpodVersionAmbiguous():
    case ProjectServerpodVersionNonHosted():
    case ProjectServerpodVersionMissingLock():
      return false;
    case ProjectServerpodVersionResolved(:final version):
      final cliVersion = Version.parse(templateVersion);
      if (version == cliVersion) {
        return false;
      }

      log.info(
        'Using Serverpod CLI $version for this project '
        '(global CLI is $cliVersion).',
      );

      try {
        await ensureServerpodCliCached(version);
      } on StateError {
        throw ExitException(ServerpodCommand.commandInvokedCannotExecute);
      }

      final entrypoint = cachedCliEntrypoint(version);
      final dartExecutable = p.join(getSdkPath(), 'bin', 'dart');
      final environment = Map<String, String>.from(Platform.environment)
        ..[_delegatedEnvVar] = '1';

      await forwardProcess(
        executable: dartExecutable,
        arguments: [entrypoint.path, ...args],
        workingDirectory: Directory.current.path,
        environment: environment,
      );

      return true;
  }
}

/// Extracts the first subcommand token from [args], skipping global flags.
String? extractSubcommand(List<String> args) {
  var i = 0;
  while (i < args.length) {
    final arg = args[i];

    if (arg == '--') {
      return null;
    }

    if (arg.startsWith('--')) {
      if (_globalValueFlags.contains(arg)) {
        i += 2;
        continue;
      }
      if (arg.contains('=')) {
        i++;
        continue;
      }
      if (_globalBooleanFlags.contains(arg)) {
        i++;
        continue;
      }
      if (_isBooleanFlagWithSeparateValue(args, i)) {
        i += 2;
        continue;
      }
      i++;
      continue;
    }

    if (arg.startsWith('-')) {
      if (_globalBooleanFlags.contains(arg)) {
        i++;
        continue;
      }
      i++;
      continue;
    }

    return arg;
  }

  return null;
}

bool _hasGlobalVersionFlag(List<String> args) {
  return args.contains('--version');
}

bool _isBooleanFlagWithSeparateValue(List<String> args, int index) {
  final arg = args[index];
  if (arg == '--interactive' || arg == '--no-interactive') {
    return false;
  }

  if (index + 1 >= args.length) {
    return false;
  }

  final next = args[index + 1];
  return !next.startsWith('-');
}

/// Visible for testing.
String get delegatedEnvVar => _delegatedEnvVar;

/// Visible for testing.
String get noDelegateEnvVar => _noDelegateEnvVar;

/// Visible for testing.
Set<String> get excludedSubcommands => _excludedSubcommands;

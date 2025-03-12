import 'package:cli_tools/cli_tools.dart';
import 'package:serverpod_cli/src/config/config.dart';
import 'package:serverpod_cli/src/create/create.dart';
import 'package:serverpod_cli/src/generator/types.dart';
import 'package:serverpod_cli/src/runner/serverpod_command.dart';
import 'package:serverpod_cli/src/util/serverpod_cli_logger.dart';

enum CreateOption<V> implements OptionDefinition<V> {
  force(FlagOption(
    argName: 'force',
    argAbbrev: 'f',
    defaultsTo: false,
    negatable: false,
    helpText:
        'Create the project even if there are issues that prevent it from '
        'running out of the box.',
  )),
  mini(FlagOption(
    argName: 'mini',
    defaultsTo: false,
    negatable: false,
    helpText: 'Shortcut for --template mini.',
    group: _templateGroup,
  )),
  template(EnumOption(
    enumParser: EnumParser(ServerpodTemplateType.values),
    argName: 'template',
    argAbbrev: 't',
    defaultsTo: ServerpodTemplateType.server,
    helpText: 'Template to use when creating a new project',
    allowedValues: ServerpodTemplateType.values,
    allowedHelp: {
      'mini': 'Mini project with minimal features and no database',
      'server': 'Server project with standard features including database',
      'module': 'Serverpod Module project',
    },
    group: _templateGroup,
  )),
  name(StringOption(
    argName: 'name',
    argAbbrev: 'n',
    argPos: 0,
    helpText: 'The name of the project to create.\n'
        'Can also be specified as the first argument.',
    mandatory: true,
  )),
  defaultIdType(EnumOption(
    enumParser: EnumParser(IdTypeAlias.values),
    argName: 'defaultIdType',
    helpText: 'Default type for primary keys.',
    allowedValues: IdTypeAlias.values,
  ));

  static const _templateGroup = MutuallyExclusive(
    'Project Template',
    mode: MutuallyExclusiveMode.allowDefaults,
  );

  const CreateOption(this.option);

  @override
  final ConfigOptionBase<V> option;
}

class CreateCommand extends ServerpodCommand<CreateOption> {
  final restrictedNames = [
    ...ServerpodTemplateType.values.map((t) => t.name),
    'create',
    'migration',
    'repair',
    'repair-migration',
  ];

  @override
  final name = 'create';

  @override
  final description =
      'Creates a new Serverpod project, specify project name (must be '
      'lowercase with no special characters).';

  CreateCommand() : super(options: CreateOption.values);

  @override
  Future<void> runWithConfig(Configuration<CreateOption> commandConfig) async {
    var template = commandConfig.value(CreateOption.mini)
        ? ServerpodTemplateType.mini
        : commandConfig.value(CreateOption.template);
    var force = commandConfig.value(CreateOption.force);
    var name = commandConfig.value(CreateOption.name);
    var defaultIdTypeAlias =
        commandConfig.optionalValue(CreateOption.defaultIdType);

    if (restrictedNames.contains(name) && !force) {
      log.error(
        'Are you sure you want to create a project named "$name"?\n'
        'Use the --${CreateOption.force.option.argName} flag to force creation.',
      );
      throw ExitException.error();
    }

    SupportedIdType? defaultIdType;

    if (defaultIdTypeAlias != null) {
      defaultIdType = SupportedIdType.fromString(defaultIdTypeAlias.name);
    } else {
      try {
        var config = await GeneratorConfig.load();
        defaultIdType = config.defaultIdType;
      } on ServerpodProjectNotFoundException catch (_) {
        // If no config file is found, it means we are creating a new project.
      } catch (_) {
        throw ExitException.error();
      }
    }

    if (!await performCreate(name, template, force, defaultIdType)) {
      throw ExitException.error();
    }
  }
}

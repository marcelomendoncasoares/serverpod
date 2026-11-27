import 'dart:async';
import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  if (args.first == 'fail') exit(1);
  if (args.first == 'wait') {
    await File(args[1]).writeAsString('$pid');
    Timer.periodic(const Duration(seconds: 1), (_) {});
    return;
  }
  final input = await stdin.transform(utf8.decoder).join();
  await File(
    args[1],
  ).writeAsString(jsonEncode({'arguments': args.sublist(2), 'input': input}));
}

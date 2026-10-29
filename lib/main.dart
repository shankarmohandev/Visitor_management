import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/visitor_provider.dart';
import 'repositories/visitor_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFF14120F),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final repository = VisitorRepository();
  final provider = VisitorProvider(repository: repository);
  await provider.init();

  runApp(
    ChangeNotifierProvider<VisitorProvider>.value(
      value: provider,
      child: const VisitorManagementApp(),
    ),
  );
}

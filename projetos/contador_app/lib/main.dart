import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme { light, dark, highContrast }

const String _kThemePrefKey = 'app_theme_mode';
const String _kCounterAKey = 'counter_a_value';
const String _kCounterBKey = 'counter_b_value';

void main() {
  runApp(const MyAppWrapper());
}

class MyAppWrapper extends StatefulWidget {
  const MyAppWrapper({super.key});
  @override
  State<MyAppWrapper> createState() => _MyAppWrapperState();
}

class _MyAppWrapperState extends State<MyAppWrapper> {
  AppTheme _current = AppTheme.light;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final idx = prefs.getInt(_kThemePrefKey) ?? 0;
    setState(() {
      _current =
          AppTheme.values.elementAt(idx.clamp(0, AppTheme.values.length - 1));
      _loaded = true;
    });
  }

  Future<void> _saveTheme(AppTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kThemePrefKey, theme.index);
  }

  void _updateTheme(AppTheme newTheme) {
    setState(() {
      _current = newTheme;
    });
    _saveTheme(newTheme);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    final themeData = _themeDataFor(_current);

    return MaterialApp(
      key: ValueKey(_current), 
      title: 'Meu Contador (Aula)',
      theme: themeData,
      home: CounterHome(
        currentTheme: _current,
        onThemeChanged: _updateTheme,
      ),
    );
  }

  ThemeData _themeDataFor(AppTheme t) {
    switch (t) {
      case AppTheme.dark:
        return ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.dark,
          ),
        );

      case AppTheme.highContrast:
        return ThemeData(
          useMaterial3: false, 
          brightness: Brightness.dark,
          primaryColor: Colors.yellow,
          scaffoldBackgroundColor: Colors.black,
          cardColor: Colors.grey.shade900,
          hintColor: Colors.yellow,

          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
            foregroundColor: Colors.yellow,
            elevation: 4,
            titleTextStyle: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.yellow,
            ),
            iconTheme: IconThemeData(color: Colors.yellow),
          ),

          textTheme: const TextTheme(
            bodyLarge: TextStyle(
              fontSize: 20,
              color: Colors.yellow,
              fontWeight: FontWeight.bold,
            ),
            bodyMedium: TextStyle(
              fontSize: 18,
              color: Colors.yellow,
            ),
            titleLarge: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.yellow,
            ),
            displayLarge: TextStyle(
              fontSize: 40,
              color: Colors.yellow,
              fontWeight: FontWeight.w900,
            ),
          ),

          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          iconButtonTheme: IconButtonThemeData(
            style: IconButton.styleFrom(
              foregroundColor: Colors.yellow,
            ),
          ),

          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.yellow,
            foregroundColor: Colors.black,
          ),

          segmentedButtonTheme: SegmentedButtonThemeData(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.selected)) {
                    return Colors.yellow; 
                  }
                  return Colors.grey.shade900;
                },
              ),
              foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.selected)) {
                    return Colors.black; 
                  }
                  return Colors.yellow; 
                },
              ),
              side: MaterialStateProperty.all(
                const BorderSide(color: Colors.yellow), 
              ),
            ),
          ),
        );

      case AppTheme.light:
      default:
        return ThemeData(
          brightness: Brightness.light,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        );
    }
  }
}

class CounterHome extends StatefulWidget {
  final AppTheme currentTheme;
  final ValueChanged<AppTheme> onThemeChanged;

  const CounterHome({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
  });

  @override
  State<CounterHome> createState() => _CounterHomeState();
}

class _CounterHomeState extends State<CounterHome> {
  int _counterA = 0;
  int _counterB = 0;

  int _stepA = 1;
  int _stepB = 1;

  @override
  void initState() {
    super.initState();
    _loadCounters();
  }

  Future<void> _loadCounters() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counterA = prefs.getInt(_kCounterAKey) ?? 0;
      _counterB = prefs.getInt(_kCounterBKey) ?? 0;
    });
  }

  Future<void> _saveCounters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kCounterAKey, _counterA);
    await prefs.setInt(_kCounterBKey, _counterB);
  }

  Future<void> _incA() async {
    setState(() => _counterA += _stepA);
    await _saveCounters();
  }

  Future<void> _decA() async {
    setState(() {
      _counterA = (_counterA - _stepA < 0) ? 0 : _counterA - _stepA;
    });
    await _saveCounters();
  }

  Future<void> _incB() async {
    setState(() => _counterB += _stepB);
    await _saveCounters();
  }

  Future<void> _decB() async {
    setState(() {
      _counterB = (_counterB - _stepB < 0) ? 0 : _counterB - _stepB;
    });
    await _saveCounters();
  }

  Future<void> _resetAll() async {
    setState(() {
      _counterA = 0;
      _counterB = 0;
      _stepA = 1;
      _stepB = 1;
    });
    await _saveCounters();
  }

  double _scaled(BuildContext context, double base) {
    final scale = MediaQuery.of(context).textScaleFactor;
    return base * scale;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayStyle = theme.textTheme.displayLarge?.copyWith(
          fontSize: _scaled(context, theme.textTheme.displayLarge?.fontSize ?? 36),
        ) ??
        TextStyle(fontSize: _scaled(context, 36), fontWeight: FontWeight.bold);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Primeiro App — Contadores'),
        centerTitle: true,
        leading: PopupMenuButton<AppTheme>(
          tooltip: 'Tema',
          onSelected: (t) => widget.onThemeChanged(t),
          icon: const Icon(Icons.color_lens),
          itemBuilder: (context) {
            return [
              const PopupMenuItem(
                value: AppTheme.light,
                child: Row(children: [
                  Icon(Icons.wb_sunny),
                  SizedBox(width: 8),
                  Text('Claro')
                ]),
              ),
              const PopupMenuItem(
                value: AppTheme.dark,
                child: Row(children: [
                  Icon(Icons.nightlight_round),
                  SizedBox(width: 8),
                  Text('Escuro')
                ]),
              ),
              const PopupMenuItem(
                value: AppTheme.highContrast,
                child: Row(children: [
                  Icon(Icons.contrast),
                  SizedBox(width: 8),
                  Text('Alto contraste (amarelo)')
                ]),
              ),
            ];
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const SizedBox(height: 6),
            const Text(
              'Dois contadores independentes. Use os botões + e - dentro de cada card.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: buildCounterCard(
                      context,
                      "Contador A",
                      _counterA,
                      _stepA, 
                      _incA,
                      _decA,
                      (newStep) => setState(() => _stepA = newStep),
                      displayStyle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: buildCounterCard(
                      context,
                      "Contador B",
                      _counterB,
                      _stepB, 
                      _incB,
                      _decB,
                      (newStep) => setState(() => _stepB = newStep),
                      displayStyle,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _resetAll,
              icon: const Icon(Icons.restart_alt),
              label: const Text("Resetar ambos"),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget buildCounterCard(
    BuildContext context,
    String label,
    int counterValue,
    int stepValue,
    VoidCallback onIncrease,
    VoidCallback onDecrease,
    ValueChanged<int> onStepChanged, 
    TextStyle displayStyle,
  ) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Text('$counterValue', style: displayStyle),
            const SizedBox(height: 16),

            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1, label: Text('1'), icon: Icon(Icons.add)),
                ButtonSegment(value: 5, label: Text('5')),
                ButtonSegment(value: 10, label: Text('10')),
              ],
              selected: {stepValue},
              onSelectionChanged: (Set<int> newSelection) {
                onStepChanged(newSelection.first);
              }
              style: ButtonStyle(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity(horizontal: -2, vertical: -2)
              ),
            ),
            const SizedBox(height: 16),

            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: onDecrease,
                  icon: const Icon(Icons.remove),
                  label: Text(' $stepValue'), 
                ),
                ElevatedButton.icon(
                  onPressed: onIncrease,
                  icon: const Icon(Icons.add),
                  label: Text(' $stepValue'), 
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

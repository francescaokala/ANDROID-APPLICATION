// ─────────────────────────────────────────────────────────────────────────────
// EXERCISE 3 — Lambda Functions & Closures (Chap 2)
// Concepts: anonymous functions, arrow functions, closures, variable capture,
//           function types, typedef, immediately invoked functions (IIFE),
//           closures as state containers
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../theme.dart';

// ── Dart: typedef (named function type) ──────────────────────────────────────
typedef Transformer<T> = T Function(T value);
typedef Predicate<T> = bool Function(T value);
typedef Combiner<A, B, R> = R Function(A a, B b);

// ── Closure: counter factory ──────────────────────────────────────────────────
/// Returns a closure that captures and increments its own state
Map<String, dynamic> makeCounter({int start = 0, int step = 1}) {
  int _count = start; // captured variable
  return {
    'increment': () { _count += step; return _count; },
    'decrement': () { _count -= step; return _count; },
    'reset': () { _count = start; return _count; },
    'value': () => _count,
  };
}

/// Closure: adder factory — captures `x`, returns a function that adds x to n
int Function(int) makeAdder(int x) => (int n) => n + x;

/// Closure: multiplier factory
int Function(int) makeMultiplier(int factor) => (int n) => n * factor;

/// Closure: range checker
bool Function(num) inRange(num min, num max) => (num v) => v >= min && v <= max;

/// Closure: memoize (captures a cache map)
Transformer<int> memoized(Transformer<int> fn) {
  final cache = <int, int>{};
  return (int n) => cache.putIfAbsent(n, () => fn(n));
}

// ── Lambda collection demos ────────────────────────────────────────────────────
final List<Map<String, dynamic>> lambdaDemos = [
  {
    'title': 'Anonymous Function',
    'concept': 'A function with no name, defined inline.',
    'code': '''// Long form
var square = (int x) {
  return x * x;
};

// Arrow shorthand (single expression)
var square = (int x) => x * x;

print(square(5)); // 25''',
    'dart_concept': 'Arrow syntax (=>) is sugar for single-expression functions',
    'tags': ['Anonymous', 'Inline', 'Arrow'],
  },
  {
    'title': 'Closure: Variable Capture',
    'concept': 'A closure captures variables from its enclosing scope, not their values at creation.',
    'code': '''int counter = 0;

// This function CLOSES OVER counter
var increment = () {
  counter++;        // captures counter
  return counter;
};

print(increment()); // 1
print(increment()); // 2  ← same counter!
print(counter);     // 2  ← outer var changed too''',
    'dart_concept': 'Closures share the variable, not a copy of it.',
    'tags': ['Closure', 'Variable Capture', 'Shared State'],
  },
  {
    'title': 'Function Factory (Currying)',
    'concept': 'A function that returns another function, with parameters baked in.',
    'code': '''// makeAdder returns a closure
int Function(int) makeAdder(int x) => (int n) => n + x;

var add5  = makeAdder(5);   // captures x=5
var add10 = makeAdder(10);  // captures x=10

print(add5(3));   // 8
print(add10(3));  // 13
print(add5(add10(1)));  // 16  ← chained!''',
    'dart_concept': 'Each call to makeAdder creates a NEW closure with its own x.',
    'tags': ['Factory', 'Currying', 'Partial Application'],
  },
  {
    'title': 'typedef & Function Types',
    'concept': 'Name a function signature with typedef for readability and reuse.',
    'code': '''// Define a type alias
typedef Transformer<T> = T Function(T value);

// Now use it as a parameter type
T applyTwice<T>(T value, Transformer<T> fn) =>
    fn(fn(value));

var double = (int n) => n * 2;
print(applyTwice(3, double)); // 12  (3→6→12)

// Works with any Transformer
var trim = (String s) => s.trim();
print(applyTwice('  hi  ', trim)); // "hi"''',
    'dart_concept': 'typedef makes complex function types readable and reusable.',
    'tags': ['typedef', 'Generic', 'Type Safety'],
  },
  {
    'title': 'Immediately Invoked Lambda',
    'concept': 'Define and call a function in the same expression (IIFE pattern).',
    'code': '''// Immediately invoked function expression (IIFE)
var result = ((int a, int b) => a * b)(6, 7);
print(result); // 42

// Useful for complex inline initialization
var config = () {
  final base = 100;
  final rate = 0.08;
  return (base * (1 + rate)).round();
}();
print(config); // 108''',
    'dart_concept': 'IIFEs are lambdas called at the moment of definition.',
    'tags': ['IIFE', 'Inline', 'Initialization'],
  },
  {
    'title': 'Closure as Counter',
    'concept': 'Closures can hold private mutable state — a lightweight alternative to a class.',
    'code': '''Map<String, Function> makeCounter({int start = 0}) {
  int _count = start; // private state
  return {
    'increment': () => ++_count,
    'decrement': () => --_count,
    'reset':     () { _count = start; return _count; },
    'value':     () => _count,
  };
}

var c = makeCounter(start: 10);
c['increment']!();  // 11
c['increment']!();  // 12
c['reset']!();      // 10''',
    'dart_concept': 'The returned map holds closures that all share the same _count.',
    'tags': ['State', 'Encapsulation', 'Lightweight OOP'],
  },
  {
    'title': 'Memoization via Closure',
    'concept': 'A closure captures a cache Map to avoid recomputing results.',
    'code': '''Transformer<int> memoized(Transformer<int> fn) {
  final cache = <int, int>{}; // captured
  return (int n) => cache.putIfAbsent(n, () => fn(n));
}

// Wrap an expensive computation
var slowSquare = (int n) {
  // imagine heavy computation here
  return n * n;
};

var fastSquare = memoized(slowSquare);
fastSquare(5);  // computed → 25
fastSquare(5);  // from cache → 25 (no re-computation)''',
    'dart_concept': 'putIfAbsent only evaluates the function on cache miss.',
    'tags': ['Memoization', 'Cache', 'Optimization'],
  },
  {
    'title': 'Lambdas in Pipelines',
    'concept': 'Compose multiple lambdas in a data pipeline using chained HOFs.',
    'code': '''var scores = [55, 82, 91, 47, 76, 88, 60];

// Pipeline: filter → map → sort → take
var topPassing = scores
  .where((s) => s >= 60)       // lambda: filter
  .map((s) => 'Score: \$s')    // lambda: transform
  .toList()
  ..sort((a, b) => b.compareTo(a)); // lambda: sort

// Each arrow function is a lambda!
print(topPassing.take(3).toList());
// [Score: 91, Score: 88, Score: 82]''',
    'dart_concept': 'Each (arg) => expr in a pipeline is an anonymous lambda.',
    'tags': ['Pipeline', 'Composition', 'Chaining'],
  },
];

class LambdaScreen extends StatefulWidget {
  const LambdaScreen({super.key});
  @override
  State<LambdaScreen> createState() => _LambdaScreenState();
}

class _LambdaScreenState extends State<LambdaScreen> {
  int _selectedIndex = 0;

  // Interactive closure counter demo
  late final Map<String, dynamic> _counter;
  int _counterValue = 0;
  int _adderX = 5;
  int _adderInput = 0;
  int _adderResult = 0;

  // Range checker
  double _rangeMin = 20, _rangeMax = 80, _rangeTest = 50;

  @override
  void initState() {
    super.initState();
    _counter = makeCounter(start: 0, step: 1);
    _counterValue = (_counter['value'] as Function)() as int;
  }

  void _counterAction(String action) {
    setState(() {
      _counterValue = (_counter[action] as Function)() as int;
    });
  }

  @override
  Widget build(BuildContext context) {
    final demo = lambdaDemos[_selectedIndex];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lambda Functions & Closures',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Row(
        children: [
          // Side navigation
          SizedBox(
            width: 170,
            child: Container(
              color: AppTheme.secondary,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: lambdaDemos.length,
                itemBuilder: (_, i) {
                  final sel = _selectedIndex == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIndex = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        color: sel ? AppTheme.gold.withOpacity(0.2) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: sel ? AppTheme.gold : Colors.transparent),
                      ),
                      child: Text(
                        lambdaDemos[i]['title'] as String,
                        style: TextStyle(
                          color: sel ? AppTheme.gold : AppTheme.textSecondary,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(demo['title'] as String,
                      style: const TextStyle(color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w900, fontSize: 24)),
                  const SizedBox(height: 6),
                  Text(demo['concept'] as String,
                      style: const TextStyle(color: AppTheme.textSecondary,
                          fontSize: 13, height: 1.6)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.gold.withOpacity(0.3)),
                    ),
                    child: Text('💡 ${demo['dart_concept']}',
                        style: const TextStyle(color: AppTheme.gold, fontSize: 12)),
                  ),
                  const SizedBox(height: 16),

                  // Code block
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1117),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.gold.withOpacity(0.3)),
                    ),
                    child: Text(demo['code'] as String,
                        style: const TextStyle(
                          color: Color(0xFFE6EDF3),
                          fontFamily: 'monospace',
                          fontSize: 12.5,
                          height: 1.7,
                        )),
                  ),
                  const SizedBox(height: 12),

                  // Tags
                  Wrap(
                    spacing: 6, runSpacing: 6,
                    children: (demo['tags'] as List<String>).map((t) => Chip(
                      label: Text(t, style: const TextStyle(fontSize: 11, color: AppTheme.gold)),
                      backgroundColor: AppTheme.gold.withOpacity(0.08),
                      side: BorderSide(color: AppTheme.gold.withOpacity(0.3)),
                    )).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Interactive playground
                  _buildInteractivePanel(_selectedIndex),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractivePanel(int index) {
    switch (index) {
      case 2: // Factory / currying
        return _curryingPlayground();
      case 5: // Counter closure
        return _counterPlayground();
      case 0: // Square demo
        return _squarePlayground();
      default:
        return _defaultPlayground(index);
    }
  }

  Widget _counterPlayground() => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('▶ Interactive: Closure Counter',
            style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text('Each button calls a function from the closure map.\n'
            'All share the same captured _count variable.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        const SizedBox(height: 16),
        Center(child: Text('$_counterValue',
            style: TextStyle(color: _counterValue >= 0 ? AppTheme.green : AppTheme.highlight,
                fontWeight: FontWeight.w900, fontSize: 56))),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _actionBtn('−', () => _counterAction('decrement'), AppTheme.highlight),
          const SizedBox(width: 12),
          _actionBtn('Reset', () => _counterAction('reset'), AppTheme.textSecondary),
          const SizedBox(width: 12),
          _actionBtn('+', () => _counterAction('increment'), AppTheme.green),
        ]),
        const SizedBox(height: 10),
        Center(child: Text('c[\'increment\']!()  →  $_counterValue',
            style: const TextStyle(color: AppTheme.green, fontFamily: 'monospace', fontSize: 12))),
      ]),
    ),
  );

  Widget _curryingPlayground() => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('▶ Interactive: makeAdder Playground',
            style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Row(children: [
          const Text('makeAdder(', style: TextStyle(color: AppTheme.textSecondary, fontFamily: 'monospace')),
          Expanded(child: Slider(
            value: _adderX.toDouble(), min: 1, max: 20, divisions: 19,
            activeColor: AppTheme.gold, label: '$_adderX',
            onChanged: (v) => setState(() {
              _adderX = v.toInt();
              _adderResult = makeAdder(_adderX)(_adderInput);
            }),
          )),
          Text('$_adderX)', style: const TextStyle(color: AppTheme.gold, fontFamily: 'monospace', fontWeight: FontWeight.w700)),
        ]),
        Row(children: [
          const Text('Input n: ', style: TextStyle(color: AppTheme.textSecondary, fontFamily: 'monospace')),
          Expanded(child: Slider(
            value: _adderInput.toDouble(), min: 0, max: 100, divisions: 100,
            activeColor: AppTheme.highlight, label: '$_adderInput',
            onChanged: (v) => setState(() {
              _adderInput = v.toInt();
              _adderResult = makeAdder(_adderX)(_adderInput);
            }),
          )),
          Text('$_adderInput', style: const TextStyle(color: AppTheme.highlight, fontFamily: 'monospace')),
        ]),
        const SizedBox(height: 8),
        Center(
          child: RichText(text: TextSpan(
            style: const TextStyle(fontFamily: 'monospace', fontSize: 16),
            children: [
              TextSpan(text: 'makeAdder($_adderX)', style: const TextStyle(color: AppTheme.gold)),
              const TextSpan(text: '($_adderInput)', style: TextStyle(color: AppTheme.highlight)),
              const TextSpan(text: ' = ', style: TextStyle(color: AppTheme.textSecondary)),
              TextSpan(text: '${makeAdder(_adderX)(_adderInput)}',
                  style: const TextStyle(color: AppTheme.green, fontWeight: FontWeight.w900, fontSize: 24)),
            ],
          )),
        ),
      ]),
    ),
  );

  Widget _squarePlayground() {
    int input = 7;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('▶ Arrow syntax demo',
              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          const Text(
            'var square = (int x) => x * x;\n'
            '// equivalent to:\n'
            'var square = (int x) { return x * x; };',
            style: TextStyle(color: AppTheme.green, fontFamily: 'monospace', fontSize: 12, height: 1.6),
          ),
          const SizedBox(height: 12),
          Center(child: Text('square(7) = ${7 * 7}',
              style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w900, fontSize: 28))),
        ]),
      ),
    );
  }

  Widget _defaultPlayground(int index) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('▶ Key Insight', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        _conceptHighlights(index),
      ]),
    ),
  );

  Widget _conceptHighlights(int index) {
    final highlights = {
      3: 'typedef Transformer<T> = T Function(T value);\n'
         '// Now T is reusable in many function signatures\n'
         '// just like a class name — but for functions.',
      4: '// IIFE: define and call in one expression\n'
         'var x = ((a, b) => a + b)(3, 4); // 7\n'
         '// Useful when you need a value but also\n'
         '// need multiple steps to compute it.',
      6: 'var cache = <int, int>{};\n'
         'return (n) => cache.putIfAbsent(n, () => fn(n));\n'
         '// putIfAbsent: compute fn(n) ONLY on miss.',
      7: 'scores\n'
         '  .where((s) => s >= 60)   // lambda 1: filter\n'
         '  .map((s) => "Score: \$s") // lambda 2: transform\n'
         '  ..sort((a, b) => b.compareTo(a)); // lambda 3: sort\n'
         '// Every (arg) => expr is a lambda!',
    };
    return Text(
      highlights[index] ?? '// See code example above',
      style: const TextStyle(color: AppTheme.green, fontFamily: 'monospace',
          fontSize: 12, height: 1.6),
    );
  }

  Widget _actionBtn(String label, VoidCallback onTap, Color color) =>
    ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.15),
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
}

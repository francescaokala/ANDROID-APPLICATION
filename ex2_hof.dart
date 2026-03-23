// ─────────────────────────────────────────────────────────────────────────────
// EXERCISE 2 — Higher-Order Functions (Chap 2)
// Concepts: map, filter/where, reduce, fold, every, any, sort, take/skip,
//           functions as first-class values, passing functions as arguments,
//           returning functions from functions (currying)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../theme.dart';

// ── Pure Dart HOF demonstrations ──────────────────────────────────────────────

/// Takes a function and applies it to a list — HOF in pure Dart
List<T> applyToAll<T>(List<T> list, T Function(T) transform) =>
    list.map(transform).toList();

/// Returns a filter function (currying / closure)
bool Function(int) greaterThan(int threshold) => (int x) => x > threshold;

/// HOF: apply a function n times (function composition)
T applyNTimes<T>(T initial, T Function(T) fn, int n) =>
    n <= 0 ? initial : applyNTimes(fn(initial), fn, n - 1);

/// HOF: zip two lists with a combiner function
List<R> zipWith<A, B, R>(List<A> a, List<B> b, R Function(A, B) fn) =>
    List.generate(a.length < b.length ? a.length : b.length, (i) => fn(a[i], b[i]));

/// Returns a memoizing HOF wrapper (advanced concept)
Map<K, V> Function(K) memoize<K, V>(V Function(K) fn) {
  final cache = <K, V>{};
  return (K key) {
    cache[key] ??= fn(key);
    return cache;
  };
}

// ── Screen ────────────────────────────────────────────────────────────────────
class HOFScreen extends StatefulWidget {
  const HOFScreen({super.key});
  @override
  State<HOFScreen> createState() => _HOFScreenState();
}

class _HOFScreenState extends State<HOFScreen> {
  // Dataset for interactive demos
  List<int> _numbers = [3, 7, 2, 15, 8, 42, 1, 19, 5, 11, 33, 6];
  final _inputCtrl = TextEditingController();
  int _filterThreshold = 5;
  int _mapMultiplier = 2;
  String _selectedDemo = 'map';

  // Results cache
  late Map<String, dynamic> _results;

  @override
  void initState() {
    super.initState();
    _compute();
  }

  void _compute() {
    final nums = _numbers;
    _results = {
      // ── map: transform every element ──────────────────────────────────────
      'map': {
        'code': 'nums.map((n) => n * $_mapMultiplier).toList()',
        'input': nums,
        'output': nums.map((n) => n * _mapMultiplier).toList(),
        'explanation':
            'map transforms EVERY element using a function. It returns a new list of the same length. The original list is unchanged.',
      },

      // ── filter/where ──────────────────────────────────────────────────────
      'filter': {
        'code': 'nums.where((n) => n > $_filterThreshold).toList()',
        'input': nums,
        'output': nums.where((n) => n > _filterThreshold).toList(),
        'explanation':
            'where (filter) keeps only elements that satisfy the predicate. Elements failing the test are discarded.',
      },

      // ── reduce ────────────────────────────────────────────────────────────
      'reduce': {
        'code': 'nums.reduce((acc, n) => acc + n)',
        'input': nums,
        'output': nums.isEmpty ? 0 : nums.reduce((a, b) => a + b),
        'explanation':
            'reduce collapses a list into a single value by applying a binary function from left to right. No initial value needed.',
      },

      // ── fold ──────────────────────────────────────────────────────────────
      'fold': {
        'code': 'nums.fold(0, (acc, n) => acc + n)',
        'input': nums,
        'output': nums.fold(0, (a, b) => a + b),
        'explanation':
            'fold is like reduce but accepts an initial seed value. This makes it safe on empty lists and enables non-numeric accumulation.',
      },

      // ── every & any ──────────────────────────────────────────────────────
      'every_any': {
        'code_every': 'nums.every((n) => n > 0)',
        'code_any': 'nums.any((n) => n > 40)',
        'every': nums.every((n) => n > 0),
        'any': nums.any((n) => n > 40),
        'output': '${nums.every((n) => n > 0)} / ${nums.any((n) => n > 40)}',
        'explanation':
            'every returns true only if ALL elements satisfy the predicate. any returns true if AT LEAST ONE element satisfies it.',
      },

      // ── sort ──────────────────────────────────────────────────────────────
      'sort': {
        'code': '[...nums]..sort((a, b) => a.compareTo(b))',
        'input': nums,
        'output': [...nums]..sort((a, b) => a.compareTo(b)),
        'explanation':
            'sort accepts a comparator function. Passing a lambda (a, b) => a.compareTo(b) sorts ascending. Swap a and b for descending.',
      },

      // ── HOF: passing functions as arguments ───────────────────────────────
      'first_class': {
        'code': 'applyToAll(nums, (n) => n * n)',
        'input': nums,
        'output': applyToAll(nums, (n) => n * n),
        'explanation':
            'In Dart, functions are first-class values. applyToAll takes a List and a Function — demonstrating higher-order functions.',
      },

      // ── Currying / closure ────────────────────────────────────────────────
      'currying': {
        'code': 'greaterThan(10) // returns a function\nnums.where(greaterThan(10)).toList()',
        'input': nums,
        'output': nums.where(greaterThan(10)).toList(),
        'explanation':
            'greaterThan(10) returns a new function. This is currying / partial application — a HOF returns a specialized function.',
      },

      // ── zipWith ───────────────────────────────────────────────────────────
      'zip': {
        'code': 'zipWith([1,2,3], [10,20,30], (a,b) => a + b)',
        'input': [1, 2, 3],
        'input2': [10, 20, 30],
        'output': zipWith([1, 2, 3], [10, 20, 30], (a, b) => a + b),
        'explanation':
            'zipWith pairs elements from two lists and applies a combining function. Returns a new list.',
      },

      // ── applyNTimes ──────────────────────────────────────────────────────
      'compose': {
        'code': 'applyNTimes(1, (n) => n * 2, 5)',
        'output': applyNTimes(1, (n) => n * 2, 5),
        'explanation':
            'applyNTimes applies a function n times recursively. Result: 1 → 2 → 4 → 8 → 16 → 32. Demonstrates function composition.',
      },
    };
  }

  final _demoOrder = [
    'map', 'filter', 'reduce', 'fold', 'every_any',
    'sort', 'first_class', 'currying', 'zip', 'compose'
  ];

  final _demoLabels = {
    'map': 'map', 'filter': 'filter / where', 'reduce': 'reduce',
    'fold': 'fold', 'every_any': 'every & any', 'sort': 'sort',
    'first_class': 'Functions as Values', 'currying': 'Currying',
    'zip': 'zipWith', 'compose': 'applyNTimes',
  };

  @override
  void dispose() { _inputCtrl.dispose(); super.dispose(); }

  void _addNumber() {
    final v = int.tryParse(_inputCtrl.text.trim());
    if (v == null) return;
    setState(() { _numbers.add(v); _inputCtrl.clear(); _compute(); });
  }

  void _resetNumbers() => setState(() {
    _numbers = [3, 7, 2, 15, 8, 42, 1, 19, 5, 11, 33, 6];
    _compute();
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Higher-Order Functions', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _resetNumbers, tooltip: 'Reset list'),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: demo list
          SizedBox(
            width: 180,
            child: Container(
              color: AppTheme.secondary,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _demoOrder.length,
                itemBuilder: (_, i) {
                  final key = _demoOrder[i];
                  final isSelected = _selectedDemo == key;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDemo = key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.highlight.withOpacity(0.2) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? AppTheme.highlight : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        _demoLabels[key]!,
                        style: TextStyle(
                          color: isSelected ? AppTheme.highlight : AppTheme.textSecondary,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Right: demo detail
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dataset controls
                  _datasetControls(),
                  const SizedBox(height: 20),
                  // Demo content
                  _buildDemoPanel(_selectedDemo),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _datasetControls() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Working Dataset', style: TextStyle(
              color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6, runSpacing: 4,
            children: _numbers.map((n) => Chip(
              label: Text('$n', style: const TextStyle(fontSize: 11)),
              deleteIcon: const Icon(Icons.close, size: 12),
              onDeleted: () => setState(() { _numbers.remove(n); _compute(); }),
            )).toList(),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _inputCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                decoration: const InputDecoration(
                  labelText: 'Add number', isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
                onSubmitted: (_) => _addNumber(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: _addNumber, child: const Text('Add')),
          ]),
          if (_selectedDemo == 'filter') ...[
            const SizedBox(height: 8),
            Row(children: [
              const Text('Filter threshold: ', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              Expanded(child: Slider(
                value: _filterThreshold.toDouble(), min: 0, max: 50, divisions: 50,
                activeColor: AppTheme.highlight, label: '$_filterThreshold',
                onChanged: (v) => setState(() { _filterThreshold = v.toInt(); _compute(); }),
              )),
              Text('> $_filterThreshold', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            ]),
          ],
          if (_selectedDemo == 'map') ...[
            const SizedBox(height: 8),
            Row(children: [
              const Text('Multiplier: ', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              Expanded(child: Slider(
                value: _mapMultiplier.toDouble(), min: 1, max: 10, divisions: 9,
                activeColor: AppTheme.highlight, label: '×$_mapMultiplier',
                onChanged: (v) => setState(() { _mapMultiplier = v.toInt(); _compute(); }),
              )),
              Text('×$_mapMultiplier', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            ]),
          ],
        ]),
      ),
    );
  }

  Widget _buildDemoPanel(String key) {
    final data = _results[key] as Map<String, dynamic>;
    final code = data['code'] as String? ?? '';
    final explanation = data['explanation'] as String;
    final output = data['output'];
    final input = data['input'] as List?;
    final input2 = data['input2'] as List?;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(_demoLabels[key]!, style: const TextStyle(
          color: AppTheme.textPrimary, fontWeight: FontWeight.w800, fontSize: 22)),
      const SizedBox(height: 4),
      Text(explanation, style: const TextStyle(
          color: AppTheme.textSecondary, fontSize: 13, height: 1.5)),
      const SizedBox(height: 16),

      // Code block
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1117),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.green.withOpacity(0.3)),
        ),
        child: Text(
          code,
          style: const TextStyle(
            color: AppTheme.green,
            fontFamily: 'monospace',
            fontSize: 13,
            height: 1.6,
          ),
        ),
      ),
      const SizedBox(height: 16),

      // Input / Output visualization
      if (key == 'every_any') ...[
        _ioRow('every(n > 0)', '${data['every']}', AppTheme.green),
        const SizedBox(height: 8),
        _ioRow('any(n > 40)', '${data['any']}', AppTheme.gold),
      ] else ...[
        if (input != null) _listDisplay('Input', input, AppTheme.textSecondary),
        if (input2 != null) ...[
          const SizedBox(height: 8),
          _listDisplay('Input 2', input2, AppTheme.textSecondary),
        ],
        const SizedBox(height: 8),
        _arrowDivider(),
        const SizedBox(height: 8),
        if (output is List)
          _listDisplay('Output', output, AppTheme.highlight)
        else
          _scalarDisplay('Result', '$output', AppTheme.gold),
      ],

      const SizedBox(height: 20),
      _conceptBadges(key),
    ]);
  }

  Widget _ioRow(String label, String value, Color color) => Row(children: [
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label, style: TextStyle(color: color, fontFamily: 'monospace', fontSize: 12)),
    ),
    const SizedBox(width: 12),
    const Icon(Icons.arrow_forward, color: AppTheme.textSecondary, size: 16),
    const SizedBox(width: 12),
    Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 18)),
  ]);

  Widget _listDisplay(String label, List items, Color color) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11,
          fontWeight: FontWeight.w700, letterSpacing: 1)),
      const SizedBox(height: 6),
      Wrap(
        spacing: 6, runSpacing: 6,
        children: items.map((item) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Text('$item', style: TextStyle(
              color: color, fontWeight: FontWeight.w700, fontSize: 13)),
        )).toList(),
      ),
    ],
  );

  Widget _scalarDisplay(String label, String value, Color color) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text('$label: ', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
      Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 32)),
    ],
  );

  Widget _arrowDivider() => Row(children: [
    const Expanded(child: Divider(color: AppTheme.border)),
    Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: AppTheme.highlight, shape: BoxShape.circle),
      child: const Icon(Icons.arrow_downward, color: Colors.white, size: 14),
    ),
    const Expanded(child: Divider(color: AppTheme.border)),
  ]);

  Widget _conceptBadges(String key) {
    final tags = {
      'map': ['Transformation', 'Same Length', 'New List', 'Pure Function'],
      'filter': ['Predicate', 'Subset', 'Immutable', 'Boolean Function'],
      'reduce': ['Aggregation', 'Binary Op', 'Single Value', 'Left Fold'],
      'fold': ['Seed Value', 'Safe on Empty', 'Flexible Accumulator'],
      'every_any': ['Short-circuit', 'Boolean Result', 'Predicate'],
      'sort': ['Comparator', 'Ordering', 'In-place Sort'],
      'first_class': ['Functions as Values', 'Generic', 'HOF Pattern'],
      'currying': ['Partial Application', 'Closure', 'Function Factory'],
      'zip': ['Parallel Lists', 'Combining', 'Pairwise'],
      'compose': ['Recursion', 'Iteration', 'Function Composition'],
    };
    return Wrap(
      spacing: 6, runSpacing: 6,
      children: (tags[key] ?? []).map((t) => Chip(
        label: Text(t, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        backgroundColor: AppTheme.surface,
        side: const BorderSide(color: AppTheme.border),
      )).toList(),
    );
  }
}

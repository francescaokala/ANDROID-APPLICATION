// ─────────────────────────────────────────────────────────────────────────────
// EXERCISE 4 — OOP Deep Dive (Chap 2)
// Concepts: abstract classes, inheritance, polymorphism, method overriding,
//           mixins, type checking (is/as), runtime dispatch,
//           encapsulation, factory constructors
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../models/university.dart';
import '../theme.dart';

class OOPScreen extends StatefulWidget {
  const OOPScreen({super.key});
  @override
  State<OOPScreen> createState() => _OOPScreenState();
}

class _OOPScreenState extends State<OOPScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  late UniversityRegistry _registry;
  String? _selectedMemberId;
  String _typeFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _registry = buildSampleRegistry();
    _selectedMemberId = _registry.all.first.id;
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  UniversityMember? get _selected =>
      _registry.all.where((m) => m.id == _selectedMemberId).firstOrNull;

  List<UniversityMember> get _filtered => switch (_typeFilter) {
        'professor' => _registry.getByType<Professor>(),
        'ta' => _registry.getByType<TeachingAssistant>(),
        'registrar' => _registry.getByType<Registrar>(),
        'it' => _registry.getByType<ITStaff>(),
        _ => _registry.all,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OOP: Inheritance & Polymorphism',
            style: TextStyle(fontWeight: FontWeight.w800)),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: const Color(0xFF9C6FDE),
          tabs: const [
            Tab(icon: Icon(Icons.account_tree), text: 'Hierarchy'),
            Tab(icon: Icon(Icons.people), text: 'Members'),
            Tab(icon: Icon(Icons.change_circle), text: 'Polymorphism'),
            Tab(icon: Icon(Icons.analytics), text: 'HOF + Types'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _buildHierarchyTab(),
          _buildMembersTab(),
          _buildPolymorphismTab(),
          _buildHOFTab(),
        ],
      ),
    );
  }

  // ── Tab 1: Class Hierarchy ─────────────────────────────────────────────────
  Widget _buildHierarchyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _conceptBanner(
            'Abstract Class & Inheritance',
            'UniversityMember is abstract — it defines a contract. Concrete subclasses (Professor, TA, Registrar, ITStaff) extend it and implement required methods.',
            const Color(0xFF9C6FDE),
          ),
          const SizedBox(height: 20),

          // UML-style hierarchy
          _hierarchyTree(),
          const SizedBox(height: 20),

          // Key concepts grid
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: _conceptCard('abstract class',
                'Cannot be instantiated.\nDefines the contract.\nContains abstract methods.',
                Icons.architecture, const Color(0xFF9C6FDE))),
            const SizedBox(width: 10),
            Expanded(child: _conceptCard('extends',
                'Inherits ALL non-private members.\nCan override methods.\nIS-A relationship.',
                Icons.arrow_upward, AppTheme.green)),
          ]),
          const SizedBox(height: 10),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: _conceptCard('mixin with',
                'Adds capabilities without inheritance.\nNo constructor.\nPrevents diamond problem.',
                Icons.extension, AppTheme.gold)),
            const SizedBox(width: 10),
            Expanded(child: _conceptCard('@override',
                'Replaces parent\'s implementation.\nMust match signature.\nEnables polymorphism.',
                Icons.swap_horiz, AppTheme.highlight)),
          ]),
          const SizedBox(height: 20),

          // Code snippet
          _codeBlock(
            'Abstract Class Definition',
            '''abstract class UniversityMember with Describable {
  final String id, name, email;
  final int yearJoined;

  // Abstract — subclasses MUST implement
  String get role;
  double get monthlyPay;
  String get department;

  // Concrete — inherited as-is
  int get yearsActive => DateTime.now().year - yearJoined;

  // Polymorphic — can be overridden
  String greet() => "Hello, I am \$name, a \$role.";
}

// ── Subclass ────────────────────────────────────────
class Professor extends AcademicMember {
  @override String get role => "\$rank Professor";
  @override double get monthlyPay => baseSalary / 12;

  @override // Polymorphic override
  String greet() => "Good day! I am Prof. \$name.";
}''',
            const Color(0xFF9C6FDE),
          ),
        ],
      ),
    );
  }

  Widget _hierarchyTree() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(children: [
        _treeNode('UniversityMember (abstract)', const Color(0xFF9C6FDE), true, 0),
        Row(children: [
          const SizedBox(width: 20),
          Expanded(child: Column(children: [
            _treeConnector(),
            _treeNode('AcademicMember (abstract)', const Color(0xFF4FC3F7), true, 1),
            Row(children: [
              const SizedBox(width: 20),
              Expanded(child: Column(children: [
                _treeConnector(),
                _treeNode('Professor', AppTheme.green, false, 2),
              ])),
              const SizedBox(width: 8),
              Expanded(child: Column(children: [
                _treeConnector(),
                _treeNode('TeachingAssistant', AppTheme.green, false, 2),
              ])),
            ]),
          ])),
          const SizedBox(width: 8),
          Expanded(child: Column(children: [
            _treeConnector(),
            _treeNode('AdministrativeStaff (abstract)', const Color(0xFFFFB74D), true, 1),
            Row(children: [
              const SizedBox(width: 20),
              Expanded(child: Column(children: [
                _treeConnector(),
                _treeNode('Registrar', AppTheme.gold, false, 2),
              ])),
              const SizedBox(width: 8),
              Expanded(child: Column(children: [
                _treeConnector(),
                _treeNode('ITStaff', AppTheme.gold, false, 2),
              ])),
            ]),
          ])),
        ]),
      ]),
    );
  }

  Widget _treeNode(String label, Color color, bool isAbstract, int depth) =>
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.5),
          style: isAbstract ? BorderStyle.solid : BorderStyle.solid,
          width: isAbstract ? 2 : 1,
        ),
      ),
      child: Row(children: [
        Icon(isAbstract ? Icons.architecture : Icons.class_, color: color, size: 14),
        const SizedBox(width: 6),
        Expanded(child: Text(label, style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.w600,
            fontStyle: isAbstract ? FontStyle.italic : FontStyle.normal))),
      ]),
    );

  Widget _treeConnector() => Container(
    margin: const EdgeInsets.only(left: 16, bottom: 4, top: 4),
    height: 12,
    width: 2,
    color: AppTheme.border,
  );

  // ── Tab 2: Members Browser ──────────────────────────────────────────────────
  Widget _buildMembersTab() {
    return Row(
      children: [
        // Sidebar: member list with type filter
        SizedBox(
          width: 200,
          child: Container(
            color: AppTheme.secondary,
            child: Column(children: [
              // Filter chips
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(children: [
                  const Text('Filter by type', style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4, runSpacing: 4,
                    children: [
                      _filterChip('all', 'All'),
                      _filterChip('professor', 'Prof'),
                      _filterChip('ta', 'TA'),
                      _filterChip('registrar', 'Reg'),
                      _filterChip('it', 'IT'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${_filtered.length} member(s)',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                ]),
              ),
              const Divider(color: AppTheme.border),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: _filtered.length,
                  itemBuilder: (_, i) {
                    final m = _filtered[i];
                    final sel = _selectedMemberId == m.id;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedMemberId = m.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: sel ? const Color(0xFF9C6FDE).withOpacity(0.2) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: sel ? const Color(0xFF9C6FDE) : Colors.transparent),
                        ),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(m.name, style: TextStyle(
                              color: sel ? const Color(0xFF9C6FDE) : AppTheme.textPrimary,
                              fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 12)),
                          Text(_typeLabel(m), style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 10)),
                        ]),
                      ),
                    );
                  },
                ),
              ),
            ]),
          ),
        ),

        // Detail panel
        Expanded(
          child: _selected == null
              ? const Center(child: Text('Select a member', style: TextStyle(color: AppTheme.textSecondary)))
              : _memberDetail(_selected!),
        ),
      ],
    );
  }

  Widget _memberDetail(UniversityMember m) {
    final color = _memberColor(m);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.2),
              child: Text(_initials(m.name), style: TextStyle(
                  color: color, fontWeight: FontWeight.w800, fontSize: 18)),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.name, style: const TextStyle(
                    color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 20)),
                Text(m.role, style: TextStyle(color: color, fontSize: 13)),
                Text(m.id, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
              ],
            )),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              _typeBadge(m),
              const SizedBox(height: 4),
              Text('\$${m.monthlyPay.toStringAsFixed(0)}/mo',
                  style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w700)),
            ]),
          ]),
          const SizedBox(height: 16),

          // Key attributes
          Card(child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _infoRow('Department', m.department),
              _infoRow('Years Active', '${m.yearsActive} years (joined ${m.yearJoined})'),
              _infoRow('Email', m.email),
              _infoRow('Monthly Pay', '\$${m.monthlyPay.toStringAsFixed(2)}'),
              if (m is AcademicMember) ...[
                _infoRow('Courses', m.courses.join(', ')),
                _infoRow('Overloaded?', m.isOverloaded ? '⚠ Yes' : '✓ No'),
                _infoRow('Max Courses', '${m.maxCoursesPerSemester}'),
              ],
              if (m is Professor) ...[
                _infoRow('Rank', m.rank),
                _infoRow('Research', m.researchTopics.join(', ')),
              ],
              if (m is TeachingAssistant)
                _infoRow('Hours/week', '${m.hoursPerWeek} @ \$${m.hourlyRate}/hr'),
              if (m is AdministrativeStaff) ...[
                _infoRow('Office', m.office),
                _infoRow('Responsibilities', (m.responsibilities).join(', ')),
              ],
            ]),
          )),
          const SizedBox(height: 12),

          // Polymorphic greet()
          Card(child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.record_voice_over, color: Color(0xFF9C6FDE), size: 14),
                const SizedBox(width: 6),
                const Text('Polymorphic greet()', style: TextStyle(
                    color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
                const Spacer(),
                _codeTag('@override'),
              ]),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF9C6FDE).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF9C6FDE).withOpacity(0.3)),
                ),
                child: Text('"${m.greet()}"',
                    style: const TextStyle(
                        color: AppTheme.textPrimary, fontSize: 13,
                        fontStyle: FontStyle.italic)),
              ),
            ]),
          )),
          const SizedBox(height: 12),

          // describe() from Describable mixin
          Card(child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.description, color: AppTheme.gold, size: 14),
                const SizedBox(width: 6),
                const Text('describe() — from Describable mixin',
                    style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
                const Spacer(),
                _codeTag('mixin'),
              ]),
              const SizedBox(height: 8),
              Text(m.describe(), style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 12, height: 1.6, fontFamily: 'monospace')),
            ]),
          )),
        ],
      ),
    );
  }

  // ── Tab 3: Polymorphism Demo ─────────────────────────────────────────────────
  Widget _buildPolymorphismTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _conceptBanner(
          'Polymorphism in Action',
          'The same method call (greet(), monthlyPay, role) produces different output depending on the runtime type. The variable type is UniversityMember — the behavior is determined by the concrete class.',
          const Color(0xFF9C6FDE),
        ),
        const SizedBox(height: 16),

        // Polymorphic dispatch table
        Card(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.table_chart, color: AppTheme.highlight, size: 14),
              const SizedBox(width: 6),
              const Text('greetAll() — runtime dispatch', style: TextStyle(
                  color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
              const Spacer(),
              _codeTag('map + greet()'),
            ]),
            const SizedBox(height: 8),
            _codeBlock('', 'List<String> greetAll() =>\n    _members.map((m) => m.greet()).toList();\n// m.greet() is resolved at RUNTIME', AppTheme.highlight),
            const SizedBox(height: 12),
            ..._registry.greetAll().asMap().entries.map((e) {
              final m = _registry.all[e.key];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _memberColor(m).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _memberColor(m).withOpacity(0.3)),
                ),
                child: Row(children: [
                  _typeBadge(m),
                  const SizedBox(width: 10),
                  Expanded(child: Text(e.value,
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12))),
                ]),
              );
            }),
          ]),
        )),
        const SizedBox(height: 16),

        // Type checking (is / as)
        Card(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.search, color: AppTheme.gold, size: 14),
              const SizedBox(width: 6),
              const Text('Type Checking: is / as / whereType', style: TextStyle(
                  color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
              const Spacer(),
              _codeTag('runtime type'),
            ]),
            const SizedBox(height: 8),
            _codeBlock('', '// is — type check\nif (m is Professor) { ... }\n\n// as — type cast (throws if wrong type)\nvar prof = m as Professor;\n\n// whereType<T> — filter by type (HOF)\nregistry.getByType<Professor>()\n  // same as: members.whereType<Professor>().toList()', AppTheme.gold),
            const SizedBox(height: 12),
            ..._registry.all.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                SizedBox(width: 130, child: Text(m.name,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12))),
                const SizedBox(width: 8),
                _isBadge('Professor', m is Professor),
                const SizedBox(width: 4),
                _isBadge('Academic', m is AcademicMember),
                const SizedBox(width: 4),
                _isBadge('Admin', m is AdministrativeStaff),
              ]),
            )),
          ]),
        )),
        const SizedBox(height: 16),

        // Method overriding
        _codeBlock('Method Overriding: monthlyPay',
          '// Each class overrides the abstract getter\n'
          '// The variable type is UniversityMember:\n\n'
          'Professor  → baseSalary / 12\n'
          'TA         → hourlyRate * hoursPerWeek * 4.33\n'
          'Registrar  → annualSalary / 12\n'
          'ITStaff    → hourlyRate * hoursPerWeek * 4.33',
          AppTheme.green,
        ),
      ]),
    );
  }

  // ── Tab 4: HOF + Type System ──────────────────────────────────────────────
  Widget _buildHOFTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _conceptBanner(
          'OOP + Higher-Order Functions',
          'OOP and HOF are complementary. Using map, filter, reduce and whereType<T> on object collections produces powerful, readable code.',
          AppTheme.green,
        ),
        const SizedBox(height: 16),

        // Total payroll
        Card(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('Total Monthly Payroll', style: TextStyle(
                  color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
              const Spacer(),
              _codeTag('HOF: fold'),
            ]),
            const SizedBox(height: 4),
            const Text(
              'members.fold(0, (sum, m) => sum + m.monthlyPay)',
              style: TextStyle(color: AppTheme.green, fontFamily: 'monospace', fontSize: 11),
            ),
            const SizedBox(height: 12),
            Center(child: Text(
              '\$${_registry.totalMonthlyPayroll.toStringAsFixed(2)}',
              style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w900, fontSize: 36),
            )),
          ]),
        )),
        const SizedBox(height: 12),

        // Sorted by pay
        Card(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('Sorted by Pay (desc)', style: TextStyle(
                  color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
              const Spacer(),
              _codeTag('HOF: sort'),
            ]),
            const SizedBox(height: 4),
            const Text(
              '[...members]..sort((a,b) => b.monthlyPay.compareTo(a.monthlyPay))',
              style: TextStyle(color: AppTheme.green, fontFamily: 'monospace', fontSize: 11),
            ),
            const SizedBox(height: 10),
            ..._registry.sortedByPay.asMap().entries.map((e) => ListTile(
              dense: true, contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(radius: 12, backgroundColor: AppTheme.gold.withOpacity(0.2),
                child: Text('#${e.key + 1}', style: const TextStyle(
                    color: AppTheme.gold, fontSize: 10, fontWeight: FontWeight.w800))),
              title: Text(e.value.name, style: const TextStyle(
                  color: AppTheme.textPrimary, fontSize: 12)),
              subtitle: Text(e.value.role, style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 10)),
              trailing: Text('\$${e.value.monthlyPay.toStringAsFixed(0)}/mo',
                  style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w700)),
            )),
          ]),
        )),
        const SizedBox(height: 12),

        // whereType
        Card(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('getByType<T>() — whereType HOF', style: TextStyle(
                  color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
              const Spacer(),
              _codeTag('whereType<T>'),
            ]),
            const SizedBox(height: 4),
            const Text(
              'members.whereType<Professor>().toList()',
              style: TextStyle(color: AppTheme.green, fontFamily: 'monospace', fontSize: 11),
            ),
            const SizedBox(height: 10),
            Row(children: [
              _countBox('Professors', _registry.getByType<Professor>().length, const Color(0xFF9C6FDE)),
              const SizedBox(width: 8),
              _countBox('TAs', _registry.getByType<TeachingAssistant>().length, AppTheme.green),
              const SizedBox(width: 8),
              _countBox('Admin', _registry.getByType<AdministrativeStaff>().length, AppTheme.gold),
            ]),
          ]),
        )),
      ]),
    );
  }

  // ── Helper widgets ─────────────────────────────────────────────────────────
  Widget _conceptBanner(String title, String body, Color color) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.4)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.lightbulb, color: color, size: 16),
        const SizedBox(width: 6),
        Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14)),
      ]),
      const SizedBox(height: 6),
      Text(body, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.5)),
    ]),
  );

  Widget _conceptCard(String title, String body, IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.4)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 6),
        Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12,
            fontFamily: 'monospace')),
      ]),
      const SizedBox(height: 6),
      Text(body, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, height: 1.5)),
    ]),
  );

  Widget _codeBlock(String label, String code, Color color) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (label.isNotEmpty) ...[
        Text(label, style: const TextStyle(color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700, fontSize: 13)),
        const SizedBox(height: 6),
      ],
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1117),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(code, style: TextStyle(
            color: color, fontFamily: 'monospace', fontSize: 11.5, height: 1.6)),
      ),
    ],
  );

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 110, child: Text(label, style: const TextStyle(
          color: AppTheme.textSecondary, fontSize: 12))),
      Expanded(child: Text(value, style: const TextStyle(
          color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w500))),
    ]),
  );

  Widget _typeBadge(UniversityMember m) {
    final label = _typeLabel(m);
    final color = _memberColor(m);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(label, style: TextStyle(
          color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }

  Widget _isBadge(String type, bool isType) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: isType ? AppTheme.green.withOpacity(0.15) : AppTheme.surface,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: isType ? AppTheme.green.withOpacity(0.4) : AppTheme.border),
    ),
    child: Text(type, style: TextStyle(
        color: isType ? AppTheme.green : AppTheme.textSecondary, fontSize: 9)),
  );

  Widget _filterChip(String value, String label) {
    final sel = _typeFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _typeFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: sel ? const Color(0xFF9C6FDE).withOpacity(0.2) : AppTheme.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: sel ? const Color(0xFF9C6FDE) : AppTheme.border),
        ),
        child: Text(label, style: TextStyle(
            color: sel ? const Color(0xFF9C6FDE) : AppTheme.textSecondary,
            fontSize: 11, fontWeight: sel ? FontWeight.w700 : FontWeight.w400)),
      ),
    );
  }

  Widget _countBox(String label, int count, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(children: [
        Text('$count', style: TextStyle(
            color: color, fontWeight: FontWeight.w900, fontSize: 22)),
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
      ]),
    ),
  );

  Widget _codeTag(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: AppTheme.green.withOpacity(0.1),
      borderRadius: BorderRadius.circular(5),
      border: Border.all(color: AppTheme.green.withOpacity(0.3)),
    ),
    child: Text(text, style: const TextStyle(
        color: AppTheme.green, fontSize: 9, fontFamily: 'monospace')),
  );

  Color _memberColor(UniversityMember m) => switch (m) {
    Professor _ => const Color(0xFF9C6FDE),
    TeachingAssistant _ => AppTheme.green,
    Registrar _ => AppTheme.gold,
    ITStaff _ => const Color(0xFF4FC3F7),
    _ => AppTheme.textSecondary,
  };

  String _typeLabel(UniversityMember m) => switch (m) {
    Professor _ => 'Professor',
    TeachingAssistant _ => 'TA',
    Registrar _ => 'Registrar',
    ITStaff _ => 'IT Staff',
    _ => 'Member',
  };

  String _initials(String name) => name.split(' ')
      .where((p) => p.isNotEmpty).take(2).map((p) => p[0]).join();
}

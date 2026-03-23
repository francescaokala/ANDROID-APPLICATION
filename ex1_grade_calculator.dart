// ─────────────────────────────────────────────────────────────────────────────
// EXERCISE 1 — Student Grade Calculator (Chap 1 + Chap 2 merged)
// Concepts: OOP (Student, Grade, GradeBook), Lambda Functions,
//           Higher-Order Functions (map, filter, reduce, fold),
//           Encapsulation, Getters, Pattern Matching, GUI
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/student.dart';
import '../theme.dart';
import '../widgets/info_card.dart';

class GradeCalculatorScreen extends StatefulWidget {
  const GradeCalculatorScreen({super.key});
  @override
  State<GradeCalculatorScreen> createState() => _GradeCalculatorScreenState();
}

class _GradeCalculatorScreenState extends State<GradeCalculatorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // GradeBook (OOP) managing all students
  final GradeBook _gradeBook = GradeBook(courseName: 'Introduction to Computer Science');
  Student? _selectedStudent;

  // Form controllers
  final _nameCtrl = TextEditingController();
  final _idCtrl = TextEditingController();
  final _majorCtrl = TextEditingController();
  final _gradeTitleCtrl = TextEditingController();
  final _scoreCtrl = TextEditingController();
  final _maxScoreCtrl = TextEditingController(text: '100');
  GradeCategory _selectedCategory = GradeCategory.assignment;

  // Sorting and filtering state
  String _sortMode = 'name'; // 'name' | 'grade'
  double _filterThreshold = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _seedSampleData();
  }

  void _seedSampleData() {
    // Pre-populate with sample students so the app is immediately useful
    final s1 = Student(id: 'S001', name: 'Amara Nkosi', major: 'CS');
    s1.addGrade(Grade(title: 'Quiz 1', score: 85, maxScore: 100, category: GradeCategory.quiz));
    s1.addGrade(Grade(title: 'Midterm', score: 78, maxScore: 100, category: GradeCategory.midterm));
    s1.addGrade(Grade(title: 'Final Exam', score: 88, maxScore: 100, category: GradeCategory.final_));
    s1.addGrade(Grade(title: 'Lab 1', score: 95, maxScore: 100, category: GradeCategory.lab));
    s1.addGrade(Grade(title: 'HW Set 1', score: 90, maxScore: 100, category: GradeCategory.assignment));

    final s2 = Student(id: 'S002', name: 'Bashir Okonkwo', major: 'Math');
    s2.addGrade(Grade(title: 'Quiz 1', score: 72, maxScore: 100, category: GradeCategory.quiz));
    s2.addGrade(Grade(title: 'Midterm', score: 65, maxScore: 100, category: GradeCategory.midterm));
    s2.addGrade(Grade(title: 'Final Exam', score: 70, maxScore: 100, category: GradeCategory.final_));
    s2.addGrade(Grade(title: 'Assignment 1', score: 80, maxScore: 100, category: GradeCategory.assignment));

    final s3 = Student(id: 'S003', name: 'Céline Dubois', major: 'Physics');
    s3.addGrade(Grade(title: 'Quiz 1', score: 95, maxScore: 100, category: GradeCategory.quiz));
    s3.addGrade(Grade(title: 'Midterm', score: 91, maxScore: 100, category: GradeCategory.midterm));
    s3.addGrade(Grade(title: 'Final Exam', score: 94, maxScore: 100, category: GradeCategory.final_));
    s3.addGrade(Grade(title: 'Lab 1', score: 98, maxScore: 100, category: GradeCategory.lab));

    _gradeBook.addStudent(s1);
    _gradeBook.addStudent(s2);
    _gradeBook.addStudent(s3);
    _selectedStudent = s1;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameCtrl.dispose(); _idCtrl.dispose(); _majorCtrl.dispose();
    _gradeTitleCtrl.dispose(); _scoreCtrl.dispose(); _maxScoreCtrl.dispose();
    super.dispose();
  }

  void _addStudent() {
    if (_nameCtrl.text.isEmpty || _idCtrl.text.isEmpty) return;
    setState(() {
      final student = Student(
        id: _idCtrl.text.trim(),
        name: _nameCtrl.text.trim(),
        major: _majorCtrl.text.trim().isEmpty ? 'Undeclared' : _majorCtrl.text.trim(),
      );
      _gradeBook.addStudent(student);
      _selectedStudent ??= student;
      _nameCtrl.clear(); _idCtrl.clear(); _majorCtrl.clear();
    });
  }

  void _addGrade() {
    if (_gradeTitleCtrl.text.isEmpty || _scoreCtrl.text.isEmpty || _selectedStudent == null) return;
    final score = double.tryParse(_scoreCtrl.text);
    final max = double.tryParse(_maxScoreCtrl.text);
    if (score == null || max == null || score > max) return;
    setState(() {
      _selectedStudent!.addGrade(Grade(
        title: _gradeTitleCtrl.text.trim(),
        score: score,
        maxScore: max,
        category: _selectedCategory,
      ));
      _gradeTitleCtrl.clear(); _scoreCtrl.clear();
    });
  }

  // ── HOF demo: get sorted students using lambda comparators ─────────────────
  List<Student> get _displayedStudents => _sortMode == 'grade'
      ? _gradeBook.sortedByGrade
      : _gradeBook.sortedByName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grade Calculator', style: TextStyle(fontWeight: FontWeight.w800)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.highlight,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Students'),
            Tab(icon: Icon(Icons.grade), text: 'Grades'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStudentsTab(),
          _buildGradesTab(),
          _buildAnalyticsTab(),
        ],
      ),
    );
  }

  // ── Tab 1: Student Management ──────────────────────────────────────────────
  Widget _buildStudentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add student form
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Add New Student', Icons.person_add),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _field(_idCtrl, 'Student ID', hint: 'S004')),
                    const SizedBox(width: 10),
                    Expanded(child: _field(_nameCtrl, 'Full Name', hint: 'Jane Doe')),
                  ]),
                  const SizedBox(height: 10),
                  _field(_majorCtrl, 'Major', hint: 'Computer Science'),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addStudent,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Student'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Sort controls (HOF demonstration)
          Row(
            children: [
              _sectionTitle('Class Roster', Icons.list),
              const Spacer(),
              _codeTag('HOF: sortedBy'),
              const SizedBox(width: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'name', label: Text('Name'), icon: Icon(Icons.sort_by_alpha, size: 14)),
                  ButtonSegment(value: 'grade', label: Text('Grade'), icon: Icon(Icons.score, size: 14)),
                ],
                selected: {_sortMode},
                onSelectionChanged: (v) => setState(() => _sortMode = v.first),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((s) =>
                      s.contains(WidgetState.selected)
                          ? AppTheme.highlight.withOpacity(0.3)
                          : AppTheme.surface),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Student list
          ..._displayedStudents.map((s) => _studentCard(s)),

          const SizedBox(height: 16),
          // Class summary
          _classStats(),
        ],
      ),
    );
  }

  Widget _studentCard(Student s) {
    final isSelected = _selectedStudent?.id == s.id;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedStudent = s;
        _tabController.animateTo(1);
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.highlight.withOpacity(0.15) : AppTheme.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.highlight : AppTheme.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: _gradeColor(s.weightedAverage).withOpacity(0.2),
            child: Text(
              s.letterGrade,
              style: TextStyle(
                color: _gradeColor(s.weightedAverage),
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
          title: Text(s.name, style: const TextStyle(
            color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
          subtitle: Text('${s.id} · ${s.major} · ${s.grades.length} grades',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${s.weightedAverage.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: _gradeColor(s.weightedAverage),
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: s.isPassing ? AppTheme.green.withOpacity(0.15) : AppTheme.highlight.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  s.isPassing ? 'PASS' : 'FAIL',
                  style: TextStyle(
                    color: s.isPassing ? AppTheme.green : AppTheme.highlight,
                    fontSize: 10, fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          onLongPress: () => _confirmDelete(s),
        ),
      ),
    );
  }

  Widget _classStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              _sectionTitle('Class Statistics', Icons.bar_chart),
              const Spacer(),
              _codeTag('HOF: fold, filter, map'),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              _statBox('Class Avg', '${_gradeBook.classAverage.toStringAsFixed(1)}%', AppTheme.gold),
              const SizedBox(width: 8),
              _statBox('Passing', '${_gradeBook.passingStudents.length}', AppTheme.green),
              const SizedBox(width: 8),
              _statBox('Failing', '${_gradeBook.failingStudents.length}', AppTheme.highlight),
              const SizedBox(width: 8),
              _statBox('Total', '${_gradeBook.students.length}', AppTheme.textSecondary),
            ]),
            const SizedBox(height: 12),
            const Text('Grade Distribution', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6, runSpacing: 6,
              children: _gradeBook.gradeDistribution.entries.map((e) =>
                Chip(
                  label: Text('${e.key}: ${e.value}',
                    style: TextStyle(color: _gradeColor(_letterToNum(e.key)), fontWeight: FontWeight.w700)),
                  backgroundColor: _gradeColor(_letterToNum(e.key)).withOpacity(0.15),
                  side: BorderSide(color: _gradeColor(_letterToNum(e.key)).withOpacity(0.5)),
                ),
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab 2: Grade Entry ─────────────────────────────────────────────────────
  Widget _buildGradesTab() {
    if (_selectedStudent == null) {
      return const Center(child: Text('Select a student from the Students tab',
          style: TextStyle(color: AppTheme.textSecondary)));
    }
    final s = _selectedStudent!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: _gradeColor(s.weightedAverage).withOpacity(0.2),
                  child: Text(s.letterGrade,
                    style: TextStyle(color: _gradeColor(s.weightedAverage),
                        fontWeight: FontWeight.w800, fontSize: 22)),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name, style: const TextStyle(
                        color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 18)),
                    Text('${s.id} · ${s.major}',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    const SizedBox(height: 4),
                    Row(children: [
                      _badge('Weighted: ${s.weightedAverage.toStringAsFixed(1)}%', AppTheme.gold),
                      const SizedBox(width: 6),
                      _badge('Simple: ${s.simpleAverage.toStringAsFixed(1)}%', AppTheme.textSecondary),
                    ]),
                  ],
                )),
              ]),
            ),
          ),
          const SizedBox(height: 16),

          // Add grade form
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Add Grade', Icons.add_chart),
                  const SizedBox(height: 12),
                  _field(_gradeTitleCtrl, 'Grade Title', hint: 'Midterm Exam'),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: _field(_scoreCtrl, 'Score', hint: '85',
                        keyboardType: TextInputType.number)),
                    const SizedBox(width: 10),
                    Expanded(child: _field(_maxScoreCtrl, 'Max Score', hint: '100',
                        keyboardType: TextInputType.number)),
                  ]),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<GradeCategory>(
                    value: _selectedCategory,
                    dropdownColor: AppTheme.cardBg,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.border)),
                    ),
                    items: GradeCategory.values.map((c) => DropdownMenuItem(
                      value: c,
                      child: Row(children: [
                        Text(c.label, style: const TextStyle(color: AppTheme.textPrimary)),
                        const Spacer(),
                        Text('×${c.weight}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                      ]),
                    )).toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v!),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addGrade,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Grade'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Filter controls (HOF: filter demo)
          Row(children: [
            _sectionTitle('Grade List', Icons.list_alt),
            const Spacer(),
            _codeTag('HOF: where/filter'),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            const Text('Show ≥ ', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            Expanded(
              child: Slider(
                value: _filterThreshold,
                min: 0, max: 100, divisions: 20,
                activeColor: AppTheme.highlight,
                label: '${_filterThreshold.toInt()}%',
                onChanged: (v) => setState(() => _filterThreshold = v),
              ),
            ),
            Text('${_filterThreshold.toInt()}%',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ]),

          // Grade list — HOF: where (filter) applied here
          ...s.filterGrades((g) => g.percentage >= _filterThreshold)
              .asMap().entries.map((e) => _gradeItem(s, e.value, e.key)),

          if (s.grades.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('No grades yet. Add one above.',
                  style: TextStyle(color: AppTheme.textSecondary))),
            ),

          // Best / Worst (HOF: reduce)
          if (s.grades.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(children: [
              _sectionTitle('Extremes', Icons.compare_arrows),
              const Spacer(),
              _codeTag('HOF: reduce'),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _extremeCard('Best', s.highestGrade, AppTheme.green)),
              const SizedBox(width: 8),
              Expanded(child: _extremeCard('Worst', s.lowestGrade, AppTheme.highlight)),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _gradeItem(Student s, Grade g, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: ListTile(
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: _gradeColor(g.percentage).withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: Text(g.letterGrade,
            style: TextStyle(color: _gradeColor(g.percentage),
                fontWeight: FontWeight.w800))),
        ),
        title: Text(g.title, style: const TextStyle(
            color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Row(children: [
          _badge(g.category.label, AppTheme.accent),
          const SizedBox(width: 4),
          Text('×${g.category.weight}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
        ]),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${g.score.toInt()}/${g.maxScore.toInt()}',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
            Text('${g.percentage.toStringAsFixed(1)}%',
                style: TextStyle(color: _gradeColor(g.percentage),
                    fontWeight: FontWeight.w800, fontSize: 15)),
          ],
        ),
        onLongPress: () {
          setState(() => s.removeGradeAt(s.grades.indexOf(g)));
        },
      ),
    );
  }

  Widget _extremeCard(String label, Grade? g, Color color) {
    if (g == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
        const SizedBox(height: 4),
        Text(g.title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13)),
        Text('${g.percentage.toStringAsFixed(1)}%',
            style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 18)),
      ]),
    );
  }

  // ── Tab 3: Analytics ───────────────────────────────────────────────────────
  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('HOF Pipeline Demo', Icons.code),
          const SizedBox(height: 4),
          const Text(
            'All operations below use pure higher-order functions: map, filter, reduce, fold, where, sort.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 16),

          // Lambda demo: gradesAbove threshold
          if (_selectedStudent != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    _sectionTitle('Grades Above 80%', Icons.filter_alt),
                    const Spacer(),
                    _codeTag('where + map'),
                  ]),
                  const SizedBox(height: 8),
                  const Text(
                    'students.where((g) => g.percentage >= 80)\n        .map((g) => g.title + ...)',
                    style: TextStyle(
                      color: AppTheme.green,
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ..._selectedStudent!.gradesAbove(80).map((g) =>
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(children: [
                        const Icon(Icons.check_circle, color: AppTheme.green, size: 14),
                        const SizedBox(width: 6),
                        Text(g, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13)),
                      ]),
                    ),
                  ),
                  if (_selectedStudent!.gradesAbove(80).isEmpty)
                    const Text('No grades above 80%', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                ]),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // HOF: top students
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  _sectionTitle('Top 2 Students', Icons.emoji_events),
                  const Spacer(),
                  _codeTag('sort + take'),
                ]),
                const SizedBox(height: 8),
                const Text(
                  '[...students]\n  ..sort((a,b) => b.avg.compareTo(a.avg))\n  .take(2).toList()',
                  style: TextStyle(color: AppTheme.green, fontFamily: 'monospace', fontSize: 11),
                ),
                const SizedBox(height: 10),
                ..._gradeBook.topN(2).asMap().entries.map((e) => ListTile(
                  dense: true, contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor: e.key == 0 ? AppTheme.gold.withOpacity(0.2) : AppTheme.textSecondary.withOpacity(0.2),
                    child: Text('#${e.key + 1}',
                      style: TextStyle(color: e.key == 0 ? AppTheme.gold : AppTheme.textSecondary,
                          fontWeight: FontWeight.w800, fontSize: 11)),
                  ),
                  title: Text(e.value.name, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13)),
                  trailing: Text('${e.value.weightedAverage.toStringAsFixed(1)}%',
                    style: TextStyle(color: _gradeColor(e.value.weightedAverage),
                        fontWeight: FontWeight.w700)),
                )),
              ]),
            ),
          ),
          const SizedBox(height: 12),

          // HOF: fold for payroll-style total
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  _sectionTitle('Class Average via fold', Icons.functions),
                  const Spacer(),
                  _codeTag('fold / reduce'),
                ]),
                const SizedBox(height: 8),
                const Text(
                  'students.map((s) => s.avg)\n        .fold(0.0, (a, b) => a + b) / n',
                  style: TextStyle(color: AppTheme.green, fontFamily: 'monospace', fontSize: 11),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    '${_gradeBook.classAverage.toStringAsFixed(2)}%',
                    style: const TextStyle(
                      color: AppTheme.gold,
                      fontWeight: FontWeight.w900,
                      fontSize: 40,
                    ),
                  ),
                ),
                Center(child: Text('Class Average — ${_gradeBook.students.length} students',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12))),
              ]),
            ),
          ),
          const SizedBox(height: 12),

          // Grade distribution (HOF: fold into Map)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  _sectionTitle('Grade Distribution', Icons.donut_large),
                  const Spacer(),
                  _codeTag('fold into Map'),
                ]),
                const SizedBox(height: 8),
                const Text(
                  'students.fold({}, (map, s) {\n  map[s.letterGrade] = (map[...] ?? 0) + 1;\n  return map; })',
                  style: TextStyle(color: AppTheme.green, fontFamily: 'monospace', fontSize: 11),
                ),
                const SizedBox(height: 12),
                ..._gradeBook.gradeDistribution.entries.map((e) {
                  final pct = _gradeBook.students.isEmpty ? 0.0
                      : e.value / _gradeBook.students.length;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(children: [
                      SizedBox(width: 20, child: Text(e.key,
                          style: TextStyle(color: _gradeColor(_letterToNum(e.key)),
                              fontWeight: FontWeight.w800))),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct,
                            backgroundColor: AppTheme.surface,
                            valueColor: AlwaysStoppedAnimation(
                                _gradeColor(_letterToNum(e.key))),
                            minHeight: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${e.value}', style: const TextStyle(color: AppTheme.textSecondary)),
                    ]),
                  );
                }),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Student s) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text('Delete Student', style: TextStyle(color: AppTheme.textPrimary)),
        content: Text('Remove ${s.name} and all their grades?',
            style: const TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _gradeBook.removeStudent(s.id);
                if (_selectedStudent?.id == s.id) {
                  _selectedStudent = _gradeBook.students.firstOrNull;
                }
              });
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Color _gradeColor(double pct) => pct >= 90
      ? AppTheme.green
      : pct >= 80
          ? const Color(0xFF4FC3F7)
          : pct >= 70
              ? AppTheme.gold
              : pct >= 60
                  ? const Color(0xFFFFB74D)
                  : AppTheme.highlight;

  double _letterToNum(String l) => switch (l) {
        'A' => 95, 'B' => 85, 'C' => 75, 'D' => 65, _ => 50
      };

  Widget _field(TextEditingController ctrl, String label,
      {String? hint, TextInputType? keyboardType}) =>
    TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(labelText: label, hintText: hint),
    );

  Widget _sectionTitle(String text, IconData icon) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: AppTheme.highlight, size: 16),
      const SizedBox(width: 6),
      Text(text, style: const TextStyle(
          color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 14)),
    ],
  );

  Widget _codeTag(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: AppTheme.green.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: AppTheme.green.withOpacity(0.3)),
    ),
    child: Text(text, style: const TextStyle(
        color: AppTheme.green, fontSize: 10, fontFamily: 'monospace')),
  );

  Widget _badge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
  );

  Widget _statBox(String label, String value, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(children: [
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 20)),
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
      ]),
    ),
  );
}

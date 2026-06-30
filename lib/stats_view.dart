import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_footer.dart';
import 'app_header.dart';
import 'domain/lift_stats.dart';
import 'services/app_services.dart';
import 'theme.dart';

class StatsView extends StatefulWidget {
  const StatsView({
    super.key,
    required this.statsStore,
    required this.onLogTap,
    required this.onTimerTap,
  });

  final LiftStatsStore statsStore;
  final VoidCallback onLogTap;
  final VoidCallback onTimerTap;

  @override
  State<StatsView> createState() => _StatsViewState();
}

class _StatsViewState extends State<StatsView> {
  LiftStats _stats = const LiftStats(entries: []);
  String? _selectedLift;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    final stats = widget.statsStore.load();
    setState(() {
      _stats = stats;
      _selectedLift = stats.liftNames.contains(_selectedLift)
          ? _selectedLift
          : stats.liftNames.firstOrNull;
    });
  }

  Future<void> _addEntry(LiftEntry entry) async {
    final entries = [..._stats.entries, entry]
      ..sort((a, b) => a.performedAt.compareTo(b.performedAt));
    await widget.statsStore.save(entries);
    if (!mounted) return;
    setState(() {
      _stats = LiftStats(entries: entries);
      _selectedLift = entry.liftName;
    });
  }

  Future<void> _openAddLiftSheet() async {
    final entry = await showModalBottomSheet<LiftEntry>(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          _LiftEntrySheet(initialLiftName: _selectedLift ?? ''),
    );
    if (entry == null) return;
    await _addEntry(entry);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedLift = _selectedLift;
    final liftEntries = selectedLift == null
        ? <LiftEntry>[]
        : _stats.entriesFor(selectedLift);
    final bestEntry = selectedLift == null
        ? null
        : _stats.bestEntryFor(selectedLift);

    return Scaffold(
      appBar: const AppHeader(),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0E1520), Color(0xFF122238)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Lift progress',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton.filled(
                      onPressed: _openAddLiftSheet,
                      icon: const Icon(Icons.add_rounded),
                      tooltip: 'Add lift',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _LiftSelector(
                  liftNames: _stats.liftNames,
                  selectedLift: selectedLift,
                  onSelected: (lift) {
                    setState(() {
                      _selectedLift = lift;
                    });
                  },
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: selectedLift == null
                      ? _EmptyStats(onAddPressed: _openAddLiftSheet)
                      : ListView(
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _PrCard(bestEntry: bestEntry),
                            const SizedBox(height: 14),
                            _ChartCard(entries: liftEntries),
                            const SizedBox(height: 14),
                            _LiftHistory(
                              entries: liftEntries.reversed.toList(),
                              isNewPr: _stats.isNewPr,
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppFooter(
        activeItem: AppFooterItem.stats,
        activeColor: Theme.of(context).colorScheme.forTimeColor,
        onLogTap: widget.onLogTap,
        onTimerTap: widget.onTimerTap,
      ),
    );
  }
}

class _LiftSelector extends StatefulWidget {
  const _LiftSelector({
    required this.liftNames,
    required this.selectedLift,
    required this.onSelected,
  });

  final List<String> liftNames;
  final String? selectedLift;
  final ValueChanged<String> onSelected;

  @override
  State<_LiftSelector> createState() => _LiftSelectorState();
}

class _LiftSelectorState extends State<_LiftSelector> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> _filteredLiftNames() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return widget.liftNames;
    return widget.liftNames
        .where((lift) => lift.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.liftNames.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final filteredLiftNames = _filteredLiftNames();
    final resultHeight = math.min(220.0, filteredLiftNames.length * 50.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const ValueKey('lift-search-field'),
          controller: _searchController,
          textInputAction: TextInputAction.search,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
          decoration: InputDecoration(
            labelText: 'Search lifts',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _searchController.text.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      setState(_searchController.clear);
                    },
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Clear search',
                  ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.06),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        if (filteredLiftNames.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'No matching lifts',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.66),
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else
          SizedBox(
            height: resultHeight,
            child: ListView.separated(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              itemCount: filteredLiftNames.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final lift = filteredLiftNames[index];
                final isSelected = lift == widget.selectedLift;
                return Material(
                  color: isSelected
                      ? theme.colorScheme.forTimeColor
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      widget.onSelected(lift);
                      FocusScope.of(context).unfocus();
                    },
                    child: SizedBox(
                      height: 42,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                lift,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_rounded,
                                color: Colors.black,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _EmptyStats extends StatelessWidget {
  const _EmptyStats({required this.onAddPressed});

  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.fitness_center_rounded,
            color: Colors.white.withValues(alpha: 0.42),
            size: 48,
          ),
          const SizedBox(height: 14),
          Text(
            'No lifts recorded yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onAddPressed,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add lift'),
          ),
        ],
      ),
    );
  }
}

class _PrCard extends StatelessWidget {
  const _PrCard({required this.bestEntry});

  final LiftEntry? bestEntry;

  @override
  Widget build(BuildContext context) {
    final entry = bestEntry;
    return _Panel(
      child: entry == null
          ? const Text('No PR yet')
          : Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.forTimeColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current PR',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.68),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatNumber(entry.weight)} kg x ${entry.reps}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'e1RM ${_formatNumber(entry.estimatedOneRepMax)} kg',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.forTimeColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.entries});

  final List<LiftEntry> entries;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Estimated 1RM over time',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 180,
            child: CustomPaint(
              painter: _LiftChartPainter(
                entries: entries,
                color: Theme.of(context).colorScheme.forTimeColor,
              ),
              child: entries.length < 2
                  ? Center(
                      child: Text(
                        'Add at least two entries to see a trend',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.58),
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _LiftHistory extends StatelessWidget {
  const _LiftHistory({required this.entries, required this.isNewPr});

  final List<LiftEntry> entries;
  final bool Function(LiftEntry entry) isNewPr;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Reps at weight',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          for (final entry in entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_formatShortDate(entry.performedAt)}  •  ${entry.reps} reps @ ${_formatNumber(entry.weight)} kg',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (isNewPr(entry))
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.forTimeColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'NEW PR',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF182A3E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: child,
    );
  }
}

class _LiftChartPainter extends CustomPainter {
  const _LiftChartPainter({required this.entries, required this.color});

  final List<LiftEntry> entries;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.length < 2) return;

    final values = entries.map((entry) => entry.estimatedOneRepMax).toList();
    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final range = math.max(maxValue - minValue, 1);
    final chartRect = Rect.fromLTWH(4, 8, size.width - 8, size.height - 28);
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1;

    for (var i = 0; i < 4; i++) {
      final y = chartRect.top + chartRect.height * i / 3;
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(chartRect.right, y),
        gridPaint,
      );
    }

    final points = <Offset>[];
    for (var i = 0; i < entries.length; i++) {
      final x = chartRect.left + (chartRect.width * i / (entries.length - 1));
      final normalized = (entries[i].estimatedOneRepMax - minValue) / range;
      final y = chartRect.bottom - (chartRect.height * normalized);
      points.add(Offset(x, y));
    }

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()..color = color;
    for (final point in points) {
      canvas.drawCircle(point, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LiftChartPainter oldDelegate) {
    return oldDelegate.entries != entries || oldDelegate.color != color;
  }
}

class _LiftEntrySheet extends StatefulWidget {
  const _LiftEntrySheet({required this.initialLiftName});

  final String initialLiftName;

  @override
  State<_LiftEntrySheet> createState() => _LiftEntrySheetState();
}

const List<String> _presetLiftNames = [
  'Back Squat',
  'Front Squat',
  'Overhead Squat',
  'Box Squat',
  'Pause Squat',
  'Tempo Squat',
  'Goblet Squat',
  'Zercher Squat',
  'Hack Squat',
  'Belt Squat',
  'Split Squat',
  'Bulgarian Split Squat',
  'Pistol Squat',
  'Leg Press',
  'Leg Extension',
  'Deadlift',
  'Conventional Deadlift',
  'Sumo Deadlift',
  'Trap Bar Deadlift',
  'Romanian Deadlift',
  'Stiff-Leg Deadlift',
  'Deficit Deadlift',
  'Block Pull',
  'Rack Pull',
  'Snatch-Grip Deadlift',
  'Single-Leg Romanian Deadlift',
  'Good Morning',
  'Hip Thrust',
  'Glute Bridge',
  'Kettlebell Swing',
  'Bench Press',
  'Close-Grip Bench Press',
  'Incline Bench Press',
  'Decline Bench Press',
  'Pause Bench Press',
  'Tempo Bench Press',
  'Dumbbell Bench Press',
  'Incline Dumbbell Bench Press',
  'Floor Press',
  'Push-Up',
  'Dip',
  'Strict Press',
  'Overhead Press',
  'Push Press',
  'Push Jerk',
  'Split Jerk',
  'Behind-the-Neck Press',
  'Seated Dumbbell Press',
  'Arnold Press',
  'Landmine Press',
  'Snatch',
  'Power Snatch',
  'Hang Snatch',
  'Hang Power Snatch',
  'Muscle Snatch',
  'Snatch Balance',
  'Clean',
  'Power Clean',
  'Hang Clean',
  'Hang Power Clean',
  'Muscle Clean',
  'Clean and Jerk',
  'Clean Pull',
  'Snatch Pull',
  'High Pull',
  'Thruster',
  'Cluster',
  'Pull-Up',
  'Strict Pull-Up',
  'Weighted Pull-Up',
  'Chin-Up',
  'Weighted Chin-Up',
  'Lat Pulldown',
  'Barbell Row',
  'Pendlay Row',
  'Dumbbell Row',
  'Chest-Supported Row',
  'Seated Cable Row',
  'T-Bar Row',
  'Face Pull',
  'Inverted Row',
  'Biceps Curl',
  'Barbell Curl',
  'Dumbbell Curl',
  'Hammer Curl',
  'Triceps Pushdown',
  'Skull Crusher',
  'Overhead Triceps Extension',
  'Lateral Raise',
  'Front Raise',
  'Rear Delt Fly',
  'Shrug',
  'Calf Raise',
  'Seated Calf Raise',
  'Hamstring Curl',
  'Nordic Curl',
  'Back Extension',
  'Reverse Hyperextension',
  'Farmer Carry',
  'Suitcase Carry',
  'Sled Push',
  'Sled Pull',
];

class _LiftEntrySheetState extends State<_LiftEntrySheet> {
  late final TextEditingController _weightController;
  late final TextEditingController _repsController;
  late final List<String> _availableLiftNames;
  String? _selectedLiftName;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final initialLift = widget.initialLiftName.trim();
    _availableLiftNames = [
      if (initialLift.isNotEmpty && !_presetLiftNames.contains(initialLift))
        initialLift,
      ..._presetLiftNames,
    ];
    _selectedLiftName = initialLift.isEmpty ? null : initialLift;
    _weightController = TextEditingController();
    _repsController = TextEditingController();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      LiftEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        liftName: _selectedLiftName!.trim(),
        weight: double.parse(_weightController.text.replaceAll(',', '.')),
        reps: int.parse(_repsController.text),
        performedAt: DateTime.now(),
      ),
    );
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.06),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add lift',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedLiftName,
                isExpanded: true,
                menuMaxHeight: 360,
                decoration: _decoration('Choose a lift'),
                dropdownColor: const Color(0xFF182A3E),
                iconEnabledColor: Colors.white,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                items: _availableLiftNames
                    .map(
                      (lift) => DropdownMenuItem<String>(
                        value: lift,
                        child: Text(lift, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedLiftName = value);
                },
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Choose a lift'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _decoration('Weight in kg'),
                validator: (value) {
                  final parsed = double.tryParse(
                    (value ?? '').replaceAll(',', '.'),
                  );
                  if (parsed == null || parsed <= 0) return 'Enter a weight';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _repsController,
                keyboardType: TextInputType.number,
                decoration: _decoration('Reps'),
                validator: (value) {
                  final parsed = int.tryParse(value ?? '');
                  if (parsed == null || parsed <= 0) return 'Enter reps';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Save lift'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatNumber(double value) {
  return value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1);
}

String _formatShortDate(DateTime date) {
  return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
}

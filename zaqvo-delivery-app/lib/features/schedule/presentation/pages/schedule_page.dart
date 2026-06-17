import 'package:flutter/material.dart';
import 'package:zaqvo_delivery_app/core/theme/app_colors.dart';

/// Your Availability — matches Figma: one shift card, one week card, status + border.
class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  bool _visibleToCustomers = true;
  _ShiftId _selectedShift = _ShiftId.morning;

  static const _shiftRowBorderUnselected = Color(0xFFCBD5E1);

  /// Editable "This week" values (default matches previous mock).
  TimeOfDay _monWedStart = const TimeOfDay(hour: 6, minute: 0);
  TimeOfDay _monWedEnd = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _friSatStart = const TimeOfDay(hour: 6, minute: 0);
  TimeOfDay _friSatEnd = const TimeOfDay(hour: 22, minute: 0);
  bool _sundayIsOff = true;
  TimeOfDay _sundayStart = const TimeOfDay(hour: 6, minute: 0);
  TimeOfDay _sundayEnd = const TimeOfDay(hour: 22, minute: 0);

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return ColoredBox(
      color: AppColors.pageBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _headerBlock(topInset),
                  Transform.translate(
                    offset: const Offset(0, -24),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _statusCard(),
                          const SizedBox(height: 12),
                          _workingHoursCard(),
                          const SizedBox(height: 16),
                          _shiftsInSingleCard(),
                          const SizedBox(height: 16),
                          _weekScheduleInSingleCard(context),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            minimum: const EdgeInsets.only(top: 8),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Availability saved'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.scheduleSaveButton,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Save Availability',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Figma: vertical blue → dark blue, bottom curve into page.
  Widget _headerBlock(double topInset) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, 6 + topInset, 16, 36),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.scheduleHeaderStart,
            AppColors.scheduleHeaderEnd,
          ],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Availability',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Manage your working hours',
                  style: TextStyle(
                    color: Color(0xE6FFFFFF),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            elevation: 0,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notifications'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.notifications_outlined,
                  color: AppColors.scheduleFigmaPrimary,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Figma: light blue border, toggle on the right, Online under toggle.
  Widget _statusCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.scheduleStatusCardBorder,
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.scheduleTitleNavy,
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'You are visible to customers',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                      color: AppColors.slate500,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _statusSwitch(),
                if (_visibleToCustomers) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Online',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusSwitch() {
    return Transform.scale(
      scale: 0.88,
      child: Switch(
        value: _visibleToCustomers,
        onChanged: (v) {
          setState(() => _visibleToCustomers = v);
        },
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        thumbColor: const WidgetStatePropertyAll<Color>(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF4ADE80);
          }
          return AppColors.slate400.withValues(alpha: 0.45);
        }),
      ),
    );
  }

  Widget _workingHoursCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x100F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.access_time,
              color: AppColors.scheduleFigmaPrimary,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WORKING HOURS TODAY',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.85,
                    color: AppColors.slate500,
                  ),
                ),
                SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '6.5 hrs',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.scheduleBodyValueBlue,
                        height: 1.0,
                        letterSpacing: -0.4,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        'Started at 8:30 AM',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.slate500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Figma: one white card; header + 4 options with dividers (no separate card shadows).
  Widget _shiftsInSingleCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: AppColors.navActive,
                ),
                SizedBox(width: 8),
                Text(
                  'Select Your Shift',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.scheduleSectionTitle,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          _shiftRow(
            id: _ShiftId.morning,
            title: 'Morning Shift',
            time: '6:00 AM - 12:00 PM',
            icon: Icons.wb_sunny_outlined,
            iconColor: AppColors.navActive,
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          _shiftRow(
            id: _ShiftId.afternoon,
            title: 'Afternoon Shift',
            time: '12:00 PM - 6:00 PM',
            icon: Icons.wb_sunny_outlined,
            iconColor: AppColors.scheduleAfternoonIcon,
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          _shiftRow(
            id: _ShiftId.evening,
            title: 'Evening Shift',
            time: '6:00 PM - 10:00 PM',
            icon: Icons.nights_stay_outlined,
            iconColor: AppColors.scheduleEveningIcon,
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          _shiftRow(
            id: _ShiftId.fullDay,
            title: 'Full Day',
            time: '6:00 AM - 10:00 PM',
            icon: Icons.local_florist_outlined,
            iconColor: AppColors.scheduleFullDayIcon,
          ),
        ],
      ),
    );
  }

  void _selectShift(_ShiftId id) {
    setState(() => _selectedShift = id);
  }

  Widget _shiftRow({
    required _ShiftId id,
    required String title,
    required String time,
    required IconData icon,
    required Color iconColor,
  }) {
    final selected = _selectedShift == id;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectShift(id),
        child: Ink(
          decoration: BoxDecoration(
            color: selected
                ? AppColors.scheduleShiftSelectedBg
                : AppColors.cardSurface,
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? AppColors.navActive : _shiftRowBorderUnselected,
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.scheduleTitleNavy,
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.scheduleShiftSubtext,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.navActive,
                    size: 26,
                  )
                else
                  const SizedBox(width: 26, height: 26),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimeRangeLabel(
    BuildContext context,
    TimeOfDay start,
    TimeOfDay end,
  ) {
    final loc = MaterialLocalizations.of(context);
    return '${loc.formatTimeOfDay(start, alwaysUse24HourFormat: false)} - '
        '${loc.formatTimeOfDay(end, alwaysUse24HourFormat: false)}';
  }

  Future<void> _openEditAllSheet(BuildContext context) async {
    final result = await showModalBottomSheet<_WeekEditResult>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      showDragHandle: true,
      backgroundColor: AppColors.pageBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return _EditWeekScheduleSheet(
          monWedStart: _monWedStart,
          monWedEnd: _monWedEnd,
          friSatStart: _friSatStart,
          friSatEnd: _friSatEnd,
          sundayOff: _sundayIsOff,
          sundayStart: _sundayStart,
          sundayEnd: _sundayEnd,
        );
      },
    );
    if (!mounted || result == null) return;
    setState(() {
      _monWedStart = result.monWedStart;
      _monWedEnd = result.monWedEnd;
      _friSatStart = result.friSatStart;
      _friSatEnd = result.friSatEnd;
      _sundayIsOff = result.sundayOff;
      _sundayStart = result.sundayStart;
      _sundayEnd = result.sundayEnd;
    });
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Weekly schedule updated'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Figma: one card, subtitle on first row, Fri–Sat row, Sun day off.
  Widget _weekScheduleInSingleCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    "This Week's Schedule",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.scheduleTitleNavy,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => _openEditAllSheet(context),
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                    child: Text(
                      'Edit All',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navActive,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          _weekLine(
            title: 'Mon, Tue, Wed',
            subtitle: 'Weekly Routine',
            isOff: false,
            time: _formatTimeRangeLabel(context, _monWedStart, _monWedEnd),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          _weekLine(
            title: 'Friday, Saturday',
            subtitle: null,
            isOff: false,
            time: _formatTimeRangeLabel(context, _friSatStart, _friSatEnd),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          _weekLine(
            title: 'Sunday',
            subtitle: null,
            isOff: _sundayIsOff,
            time: _sundayIsOff
                ? null
                : _formatTimeRangeLabel(context, _sundayStart, _sundayEnd),
          ),
        ],
      ),
    );
  }

  Widget _weekLine({
    required String title,
    String? subtitle,
    required bool isOff,
    String? time,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.scheduleTitleNavy,
                    height: 1.2,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.slate500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isOff)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.scheduleDayOffBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Day Off',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.scheduleDayOffTextOnPill,
                ),
              ),
            )
          else
            Container(
              constraints: const BoxConstraints(maxWidth: 200),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.scheduleWeekPillBorder,
                  width: 1.2,
                ),
              ),
              child: Text(
                time ?? '',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.scheduleWeekPillText,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WeekEditResult {
  const _WeekEditResult({
    required this.monWedStart,
    required this.monWedEnd,
    required this.friSatStart,
    required this.friSatEnd,
    required this.sundayOff,
    required this.sundayStart,
    required this.sundayEnd,
  });

  final TimeOfDay monWedStart;
  final TimeOfDay monWedEnd;
  final TimeOfDay friSatStart;
  final TimeOfDay friSatEnd;
  final bool sundayOff;
  final TimeOfDay sundayStart;
  final TimeOfDay sundayEnd;
}

class _EditWeekScheduleSheet extends StatefulWidget {
  const _EditWeekScheduleSheet({
    required this.monWedStart,
    required this.monWedEnd,
    required this.friSatStart,
    required this.friSatEnd,
    required this.sundayOff,
    required this.sundayStart,
    required this.sundayEnd,
  });

  final TimeOfDay monWedStart;
  final TimeOfDay monWedEnd;
  final TimeOfDay friSatStart;
  final TimeOfDay friSatEnd;
  final bool sundayOff;
  final TimeOfDay sundayStart;
  final TimeOfDay sundayEnd;

  @override
  State<_EditWeekScheduleSheet> createState() => _EditWeekScheduleSheetState();
}

class _EditWeekScheduleSheetState extends State<_EditWeekScheduleSheet> {
  late TimeOfDay _mwS;
  late TimeOfDay _mwE;
  late TimeOfDay _fsS;
  late TimeOfDay _fsE;
  late TimeOfDay _suS;
  late TimeOfDay _suE;
  late bool _sunOff;

  @override
  void initState() {
    super.initState();
    _mwS = widget.monWedStart;
    _mwE = widget.monWedEnd;
    _fsS = widget.friSatStart;
    _fsE = widget.friSatEnd;
    _sunOff = widget.sundayOff;
    _suS = widget.sundayStart;
    _suE = widget.sundayEnd;
  }

  String _formatPair(BuildContext context, TimeOfDay a, TimeOfDay b) {
    final loc = MaterialLocalizations.of(context);
    return '${loc.formatTimeOfDay(a, alwaysUse24HourFormat: false)} - '
        '${loc.formatTimeOfDay(b, alwaysUse24HourFormat: false)}';
  }

  Future<void> _pickPair(
    TimeOfDay start,
    TimeOfDay end,
    void Function(TimeOfDay, TimeOfDay) apply,
  ) async {
    final t1 = await showTimePicker(
      context: context,
      initialTime: start,
    );
    if (t1 == null || !mounted) return;
    final t2 = await showTimePicker(
      context: context,
      initialTime: end,
    );
    if (t2 == null || !mounted) return;
    setState(() => apply(t1, t2));
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 4),
              child: Text(
                'Edit weekly schedule',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.scheduleTitleNavy,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                'Set hours for each group. They apply to your availability for the week.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.slate500,
                  height: 1.35,
                ),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: h * 0.52),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _editSection(
                      context,
                      title: 'Mon, Tue, Wed',
                      subtitle: 'Weekly Routine',
                      value: _formatPair(context, _mwS, _mwE),
                      onEdit: () => _pickPair(
                        _mwS,
                        _mwE,
                        (a, b) {
                          _mwS = a;
                          _mwE = b;
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    _editSection(
                      context,
                      title: 'Friday, Saturday',
                      subtitle: null,
                      value: _formatPair(context, _fsS, _fsE),
                      onEdit: () => _pickPair(
                        _fsS,
                        _fsE,
                        (a, b) {
                          _fsS = a;
                          _fsE = b;
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x060F172A),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Sunday',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.scheduleTitleNavy,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              'Day off (no availability)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.slate700,
                              ),
                            ),
                            trailing: Switch(
                              value: _sunOff,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              trackOutlineColor:
                                  WidgetStateProperty.all(Colors.transparent),
                              thumbColor: const WidgetStatePropertyAll<Color>(
                                Colors.white,
                              ),
                              trackColor:
                                  WidgetStateProperty.resolveWith((states) {
                                if (states
                                    .contains(WidgetState.selected)) {
                                  return const Color(0xFF4ADE80);
                                }
                                return AppColors.slate400.withValues(
                                  alpha: 0.4,
                                );
                              }),
                              onChanged: (v) {
                                setState(() => _sunOff = v);
                              },
                            ),
                          ),
                          if (!_sunOff) ...[
                            const SizedBox(height: 6),
                            Material(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              child: InkWell(
                                onTap: () => _pickPair(
                                  _suS,
                                  _suE,
                                  (a, b) {
                                    _suS = a;
                                    _suE = b;
                                  },
                                ),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: AppColors.border,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.schedule,
                                        size: 20,
                                        color: AppColors.navActive,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _formatPair(
                                            context,
                                            _suS,
                                            _suE,
                                          ),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.edit_outlined,
                                        size: 18,
                                        color: AppColors.slate500,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.slate700,
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop(
                          _WeekEditResult(
                            monWedStart: _mwS,
                            monWedEnd: _mwE,
                            friSatStart: _fsS,
                            friSatEnd: _fsE,
                            sundayOff: _sunOff,
                            sundayStart: _suS,
                            sundayEnd: _suE,
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.scheduleSaveButton,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _editSection(
    BuildContext context, {
    required String title,
    String? subtitle,
    required String value,
    required Future<void> Function() onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.scheduleTitleNavy,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.slate500,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Material(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: () => onEdit(),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 20,
                      color: AppColors.navActive,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: AppColors.slate500,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _ShiftId { morning, afternoon, evening, fullDay }

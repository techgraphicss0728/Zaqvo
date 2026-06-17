import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:zaqvo_customer_app/core/router/app_routes.dart';
import 'package:zaqvo_customer_app/core/theme/app_colors.dart';
import 'package:zaqvo_customer_app/state/app_state.dart';

/// Payment checkout methods (mock data; replace with API later).
class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  static const _codId = 'cod';

  /// Mock saved instruments (mutable for delete / default changes).
  late List<_SavedPaymentMethod> _saved;

  /// Selected payment: COD or a saved method id.
  late String _selectedId;

  bool _editSaved = false;

  @override
  void initState() {
    super.initState();
    _saved = [
      const _SavedPaymentMethod(
        id: 'gpay-1',
        kind: _SavedKind.upi,
        title: 'Google Pay',
        subtitle: 'alex.zaqvo@okaxis',
        isDefault: true,
      ),
      const _SavedPaymentMethod(
        id: 'card-1',
        kind: _SavedKind.card,
        title: 'HDFC Bank Debit Card',
        subtitle: '•••• •••• •••• 4242',
        isDefault: false,
      ),
    ];
    _selectedId = 'gpay-1';
  }

  void _select(String id) => setState(() => _selectedId = id);

  void _setDefault(String id) {
    setState(() {
      for (var i = 0; i < _saved.length; i++) {
        _saved[i] = _saved[i].copyWith(isDefault: _saved[i].id == id);
      }
    });
  }

  void _deleteSaved(String id) {
    setState(() {
      _saved.removeWhere((e) => e.id == id);
      if (_selectedId == id) {
        _selectedId = _saved.isNotEmpty ? _saved.first.id : _codId;
      }
      if (_saved.isEmpty) {
        _selectedId = _codId;
      } else {
        final hasDefault = _saved.any((e) => e.isDefault);
        if (!hasDefault) {
          _saved[0] = _saved[0].copyWith(isDefault: true);
        }
      }
    });
  }

  String _labelForSelection() {
    if (_selectedId == _codId) return 'Cash on Delivery';
    for (final m in _saved) {
      if (m.id == _selectedId) return m.title;
    }
    return 'Selected method';
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final amount = appState.cartSubtotal > 0
        ? appState.cartSubtotal
        : 124.50;
    final formatted = NumberFormat.currency(symbol: r'$').format(amount);

    const bg = Color(0xFFF3F6F9);

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PaymentHeader(
            onBack: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.home);
              }
            },
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              children: [
                const _SecureBanner(),
                const SizedBox(height: 22),
                const _SectionHeading('PAY ON DELIVERY'),
                const SizedBox(height: 10),
                _PayOnDeliveryCard(
                  selected: _selectedId == _codId,
                  onSelect: () => _select(_codId),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(
                      child: _SectionHeading('SAVED METHODS'),
                    ),
                    TextButton(
                      onPressed: () =>
                          setState(() => _editSaved = !_editSaved),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.skyBlue,
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        _editSaved ? 'Done' : 'Edit',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ..._saved.map(
                  (m) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SavedMethodCard(
                      method: m,
                      selected: _selectedId == m.id,
                      editMode: _editSaved,
                      onSelect: () {
                        _select(m.id);
                        _setDefault(m.id);
                      },
                      onDelete: () => _deleteSaved(m.id),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const _SectionHeading('ADD NEW'),
                const SizedBox(height: 10),
                _DashedAddRow(
                  icon: Icons.credit_card_rounded,
                  label: 'Add Credit / Debit Card',
                  onTap: () => _showAddCardSheet(context),
                ),
                const SizedBox(height: 10),
                _DashedAddRow(
                  icon: Icons.qr_code_2_rounded,
                  label: 'Add UPI ID',
                  onTap: () => _showAddUpiSheet(context),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              12 + MediaQuery.paddingOf(context).bottom,
            ),
            child: _ProceedButton(
              label: 'Proceed to Pay $formatted',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Pay $formatted with ${_labelForSelection()} (mock)',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addUpiAndSelect(String vpa) {
    final trimmed = vpa.trim();
    if (trimmed.isEmpty) return;
    final dup = _saved.any(
      (s) =>
          s.kind == _SavedKind.upi &&
          s.subtitle.toLowerCase() == trimmed.toLowerCase(),
    );
    if (dup) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This UPI ID is already saved.')),
      );
      return;
    }
    final id = 'upi-${DateTime.now().microsecondsSinceEpoch}';
    setState(() {
      _saved = [
        for (final e in _saved) e.copyWith(isDefault: false),
        _SavedPaymentMethod(
          id: id,
          kind: _SavedKind.upi,
          title: 'UPI',
          subtitle: trimmed,
          isDefault: true,
        ),
      ];
      _selectedId = id;
    });
  }

  void _addCardAndSelect({
    required String cardDigits,
    String? label,
  }) {
    final digits = cardDigits.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 13 || digits.length > 19) return;
    final last4 = digits.substring(digits.length - 4);
    final masked = '•••• •••• •••• $last4';
    final dup = _saved.any(
      (s) =>
          s.kind == _SavedKind.card && s.subtitle.trim().endsWith(last4),
    );
    if (dup) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A card with this number is already saved.')),
      );
      return;
    }
    final id = 'card-${DateTime.now().microsecondsSinceEpoch}';
    final title = (label != null && label.trim().isNotEmpty)
        ? label.trim()
        : 'Debit / Credit Card';
    setState(() {
      _saved = [
        for (final e in _saved) e.copyWith(isDefault: false),
        _SavedPaymentMethod(
          id: id,
          kind: _SavedKind.card,
          title: title,
          subtitle: masked,
          isDefault: true,
        ),
      ];
      _selectedId = id;
    });
  }

  Future<void> _showAddUpiSheet(BuildContext context) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(ctx).bottom,
          ),
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Add UPI ID',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: Color(0xFF0A2740),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: controller,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.username],
                    decoration: const InputDecoration(
                      labelText: 'UPI ID',
                      hintText: 'yourname@bank',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final t = (v ?? '').trim();
                      if (t.isEmpty) return 'Enter a UPI ID';
                      if (!t.contains('@') || t.length < 5) {
                        return 'Enter a valid UPI ID (e.g. name@bank)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () {
                      if (formKey.currentState?.validate() != true) return;
                      Navigator.pop(ctx);
                      _addUpiAndSelect(controller.text);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.skyBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Save UPI'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    controller.dispose();
  }

  Future<void> _showAddCardSheet(BuildContext context) async {
    final numberController = TextEditingController();
    final labelController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(ctx).bottom,
          ),
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Add card',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: Color(0xFF0A2740),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: numberController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Card number',
                      hintText: '4242 4242 4242 4242',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final d = (v ?? '').replaceAll(RegExp(r'\D'), '');
                      if (d.length < 13 || d.length > 19) {
                        return 'Enter a valid card number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: labelController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nickname (optional)',
                      hintText: 'e.g. HDFC Bank Debit Card',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () {
                      if (formKey.currentState?.validate() != true) return;
                      Navigator.pop(ctx);
                      _addCardAndSelect(
                        cardDigits: numberController.text,
                        label: labelController.text.trim().isEmpty
                            ? null
                            : labelController.text,
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.skyBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Save card'),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Mock only — never store real card data in production.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.slate400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    numberController.dispose();
    labelController.dispose();
  }
}

enum _SavedKind { upi, card }

class _SavedPaymentMethod {
  const _SavedPaymentMethod({
    required this.id,
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.isDefault,
  });

  final String id;
  final _SavedKind kind;
  final String title;
  final String subtitle;
  final bool isDefault;

  _SavedPaymentMethod copyWith({bool? isDefault}) {
    return _SavedPaymentMethod(
      id: id,
      kind: kind,
      title: title,
      subtitle: subtitle,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class _PaymentHeader extends StatelessWidget {
  const _PaymentHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(28),
      ),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4A9FD9), Color(0xFF36B8E8), AppColors.skyBlue],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 16, 18),
            child: Row(
              children: [
                Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onBack,
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Payment Methods',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SecureBanner extends StatelessWidget {
  const _SecureBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF36C2F0), Color(0xFF0D47A1)],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secure Payments',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Your transaction is encrypted with bank-grade security. '
                  'ZAQVO never stores your CVV.',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    height: 1.4,
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

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
        color: Color(0xFF0A2740),
      ),
    );
  }
}

class _PayOnDeliveryCard extends StatelessWidget {
  const _PayOnDeliveryCard({
    required this.selected,
    required this.onSelect,
  });

  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 1.5,
      shadowColor: Colors.black.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.skyBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.payments_outlined,
                  color: AppColors.skyBlue,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cash on Delivery',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Color(0xFF0A2740),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Pay when your order arrives',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _RadioDot(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

class _SavedMethodCard extends StatelessWidget {
  const _SavedMethodCard({
    required this.method,
    required this.selected,
    required this.editMode,
    required this.onSelect,
    required this.onDelete,
  });

  final _SavedPaymentMethod method;
  final bool selected;
  final bool editMode;
  final VoidCallback onSelect;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 1.5,
      shadowColor: Colors.black.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                decoration: const BoxDecoration(
                  color: AppColors.skyBlue,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(16),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LeadingIcon(kind: method.kind),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Text(
                                    method.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: Color(0xFF0A2740),
                                    ),
                                  ),
                                ),
                                if (method.isDefault) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.skyBlue
                                          .withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'DEFAULT',
                                      style: TextStyle(
                                        color: Color(0xFF1565C0),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              method.subtitle,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (editMode)
                        IconButton(
                          onPressed: onDelete,
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.slate400,
                          ),
                          tooltip: 'Remove',
                        ),
                      const SizedBox(width: 4),
                      _RadioDot(selected: selected),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon({required this.kind});

  final _SavedKind kind;

  @override
  Widget build(BuildContext context) {
    switch (kind) {
      case _SavedKind.upi:
        return Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.skyBlue.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.account_balance_wallet_outlined,
            color: AppColors.skyBlue,
            size: 24,
          ),
        );
      case _SavedKind.card:
        return Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F71),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'VISA',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
        );
    }
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.skyBlue : const Color(0xFFCBD5E1),
          width: selected ? 2 : 1.5,
        ),
        color: selected
            ? AppColors.skyBlue.withValues(alpha: 0.15)
            : Colors.transparent,
      ),
      child: selected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.skyBlue,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}

class _DashedAddRow extends StatelessWidget {
  const _DashedAddRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRoundedBorderPainter(
        color: const Color(0xFFCBD5E1),
        radius: 14,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF64748B), size: 26),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF0A2740),
                    ),
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Color(0xFF94A3B8),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedRoundedBorderPainter extends CustomPainter {
  _DashedRoundedBorderPainter({
    required this.color,
    required this.radius,
  });

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(r);
    final dashLen = 5.0;
    final gap = 4.0;
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        final next = (d + dashLen).clamp(0.0, metric.length);
        final extract = metric.extractPath(d, next);
        canvas.drawPath(
          extract,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2,
        );
        d += dashLen + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

class _ProceedButton extends StatelessWidget {
  const _ProceedButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [Color(0xFF36C2F0), Color(0xFF0D47A1)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

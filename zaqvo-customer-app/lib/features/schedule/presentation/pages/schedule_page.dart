import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:zaqvo_customer_app/core/theme/app_colors.dart';
import 'package:zaqvo_customer_app/domain/models/product.dart';
import 'package:zaqvo_customer_app/shared/widgets/water_refresh_control.dart';
import 'package:zaqvo_customer_app/state/app_state.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDate = DateTime.now();
  String? _selectedProductId;
  int _quantity = 1;
  int _selectedSlot = 0;

  static const _slots = [
    '6AM - 9AM',
    '9AM - 12PM',
    '12PM - 3PM',
    '3PM - 6PM',
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final products = appState.products;
    _selectedProductId ??= products.isNotEmpty ? products.first.id : null;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Schedule Delivery')),
      body: WaterRefreshWrapper(
        onRefresh: appState.refreshData,
        child: Skeletonizer(
          enabled: appState.isBusy,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            children: [
              _buildCalendarCard(),
              const SizedBox(height: 16),
              const Text(
                'Select Product',
                style: TextStyle(fontSize: 22 / 1.2, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 190,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final selected = product.id == _selectedProductId;
                    return _ScheduleProductCard(
                      product: product,
                      selected: selected,
                      onTap: () => setState(() => _selectedProductId = product.id),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Quantity',
                style: TextStyle(fontSize: 22 / 1.2, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x172A88C8),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _qtyBtn(Icons.remove, () {
                      if (_quantity > 1) setState(() => _quantity--);
                    }),
                    Text(
                      '$_quantity',
                      style: const TextStyle(
                        fontSize: 40 / 1.4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    _qtyBtn(Icons.add, () => setState(() => _quantity++)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Preferred Time Slot',
                style: TextStyle(fontSize: 22 / 1.2, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _slots.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.1,
                ),
                itemBuilder: (context, index) {
                  final selected = _selectedSlot == index;
                  return InkWell(
                    onTap: () => setState(() => _selectedSlot = index),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF2BA7DE)
                              : const Color(0xFFE2EBF3),
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _slotLabel(index),
                            style: const TextStyle(
                              color: Color(0xFF788899),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _slots[index],
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18 / 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Upcoming Scheduled Deliveries',
                style: TextStyle(fontSize: 22 / 1.2, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              ...appState.scheduledDeliveries.take(3).map((entry) {
                final product = appState.getProductById(entry.productId);
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x142A88C8),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        DateFormat('MMM d, yyyy').format(entry.scheduledDate),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Text(
                        '${entry.timeSlotLabel}\n${entry.quantity}x ${product?.name ?? 'Water Can'}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2B9BD6), Color(0xFF43C9EF)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: FilledButton(
                    onPressed: _selectedProductId == null
                        ? null
                        : () {
                            appState.scheduleDelivery(
                              productId: _selectedProductId!,
                              scheduledDate: _selectedDate,
                              timeSlotLabel: _slots[_selectedSlot],
                              quantity: _quantity,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Delivery scheduled successfully'),
                              ),
                            );
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Schedule Delivery',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFF2BA7DE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  Widget _buildCalendarCard() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(
      _focusedMonth.year,
      _focusedMonth.month,
    );
    final firstWeekday = firstDay.weekday % 7;
    final leadingDays = firstWeekday;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A2A88C8),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _focusedMonth =
                        DateTime(_focusedMonth.year, _focusedMonth.month - 1);
                  });
                },
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    DateFormat('MMMM yyyy').format(_focusedMonth),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _focusedMonth =
                        DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                  });
                },
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _WeekText('Mo'),
              _WeekText('Tu'),
              _WeekText('We'),
              _WeekText('Th'),
              _WeekText('Fr'),
              _WeekText('Sa'),
              _WeekText('Su'),
            ],
          ),
          const SizedBox(height: 6),
          GridView.builder(
            itemCount: 42,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.18,
            ),
            itemBuilder: (context, index) {
              final dayNum = index - leadingDays + 1;
              final inMonth = dayNum > 0 && dayNum <= daysInMonth;
              if (!inMonth) return const SizedBox.shrink();
              final date =
                  DateTime(_focusedMonth.year, _focusedMonth.month, dayNum);
              final selected = DateUtils.isSameDay(date, _selectedDate);
              return InkWell(
                onTap: () => setState(() => _selectedDate = date),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFF2E8FD9) : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$dayNum',
                      style: TextStyle(
                        color: selected ? Colors.white : const Color(0xFF2A2F35),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _slotLabel(int index) {
    const labels = ['Morning', 'Late Morning', 'Afternoon', 'Late Afternoon'];
    return labels[index];
  }
}

class _WeekText extends StatelessWidget {
  const _WeekText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF96A2AF),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _ScheduleProductCard extends StatelessWidget {
  const _ScheduleProductCard({
    required this.product,
    required this.selected,
    required this.onTap,
  });

  final Product product;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 112,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF2BA7DE) : const Color(0xFFE5EDF4),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  colors: [Color(0xFF9AE2FC), Color(0xFF5EC5F1)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              textScaler: const TextScaler.linear(1),
            ),
            Text(
              '₹${product.price.toStringAsFixed(0)}',
              style: const TextStyle(
                color: Color(0xFF1F8BC8),
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
              textScaler: const TextScaler.linear(1),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onTap,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 30),
                  backgroundColor: const Color(0xFF2FADE3),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                ),
                child: const Text(
                  'Add',
                  textScaler: TextScaler.linear(1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

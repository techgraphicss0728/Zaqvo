import 'package:flutter/material.dart';
import 'package:zaqvo_delivery_app/core/theme/app_colors.dart';

/// Partner earnings — Figma: header, today's card, week/month, stats, list, bonus.
class EarningsPage extends StatelessWidget {
  const EarningsPage({super.key});

  static const _mockRecent = <_RecentRow>[
    _RecentRow('Lakshmi Devi', '1 × 20L Can • 9:00 AM', '₹75'),
    _RecentRow('Ramesh Kumar', '2 × 20L Cans • 10:20 AM', '₹150'),
    _RecentRow('Sita Reddy', '1 × 20L Can • 11:45 AM', '₹75'),
    _RecentRow('Anil Verma', '3 × 20L Cans • 1:10 PM', '₹210'),
    _RecentRow('Priya Sharma', '1 × 20L Can • 3:00 PM', '₹75'),
  ];

  static const _mockBonuses = <_BonusRow>[
    _BonusRow('Complete 20 deliveries this week', '+₹200'),
    _BonusRow('Maintain 4.5+ rating for 7 days', '+₹100'),
    _BonusRow('5 on-time drops in a row', '+₹150'),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.pageBackground,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _headerStrip(),
              Transform.translate(
                offset: const Offset(0, -20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _todaysEarningsCard(),
                      const SizedBox(height: 12),
                      _weekMonthRow(),
                      const SizedBox(height: 12),
                      _detailedStatsCard(),
                      const SizedBox(height: 12),
                      _recentDeliveriesCard(),
                      const SizedBox(height: 12),
                      _bonusOpportunitiesCard(),
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

  Widget _headerStrip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.earningsHeaderStart,
            AppColors.earningsHeaderEnd,
          ],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: AppColors.earningsHeaderEnd,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Earnings 💰',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Track your income',
                  style: TextStyle(
                    color: Color(0xE0FFFFFF),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _todaysEarningsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.earningsTodayCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.earningsTodayCard.withValues(alpha: 0.45),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "TODAY'S EARNINGS",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '₹850',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 6),
              Text(
                '5 deliveries completed',
                style: TextStyle(
                  color: Color(0xE6FFFFFF),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Material(
              color: Colors.white.withValues(alpha: 0.25),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {},
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.trending_up_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _weekMonthRow() {
    return Row(
      children: [
        Expanded(
          child: _summaryMiniCard(
            label: 'This Week',
            amount: '₹4,200',
            color: AppColors.earningsWeekCard,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryMiniCard(
            label: 'This Month',
            amount: '₹18,500',
            color: AppColors.earningsMonthCard,
          ),
        ),
      ],
    );
  }

  Widget _summaryMiniCard({
    required String label,
    required String amount,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x150F172A),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailedStatsCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _statLine(
            'Completed Deliveries',
            valueWidget: Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.successLight,
                shape: BoxShape.circle,
              ),
              child: const Text(
                '5',
                style: TextStyle(
                  color: AppColors.orderPriceGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const Divider(height: 20, color: AppColors.border),
          _statLine(
            'Average per Delivery',
            valueText: '₹170',
            valueStrong: true,
            valueColor: AppColors.textPrimary,
          ),
          const Divider(height: 20, color: AppColors.border),
          _statLine(
            'Bonus Earned',
            valueText: '₹500',
            valueStrong: true,
            valueColor: AppColors.earningsListGreen,
          ),
        ],
      ),
    );
  }

  Widget _statLine(
    String label, {
    String? valueText,
    Color? valueColor,
    bool valueStrong = false,
    Widget? valueWidget,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.slate500,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (valueWidget != null)
            valueWidget
          else
            Text(
              valueText ?? '',
              style: TextStyle(
                color: valueColor ?? AppColors.textPrimary,
                fontSize: 15,
                fontWeight: valueStrong ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _recentDeliveriesCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 4),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _BlueCheckCircle(),
                SizedBox(width: 8),
                Text(
                  'Recent Deliveries',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          for (var i = 0; i < _mockRecent.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.border),
            _recentTile(_mockRecent[i]),
          ],
        ],
      ),
    );
  }

  Widget _recentTile(_RecentRow r) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  r.detail,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.slate500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            r.amount,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.earningsListGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bonusOpportunitiesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.earningsBonusCardBorder,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Bonus Opportunities',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < _mockBonuses.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _bonusRow(_mockBonuses[i]),
          ],
        ],
      ),
    );
  }

  Widget _bonusRow(_BonusRow b) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            b.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.slate700,
              height: 1.35,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.earningsBonusPillBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            b.reward,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.earningsBonusPillText,
            ),
          ),
        ),
      ],
    );
  }
}

class _BlueCheckCircle extends StatelessWidget {
  const _BlueCheckCircle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: AppColors.earningsRecentHeaderIcon,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check,
        color: Colors.white,
        size: 16,
      ),
    );
  }
}

class _RecentRow {
  const _RecentRow(this.name, this.detail, this.amount);
  final String name;
  final String detail;
  final String amount;
}

class _BonusRow {
  const _BonusRow(this.title, this.reward);
  final String title;
  final String reward;
}

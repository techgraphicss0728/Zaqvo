import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zaqvo_delivery_app/core/theme/app_colors.dart';
import 'package:zaqvo_delivery_app/core/utils/order_contact_launch.dart';
import 'package:zaqvo_delivery_app/features/orders/presentation/models/partner_order.dart';

/// Completed order — detail view + proof of delivery (pick image, show in place).
class CompletedOrderDetailsPage extends StatefulWidget {
  const CompletedOrderDetailsPage({super.key, required this.orderId});

  final String orderId;

  @override
  State<CompletedOrderDetailsPage> createState() =>
      _CompletedOrderDetailsPageState();
}

class _CompletedOrderDetailsPageState extends State<CompletedOrderDetailsPage> {
  final _picker = ImagePicker();
  Uint8List? _proofBytes;

  Future<void> _pick(ImageSource source) async {
    try {
      final x = await _picker.pickImage(
        source: source,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 88,
      );
      if (x == null) return;
      final bytes = await x.readAsBytes();
      if (!mounted) return;
      setState(() => _proofBytes = bytes);
    } on PlatformException catch (e) {
      if (!mounted) return;
      final isChannel = e.code == 'channel-error' ||
          (e.message?.contains('Unable to establish connection') ?? false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isChannel
                ? 'Image service is not ready. Stop the app, run: flutter clean && flutter pub get, then rebuild (not hot reload).'
                : 'Could not open the image picker: ${e.message ?? e.code}',
          ),
        ),
      );
    }
  }

  /// Close the sheet first, then pick after the route is gone so the Android
  /// Activity / Pigeon channel is in a valid state for [image_picker].
  Future<void> _chooseSource(ImageSource source) async {
    Navigator.of(context, rootNavigator: true).pop();
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    await _pick(source);
  }

  void _onProofTap() {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                onTap: () => _chooseSource(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take a photo'),
                onTap: () => _chooseSource(ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = findCompletedOrderById(widget.orderId);
    if (order == null) {
      return Scaffold(
        backgroundColor: AppColors.pageBackground,
        appBar: AppBar(
          title: const Text('Order'),
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
        ),
        body: const Center(
          child: Text('Order not found', style: TextStyle(color: AppColors.slate500)),
        ),
      );
    }

    return ColoredBox(
      color: AppColors.pageBackground,
      child: Column(
        children: [
          _DetailHeader(
            orderId: order.id,
            secondaryRef: order.secondaryRef,
            onBack: () => context.pop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  _StatusCard(),
                  const SizedBox(height: 12),
                  _CustomerCard(
                    order: order,
                    onNavigate: () {
                      launchMapsForAddress(context, order.fullAddress);
                    },
                    onCall: () {
                      launchCustomerCall(context, order.customerPhone);
                    },
                  ),
                  const SizedBox(height: 12),
                  _OrderInfoCard(order: order),
                  const SizedBox(height: 12),
                  _ProofSection(
                    bytes: _proofBytes,
                    onTap: _onProofTap,
                  ),
                  const SizedBox(height: 12),
                  _EarningsRow(amount: order.amount),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.orderId,
    required this.secondaryRef,
    required this.onBack,
  });

  final String orderId;
  final String secondaryRef;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        4,
        MediaQuery.paddingOf(context).top + 4,
        12,
        20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.ordersHeaderTop,
            AppColors.ordersHeaderBottom,
          ],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '#$orderId',
                  style: const TextStyle(
                    color: Color(0xE0FFFFFF),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '#$secondaryRef',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.orderPriceGreen, size: 28),
          const SizedBox(width: 10),
          const Text(
            'Order Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.orderCompletedBadgeBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'COMPLETED',
              style: TextStyle(
                color: AppColors.orderCompletedBadgeText,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({
    required this.order,
    required this.onNavigate,
    required this.onCall,
  });

  final CompletedPartnerOrder order;
  final VoidCallback onNavigate;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person_outline, color: AppColors.navActive, size: 24),
              SizedBox(width: 8),
              Text(
                'Customer Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _labelValue('NAME', order.customerName, valueBold: true),
          const SizedBox(height: 10),
          _labelValue('PHONE', order.customerPhone, valueBold: true),
          const SizedBox(height: 10),
          _labelValue('ADDRESS', order.fullAddress, valueBold: false),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _OutlineAction(
                  label: 'Navigate',
                  icon: Icons.near_me_outlined,
                  onPressed: onNavigate,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _OutlineAction(
                  label: 'Call',
                  icon: Icons.phone_outlined,
                  onPressed: onCall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _labelValue(String label, String value, {required bool valueBold}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: AppColors.orderDetailLabel,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        value,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: valueBold ? FontWeight.w800 : FontWeight.w500,
          height: 1.35,
        ),
      ),
    ],
  );
}

class _OutlineAction extends StatelessWidget {
  const _OutlineAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: const BorderSide(color: AppColors.navActive, width: 1.2),
        foregroundColor: AppColors.navActive,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _OrderInfoCard extends StatelessWidget {
  const _OrderInfoCard({required this.order});

  final CompletedPartnerOrder order;

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shopping_bag_outlined, color: AppColors.navActive, size: 24),
              SizedBox(width: 8),
              Text(
                'Order Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _OrderInfoRow('Items', order.itemsLabel),
          const SizedBox(height: 10),
          _OrderInfoRow('Distance', '${order.distanceKm} km'),
          const SizedBox(height: 10),
          _OrderInfoRow('Delivery Time', order.timeLabel),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text(
                'Payment',
                style: TextStyle(
                  color: AppColors.orderDetailLabel,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.orderDetailPaymentBadgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.isOnline ? 'ONLINE' : 'CASH',
                  style: const TextStyle(
                    color: AppColors.orderDetailIcon,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderInfoRow extends StatelessWidget {
  const _OrderInfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.orderDetailLabel,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProofSection extends StatelessWidget {
  const _ProofSection({
    required this.bytes,
    required this.onTap,
  });

  final Uint8List? bytes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Proof of delivery',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Upload a photo of the delivery. It will show here for this order.',
            style: TextStyle(
              color: AppColors.slate500,
              fontSize: 13,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Material(
            color: AppColors.pageBackground,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 1.1,
                  child: bytes != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.memory(
                              bytes!,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              right: 10,
                              bottom: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.proofOverlay,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.verified,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Verified Delivery',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : const _ProofPlaceholder(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProofPlaceholder extends StatelessWidget {
  const _ProofPlaceholder();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorder(),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_a_photo_outlined,
              size: 40,
              color: AppColors.slate400,
            ),
            SizedBox(height: 8),
            Text(
              'Tap to upload',
              style: TextStyle(
                color: AppColors.slate500,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Gallery or camera',
              style: TextStyle(
                color: AppColors.slate400,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedBorder extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(16),
    );
    final paint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(r, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EarningsRow extends StatelessWidget {
  const _EarningsRow({required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Row(
        children: [
          const Icon(
            Icons.payments_outlined,
            color: AppColors.orderPriceGreen,
            size: 26,
          ),
          const SizedBox(width: 10),
          const Text(
            'Delivery Earnings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Text(
            '₹$amount',
            style: const TextStyle(
              color: AppColors.orderPriceGreen,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  const _WhiteCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
      child: child,
    );
  }
}

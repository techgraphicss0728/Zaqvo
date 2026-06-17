import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zaqvo_delivery_app/core/theme/app_colors.dart';

/// KYC-style documents: upload per type → orange "UPLOADED" → green "VERIFIED" (admin step).
class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocRow {
  _DocRow({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;
  DocumentUploadStatus status = DocumentUploadStatus.notUploaded;
  DateTime? uploadedAt;
}

enum DocumentUploadStatus {
  notUploaded,
  uploadedPending,
  verified,
}

class _DocumentsPageState extends State<DocumentsPage> {
  final _picker = ImagePicker();

  late final List<_DocRow> _rows = [
    _DocRow(
      label: 'Aadhar Card',
      icon: Icons.badge_outlined,
    ),
    _DocRow(
      label: 'Driving License',
      icon: Icons.card_membership_outlined,
    ),
    _DocRow(
      label: 'Vehicle RC',
      icon: Icons.directions_car_outlined,
    ),
    _DocRow(
      label: 'Bank Account Details',
      icon: Icons.account_balance_outlined,
    ),
  ];

  int get _verifiedCount =>
      _rows.where((e) => e.status == DocumentUploadStatus.verified).length;
  int get _missingCount =>
      _rows.where((e) => e.status == DocumentUploadStatus.notUploaded).length;
  int get _pendingCount =>
      _rows.where((e) => e.status == DocumentUploadStatus.uploadedPending).length;

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _pickFor(_DocRow row, ImageSource source) async {
    Navigator.of(context, rootNavigator: true).pop();
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    try {
      final x = await _picker.pickImage(
        source: source,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 88,
      );
      if (x == null) return;
      if (!mounted) return;
      setState(() {
        row.status = DocumentUploadStatus.uploadedPending;
        row.uploadedAt = DateTime.now();
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Document received. It will show as verified after admin approval.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on PlatformException catch (e) {
      if (!mounted) return;
      final isChannel = e.code == 'channel-error' ||
          (e.message?.contains('Unable to establish connection') ?? false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isChannel
                ? 'Image service is not ready. Rebuild the app (not hot reload).'
                : 'Could not open the image picker: ${e.message ?? e.code}',
          ),
        ),
      );
    }
  }

  void _openSourceSheet(_DocRow row) {
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
                onTap: () => _pickFor(row, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take a photo'),
                onTap: () => _pickFor(row, ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onRowTap(_DocRow row) {
    switch (row.status) {
      case DocumentUploadStatus.notUploaded:
        _openSourceSheet(row);
        break;
      case DocumentUploadStatus.uploadedPending:
        _openPendingSheet(row);
        break;
      case DocumentUploadStatus.verified:
        break;
    }
  }

  void _openPendingSheet(_DocRow row) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Verification in progress',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '“${row.label}” is uploaded and waiting for team review. '
                  'It usually takes 24–48 business hours. '
                  'When the backend marks it approved, the badge will turn green.',
                  style: const TextStyle(
                    color: AppColors.slate500,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _openSourceSheet(row);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.slate500,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Replace document'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    setState(
                      () => row.status = DocumentUploadStatus.verified,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.orderOutlineTeal,
                    side: const BorderSide(
                      color: AppColors.orderOutlineTeal,
                      width: 1.2,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Mark as verified (admin)'),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Use “Mark as verified (admin)” to mirror approval from your server.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.slate400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onUploadNewDocument() {
    final missing = _rows
        .where((r) => r.status == DocumentUploadStatus.notUploaded)
        .toList();
    if (missing.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All document slots already have a file.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (missing.length == 1) {
      _openSourceSheet(missing.first);
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Upload for',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              for (final r in missing)
                ListTile(
                  leading: Icon(r.icon, color: AppColors.documentsRowIcon),
                  title: Text(r.label),
                  onTap: () {
                    Navigator.pop(ctx);
                    _openSourceSheet(r);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

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
              _headerBar(context),
              Transform.translate(
                offset: const Offset(0, -12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _statusBanner(),
                      const SizedBox(height: 12),
                      _uploadedCard(),
                      const SizedBox(height: 12),
                      _updateCard(),
                      const SizedBox(height: 12),
                      _importantNotes(),
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

  Widget _headerBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 4, 12, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.documentsHeaderStart,
            AppColors.documentsHeaderEnd,
          ],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                tooltip: 'Back',
              ),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Documents',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Manage your verification documents',
                      style: TextStyle(
                        color: Color(0xE6FFFFFF),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.profileAvatarBg,
                child: Text(
                  'V',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
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

  Widget _statusBanner() {
    if (_verifiedCount == 4) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.documentsAllVerifiedBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.successStrong,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'All Documents Verified',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.documentsAllVerifiedText,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "You're all set to deliver!",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.documentsAllVerifiedText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    if (_pendingCount > 0 && _missingCount == 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.documentsReviewBannerBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            Icon(Icons.schedule, color: AppColors.documentsReviewBannerText),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Some documents are waiting for admin verification.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.documentsReviewBannerText,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.documentsPromptBannerBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.documentsPromptBannerText),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Upload all four documents to complete verification.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.documentsPromptBannerText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _uploadedCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 8),
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
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Uploaded Documents',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.shield_outlined,
                size: 22,
                color: AppColors.documentsHeaderEnd,
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < _rows.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.border),
            _docRow(_rows[i]),
          ],
        ],
      ),
    );
  }

  Widget _docRow(_DocRow row) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onRowTap(row),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                row.icon,
                size: 26,
                color: AppColors.documentsRowIcon,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            row.label,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (row.status == DocumentUploadStatus.notUploaded) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.add_circle_outline,
                            size: 22,
                            color: AppColors.documentsHeaderEnd,
                          ),
                        ],
                      ],
                    ),
                    if (row.uploadedAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Uploaded on ${_formatDate(row.uploadedAt!)}',
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
              if (row.status == DocumentUploadStatus.uploadedPending)
                _statusPill('UPLOADED', isVerified: false),
              if (row.status == DocumentUploadStatus.verified)
                _statusPill('VERIFIED', isVerified: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusPill(String text, {required bool isVerified}) {
    return Container(
      margin: const EdgeInsets.only(left: 8, top: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: isVerified
            ? AppColors.profileDocVerifiedBg
            : AppColors.docUploadBadgeBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
          color: isVerified
              ? AppColors.profileDocVerifiedText
              : AppColors.docUploadBadgeText,
        ),
      ),
    );
  }

  Widget _updateCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Need to Update?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'If your documents have expired or you have a new vehicle, please '
            'update them here to continue working without interruptions.',
            style: TextStyle(
              color: AppColors.slate500,
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _onUploadNewDocument,
              icon: const Icon(Icons.upload_file_outlined, size: 20),
              label: const Text(
                'Upload New Document',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.navActive,
                side: const BorderSide(color: AppColors.navActive, width: 1.2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _importantNotes() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.documentsNotesPanelBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.documentsNotesPanelBorder,
          width: 1,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: AppColors.documentsNotesText,
              ),
              SizedBox(width: 8),
              Text(
                'Important Notes',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.documentsNotesText,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          _NoteBullet(
            'Ensure documents are clear and legible to avoid verification delays.',
          ),
          SizedBox(height: 6),
          _NoteBullet(
            'Verification typically takes 24-48 business hours.',
          ),
          SizedBox(height: 6),
          _NoteBullet(
            'Keep originals ready for physical verification if requested.',
          ),
        ],
      ),
    );
  }
}

class _NoteBullet extends StatelessWidget {
  const _NoteBullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '• ',
          style: TextStyle(
            color: AppColors.documentsNotesText,
            fontWeight: FontWeight.w800,
            height: 1.4,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.documentsNotesText,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

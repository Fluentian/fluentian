import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/app_localization.dart';
import '../core/theme.dart';
import '../models/course_model.dart';
import '../providers/content_provider.dart';
import '../services/download_manager.dart';

/// Lets a learner browse their courses unit-by-unit and explicitly
/// download a unit (all lessons + audio) for offline use, with an
/// estimated download size shown before committing.
class OfflineDownloadsScreen extends StatefulWidget {
  const OfflineDownloadsScreen({super.key});

  @override
  State<OfflineDownloadsScreen> createState() => _OfflineDownloadsScreenState();
}

class _OfflineDownloadsScreenState extends State<OfflineDownloadsScreen> {
  final _downloadManager = DownloadManager.instance;
  Set<String> _downloadedUnitIds = {};
  final Set<String> _inProgressUnitIds = {};

  @override
  void initState() {
    super.initState();
    _refreshDownloadedIds();
  }

  Future<void> _refreshDownloadedIds() async {
    final ids = await _downloadManager.getDownloadedUnitIds();
    if (mounted) setState(() => _downloadedUnitIds = ids);
  }

  Future<void> _handleDownload(UnitModel unit) async {
    setState(() => _inProgressUnitIds.add(unit.id));
    final result = await _downloadManager.downloadUnit(unit);
    if (!mounted) return;
    setState(() => _inProgressUnitIds.remove(unit.id));

    switch (result.outcome) {
      case DownloadOutcome.downloaded:
        await _refreshDownloadedIds();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: LText('Downloaded "${unit.title}" for offline use.'),
          ),
        );
      case DownloadOutcome.wifiRequired:
        if (!mounted) return;
        _confirmDownloadOverCellular(unit);
      case DownloadOutcome.failed:
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: LText('Could not finish the download. Try again.')),
        );
    }
  }

  Future<void> _confirmDownloadOverCellular(UnitModel unit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const LText('Download over mobile data?'),
        content: const LText(
          'Wi-Fi-only downloads is on in your settings. Downloading this unit now will use your mobile data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const LText('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const LText('Download anyway'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _inProgressUnitIds.add(unit.id));
    final result = await _downloadManager.downloadUnit(unit, ignoreWifiSetting: true);
    if (!mounted) return;
    setState(() => _inProgressUnitIds.remove(unit.id));
    if (result.outcome == DownloadOutcome.downloaded) {
      await _refreshDownloadedIds();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: LText('Downloaded "${unit.title}" for offline use.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: LText('Could not finish the download. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final courses = context.watch<ContentProvider>().courses;
    return Scaffold(
      backgroundColor: FluentianColors.pageBg,
      appBar: AppBar(
        title: LText(
          'Downloaded lessons',
          style: GoogleFonts.inter(fontWeight: FontWeight.w900),
        ),
        backgroundColor: FluentianColors.pageBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: courses.isEmpty
          ? const Center(child: LText('No courses loaded yet.'))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              itemCount: courses.length,
              itemBuilder: (context, courseIndex) {
                final course = courses[courseIndex];
                final units = List<UnitModel>.of(course.units)
                  ..sort((a, b) => a.unitNo.compareTo(b.unitNo));
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: LText(
                          course.code,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w900,
                            color: FluentianColors.textSecondary,
                          ),
                        ),
                      ),
                      ...units.map(
                        (unit) => _UnitDownloadRow(
                          unit: unit,
                          isDownloaded: _downloadedUnitIds.contains(unit.id),
                          isInProgress: _inProgressUnitIds.contains(unit.id),
                          onDownload: () => _handleDownload(unit),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _UnitDownloadRow extends StatefulWidget {
  final UnitModel unit;
  final bool isDownloaded;
  final bool isInProgress;
  final VoidCallback onDownload;

  const _UnitDownloadRow({
    required this.unit,
    required this.isDownloaded,
    required this.isInProgress,
    required this.onDownload,
  });

  @override
  State<_UnitDownloadRow> createState() => _UnitDownloadRowState();
}

class _UnitDownloadRowState extends State<_UnitDownloadRow> {
  int? _estimatedBytes;
  bool _estimating = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isDownloaded) _estimateSize();
  }

  Future<void> _estimateSize() async {
    setState(() => _estimating = true);
    final bytes = await DownloadManager.instance.estimateUnitDownloadBytes(widget.unit);
    if (mounted) {
      setState(() {
        _estimatedBytes = bytes;
        _estimating = false;
      });
    }
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '< 1 MB';
    final mb = bytes / (1024 * 1024);
    if (mb < 1) return '< 1 MB';
    return '${mb.toStringAsFixed(mb < 10 ? 1 : 0)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FluentianColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LText(
                  widget.unit.title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: FluentianColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                if (widget.isDownloaded)
                  LText(
                    'Downloaded · available offline',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: FluentianColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else if (_estimating)
                  LText(
                    'Estimating size…',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: FluentianColors.textSecondary,
                    ),
                  )
                else
                  LText(
                    _estimatedBytes != null
                        ? '${widget.unit.lessons.length} lessons · ~${_formatBytes(_estimatedBytes!)}'
                        : '${widget.unit.lessons.length} lessons',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: FluentianColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (widget.isInProgress)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (widget.isDownloaded)
            const Icon(Icons.check_circle_rounded, color: FluentianColors.primary)
          else
            IconButton(
              onPressed: widget.onDownload,
              icon: const Icon(Icons.download_rounded),
              color: FluentianColors.primary,
              tooltip: 'Download for offline use',
            ),
        ],
      ),
    );
  }
}

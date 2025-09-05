import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'dart:convert';

class CsvUploadWidget extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onCsvUploaded;

  const CsvUploadWidget({super.key, required this.onCsvUploaded});

  @override
  State<CsvUploadWidget> createState() => _CsvUploadWidgetState();
}

class _CsvUploadWidgetState extends State<CsvUploadWidget> {
  late DropzoneViewController? _dropzoneController;
  bool _isUploading = false;
  bool _isDragOver = false;

  Future<void> _pickAndProcessFile() async {
    try {
      setState(() => _isUploading = true);

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final csvData = await _processCsvFile(file.bytes!, file.name);
        widget.onCsvUploaded(csvData);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error reading CSV file: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<List<Map<String, dynamic>>> _processCsvFile(
      List<int> bytes, String fileName) async {
    final csvString = utf8.decode(bytes);
    final lines =
        csvString.split('\n').where((line) => line.trim().isNotEmpty).toList();

    if (lines.isEmpty) {
      throw Exception('CSV file is empty');
    }

    // Parse header
    final header = lines.first.split(',').map((h) => h.trim()).toList();
    final expectedColumns = ['symbol', 'lastPrice', 'asOfISO', 'snapshotLabel'];

    for (final col in expectedColumns) {
      if (!header.contains(col)) {
        throw Exception('Missing required column: $col');
      }
    }

    // Parse data rows
    final csvData = <Map<String, dynamic>>[];
    for (int i = 1; i < lines.length; i++) {
      final values = lines[i].split(',').map((v) => v.trim()).toList();

      if (values.length != header.length) {
        continue; // Skip malformed rows
      }

      final row = <String, dynamic>{};
      for (int j = 0; j < header.length; j++) {
        row[header[j]] = values[j];
      }

      // Validate required fields
      if (row['symbol']?.isNotEmpty == true &&
          row['lastPrice']?.isNotEmpty == true &&
          row['snapshotLabel']?.isNotEmpty == true) {
        csvData.add(row);
      }
    }

    if (csvData.isEmpty) {
      throw Exception('No valid data rows found in CSV');
    }

    return csvData;
  }

  void _downloadCsvTemplate() {
    final csvContent = 'symbol,lastPrice,asOfISO,snapshotLabel\n'
        'GP,302,2025-09-04T04:00:00Z,open\n'
        'BATBC,525,2025-09-04T04:00:00Z,open\n'
        'SQURPHARMA,252,2025-09-04T04:00:00Z,open\n'
        'UTTARAFUND,16.3,2025-09-04T04:00:00Z,open\n'
        'IDLCMF,12.6,2025-09-04T04:00:00Z,open\n'
        'XAUBDT,100450,2025-09-04T04:00:00Z,open';

    if (kIsWeb) {
      // Web download implementation would use html package
      // For now, show content in dialog
      _showTemplateDialog(csvContent);
    } else {
      // Mobile implementation would save to downloads
      _showTemplateDialog(csvContent);
    }
  }

  void _showTemplateDialog(String csvContent) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('CSV Template'),
        content: SingleChildScrollView(
          child: SelectableText(
            csvContent,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.upload_file,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'CSV Upload',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (kIsWeb)
              // Web drag-drop zone
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _isDragOver
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).dividerColor,
                    width: _isDragOver ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: _isDragOver
                      ? Theme.of(context).colorScheme.primary.withAlpha(26)
                      : Colors.transparent,
                ),
                child: Stack(
                  children: [
                    DropzoneView(
                      onCreated: (controller) =>
                          _dropzoneController = controller,
                      onDropFiles: (files) async {
                        if (files?.isNotEmpty == true && !_isUploading) {
                          setState(() => _isUploading = true);
                          try {
                            final bytes = await _dropzoneController!
                                .getFileData(files!.first);
                            final csvData =
                                await _processCsvFile(bytes, files.first.name);
                            widget.onCsvUploaded(csvData);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error processing file: $e'),
                                backgroundColor:
                                    Theme.of(context).colorScheme.error,
                              ),
                            );
                          } finally {
                            setState(() => _isUploading = false);
                          }
                        }
                      },
                      onHover: () => setState(() => _isDragOver = true),
                      onLeave: () => setState(() => _isDragOver = false),
                    ),
                    Center(
                      child: _isUploading
                          ? const CircularProgressIndicator()
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cloud_upload,
                                  size: 32,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withAlpha(179),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Drop CSV file here or click to browse',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              )
            else
              // Mobile file picker button
              Container(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _pickAndProcessFile,
                  icon: _isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.attach_file),
                  label:
                      Text(_isUploading ? 'Uploading...' : 'Select CSV File'),
                ),
              ),

            const SizedBox(height: 12),

            // Template download and info
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: _downloadCsvTemplate,
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('Download Template'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message:
                      'CSV Format: symbol,lastPrice,asOfISO,snapshotLabel\nsnapshotLabel: open, close, or manual',
                  child: Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
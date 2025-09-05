import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

import './widgets/csv_upload_widget.dart';
import './widgets/global_last_updated_widget.dart';
import './widgets/instrument_edit_dialog.dart';
import './widgets/recalculate_pl_button.dart';
import './widgets/snapshot_buttons_widget.dart';

class PriceAdminPanel extends StatefulWidget {
  const PriceAdminPanel({super.key});

  @override
  State<PriceAdminPanel> createState() => _PriceAdminPanelState();
}

class _PriceAdminPanelState extends State<PriceAdminPanel> {
  List<Map<String, dynamic>> _instruments = [];
  String _searchQuery = '';
  String _sortColumn = 'symbol';
  bool _sortAscending = true;
  bool _isLoading = false;
  DateTime? _globalLastUpdated;

  @override
  void initState() {
    super.initState();
    _loadInstruments();
    _loadGlobalLastUpdated();
  }

  Future<void> _loadInstruments() async {
    setState(() => _isLoading = true);

    // Mock data - replace with actual Supabase calls when available
    await Future.delayed(const Duration(milliseconds: 500));

    _instruments = [
      {
        'id': '1',
        'symbol': 'GP',
        'lastPrice': 302.0,
        'lastUpdatedAt': DateTime.now().subtract(const Duration(hours: 2)),
        'snapshotLabel': 'open',
        'companyName': 'GP Limited',
        'priceChange24h': 5.2,
      },
      {
        'id': '2',
        'symbol': 'BATBC',
        'lastPrice': 525.0,
        'lastUpdatedAt': DateTime.now().subtract(const Duration(hours: 1)),
        'snapshotLabel': 'close',
        'companyName': 'BATBC Corp',
        'priceChange24h': -2.8,
      },
      {
        'id': '3',
        'symbol': 'SQURPHARMA',
        'lastPrice': 252.0,
        'lastUpdatedAt': DateTime.now().subtract(const Duration(minutes: 30)),
        'snapshotLabel': 'manual',
        'companyName': 'Square Pharma',
        'priceChange24h': 8.5,
      },
      {
        'id': '4',
        'symbol': 'UTTARAFUND',
        'lastPrice': 16.3,
        'lastUpdatedAt': DateTime.now().subtract(const Duration(hours: 3)),
        'snapshotLabel': 'open',
        'companyName': 'Uttara Fund',
        'priceChange24h': 1.2,
      },
      {
        'id': '5',
        'symbol': 'IDLCMF',
        'lastPrice': 12.6,
        'lastUpdatedAt': DateTime.now().subtract(const Duration(hours: 4)),
        'snapshotLabel': 'close',
        'companyName': 'IDLC Mutual Fund',
        'priceChange24h': -0.8,
      },
      {
        'id': '6',
        'symbol': 'XAUBDT',
        'lastPrice': 100450.0,
        'lastUpdatedAt': DateTime.now().subtract(const Duration(minutes: 15)),
        'snapshotLabel': 'manual',
        'companyName': 'Gold BDT',
        'priceChange24h': 125.0,
      },
    ];

    setState(() => _isLoading = false);
  }

  Future<void> _loadGlobalLastUpdated() async {
    // Mock data - replace with actual Supabase call
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() {
      _globalLastUpdated = DateTime.now().subtract(const Duration(minutes: 15));
    });
  }

  List<Map<String, dynamic>> get _filteredInstruments {
    var filtered = _instruments.where((instrument) {
      if (_searchQuery.isEmpty) return true;
      return instrument['symbol']
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          instrument['companyName']
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
    }).toList();

    filtered.sort((a, b) {
      dynamic aValue = a[_sortColumn];
      dynamic bValue = b[_sortColumn];

      if (aValue is String) aValue = aValue.toLowerCase();
      if (bValue is String) bValue = bValue.toLowerCase();

      int comparison = aValue.compareTo(bValue);
      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  void _sortData(String column) {
    setState(() {
      if (_sortColumn == column) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = column;
        _sortAscending = true;
      }
    });
  }

  Future<void> _editInstrumentPrice(Map<String, dynamic> instrument) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => InstrumentEditDialog(instrument: instrument),
    );

    if (result != null) {
      setState(() {
        final index =
            _instruments.indexWhere((item) => item['id'] == result['id']);
        if (index != -1) {
          _instruments[index]['lastPrice'] = result['lastPrice'];
          _instruments[index]['lastUpdatedAt'] = DateTime.now();
          _instruments[index]['snapshotLabel'] = 'manual';
        }
      });

      // Update global last updated time
      await _updateGlobalLastUpdated();

      // Add to price history (mock)
      await _addToPriceHistory(result);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Updated ${result['symbol']} price to ${result['lastPrice']}'),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
    }
  }

  Future<void> _handleCsvUpload(List<Map<String, dynamic>> csvData) async {
    setState(() => _isLoading = true);

    try {
      DateTime maxAsOfTime = DateTime.now();
      int updatedCount = 0;

      for (final row in csvData) {
        final symbol = row['symbol'] as String;
        final price = double.tryParse(row['lastPrice'].toString());
        final asOfISO = row['asOfISO'] as String?;
        final snapshotLabel = row['snapshotLabel'] as String;

        if (price == null) continue;

        final asOfTime = asOfISO != null
            ? DateTime.tryParse(asOfISO) ?? DateTime.now()
            : DateTime.now();

        if (asOfTime.isAfter(maxAsOfTime)) {
          maxAsOfTime = asOfTime;
        }

        final index =
            _instruments.indexWhere((item) => item['symbol'] == symbol);
        if (index != -1) {
          _instruments[index]['lastPrice'] = price;
          _instruments[index]['lastUpdatedAt'] = asOfTime;
          _instruments[index]['snapshotLabel'] = snapshotLabel;
          updatedCount++;

          // Add to price history
          await _addToPriceHistory({
            'id': _instruments[index]['id'],
            'symbol': symbol,
            'lastPrice': price,
            'asOfISO': asOfTime.toIso8601String(),
            'snapshotLabel': snapshotLabel,
          });
        }
      }

      // Update global last updated time
      _globalLastUpdated = maxAsOfTime;
      await _updateGlobalLastUpdated();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully updated $updatedCount instruments'),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing CSV: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addToPriceHistory(Map<String, dynamic> data) async {
    // Mock price history addition - replace with actual Supabase call
    await Future.delayed(const Duration(milliseconds: 100));
    print(
        'Added to price history: ${data['symbol']} - ${data['lastPrice']} - ${data['snapshotLabel']}');
  }

  Future<void> _updateGlobalLastUpdated() async {
    // Mock global last updated update - replace with actual Supabase call
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() {
      _globalLastUpdated = DateTime.now();
    });
  }

  Future<void> _handleRecalculatePL() async {
    setState(() => _isLoading = true);

    try {
      // Mock portfolio P/L recalculation - replace with actual Supabase call
      await Future.delayed(const Duration(seconds: 2));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Successfully recalculated all portfolio P/L'),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error recalculating P/L: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSnapshotApply(String snapshotType) async {
    setState(() => _isLoading = true);

    try {
      // Mock snapshot application - replace with actual storage download and processing
      await Future.delayed(const Duration(seconds: 1));

      final mockSnapshotData = snapshotType == 'open'
          ? [
              {
                'symbol': 'GP',
                'lastPrice': '302',
                'asOfISO': '2025-09-04T04:00:00Z',
                'snapshotLabel': 'open'
              },
              {
                'symbol': 'BATBC',
                'lastPrice': '525',
                'asOfISO': '2025-09-04T04:00:00Z',
                'snapshotLabel': 'open'
              },
              {
                'symbol': 'SQURPHARMA',
                'lastPrice': '252',
                'asOfISO': '2025-09-04T04:00:00Z',
                'snapshotLabel': 'open'
              },
            ]
          : [
              {
                'symbol': 'GP',
                'lastPrice': '305',
                'asOfISO': '2025-09-04T16:00:00Z',
                'snapshotLabel': 'close'
              },
              {
                'symbol': 'BATBC',
                'lastPrice': '528',
                'asOfISO': '2025-09-04T16:00:00Z',
                'snapshotLabel': 'close'
              },
              {
                'symbol': 'SQURPHARMA',
                'lastPrice': '255',
                'asOfISO': '2025-09-04T16:00:00Z',
                'snapshotLabel': 'close'
              },
            ];

      await _handleCsvUpload(mockSnapshotData);
      await _handleRecalculatePL();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Applied ${snapshotType.toUpperCase()} snapshot successfully'),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error applying snapshot: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Price Admin Panel'),
        centerTitle: true,
        actions: [
          GlobalLastUpdatedWidget(
            lastUpdated: _globalLastUpdated,
            onRefresh: _loadGlobalLastUpdated,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search and Controls
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Search Bar
                      TextField(
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                        decoration: InputDecoration(
                          hintText: 'Search instruments...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () =>
                                      setState(() => _searchQuery = ''),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Action Buttons Row
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: CsvUploadWidget(
                              onCsvUploaded: _handleCsvUpload,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: RecalculatePlButton(
                              onPressed: _handleRecalculatePL,
                              isLoading: _isLoading,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Snapshot Buttons
                      SnapshotButtonsWidget(
                        onSnapshotApply: _handleSnapshotApply,
                        isLoading: _isLoading,
                      ),
                    ],
                  ),
                ),

                // Data Table
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DataTable2(
                      columnSpacing: 12,
                      horizontalMargin: 12,
                      minWidth: 800,
                      sortColumnIndex: _getSortColumnIndex(),
                      sortAscending: _sortAscending,
                      columns: [
                        DataColumn2(
                          label: const Text('Symbol'),
                          size: ColumnSize.S,
                          onSort: (columnIndex, ascending) =>
                              _sortData('symbol'),
                        ),
                        DataColumn2(
                          label: const Text('Company'),
                          size: ColumnSize.L,
                          onSort: (columnIndex, ascending) =>
                              _sortData('companyName'),
                        ),
                        DataColumn2(
                          label: const Text('Last Price'),
                          size: ColumnSize.M,
                          numeric: true,
                          onSort: (columnIndex, ascending) =>
                              _sortData('lastPrice'),
                        ),
                        DataColumn2(
                          label: const Text('Change (24h)'),
                          size: ColumnSize.S,
                          numeric: true,
                          onSort: (columnIndex, ascending) =>
                              _sortData('priceChange24h'),
                        ),
                        const DataColumn2(
                          label: Text('Last Updated'),
                          size: ColumnSize.M,
                        ),
                        const DataColumn2(
                          label: Text('Source'),
                          size: ColumnSize.S,
                        ),
                        const DataColumn2(
                          label: Text('Actions'),
                          size: ColumnSize.S,
                        ),
                      ],
                      rows: _filteredInstruments.map((instrument) {
                        final priceChange =
                            instrument['priceChange24h'] as double;
                        final changeColor = priceChange >= 0
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.error;

                        return DataRow2(
                          cells: [
                            DataCell(
                              Text(
                                instrument['symbol'],
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                            DataCell(Text(instrument['companyName'])),
                            DataCell(
                              Text(
                                '\$${instrument['lastPrice'].toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                            DataCell(
                              Text(
                                '${priceChange >= 0 ? '+' : ''}${priceChange.toStringAsFixed(2)}',
                                style: TextStyle(color: changeColor),
                              ),
                            ),
                            DataCell(
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${(instrument['lastUpdatedAt'] as DateTime).hour.toString().padLeft(2, '0')}:${(instrument['lastUpdatedAt'] as DateTime).minute.toString().padLeft(2, '0')}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Text(
                                    '${(instrument['lastUpdatedAt'] as DateTime).day}/${(instrument['lastUpdatedAt'] as DateTime).month}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.color
                                              ?.withAlpha(179),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getSnapshotColor(
                                      instrument['snapshotLabel']),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  instrument['snapshotLabel'].toUpperCase(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                            ),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () =>
                                    _editInstrumentPrice(instrument),
                                tooltip: 'Edit Price',
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
    );
  }

  int _getSortColumnIndex() {
    switch (_sortColumn) {
      case 'symbol':
        return 0;
      case 'companyName':
        return 1;
      case 'lastPrice':
        return 2;
      case 'priceChange24h':
        return 3;
      default:
        return 0;
    }
  }

  Color _getSnapshotColor(String snapshotLabel) {
    switch (snapshotLabel.toLowerCase()) {
      case 'open':
        return Colors.green;
      case 'close':
        return Colors.blue;
      case 'manual':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

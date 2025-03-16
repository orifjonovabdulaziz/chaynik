import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../provider/uzum_provider.dart';

class UzumScreen extends ConsumerStatefulWidget {
  final int marketId;
  final String marketName;

  const UzumScreen({
    Key? key,
    required this.marketId,
    required this.marketName,
  }) : super(key: key);

  @override
  ConsumerState<UzumScreen> createState() => _UzumScreenState();
}

class _UzumScreenState extends ConsumerState<UzumScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(uzumProvider.notifier).getTodayStats(widget.marketId);
    });
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            primaryColor: Theme.of(context).primaryColor,
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });

      ref.read(uzumProvider.notifier).getStatsByDateRange(
        marketId: widget.marketId,
        startDate: picked.start,
        endDate: picked.end,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(uzumProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/market'),
        ),
        title: Text(widget.marketName),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _selectDateRange,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (_startDate != null && _endDate != null) {
                ref.read(uzumProvider.notifier).getStatsByDateRange(
                  marketId: widget.marketId,
                  startDate: _startDate!,
                  endDate: _endDate!,
                );
              } else {
                ref.read(uzumProvider.notifier).getTodayStats(widget.marketId);
              }
            },
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              state.error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(uzumProvider.notifier).getTodayStats(widget.marketId);
              },
              child: const Text('Повторить'),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: () async {
          if (_startDate != null && _endDate != null) {
            await ref.read(uzumProvider.notifier).getStatsByDateRange(
              marketId: widget.marketId,
              startDate: _startDate!,
              endDate: _endDate!,
            );
          } else {
            await ref.read(uzumProvider.notifier).getTodayStats(widget.marketId);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Период:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _startDate != null && _endDate != null
                            ? '${_formatDate(_startDate!)} - ${_formatDate(_endDate!)}'
                            : 'Сегодня',
                      ),
                      const Divider(height: 32),
                      _StatisticRow(
                        title: 'Количество продаж:',
                        value: '${state.count}',
                      ),
                      const SizedBox(height: 16),
                      _StatisticRow(
                        title: 'Общая прибыль:',
                        value: '${_formatMoney(state.totalProfit.toDouble())} сум',
                      ),
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _formatMoney(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
    );
  }
}

class _StatisticRow extends StatelessWidget {
  final String title;
  final String value;

  const _StatisticRow({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
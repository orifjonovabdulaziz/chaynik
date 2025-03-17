import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../components/shared/drawer.dart';
import '../models/sold.dart';
import '../provider/sold_history_provider.dart';

class SoldHistoryScreen extends ConsumerStatefulWidget {
  const SoldHistoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SoldHistoryScreen> createState() => _SoldHistoryScreenState();
}

class _SoldHistoryScreenState extends ConsumerState<SoldHistoryScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    // Загружаем историю при открытии экрана
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(soldHistoryProvider.notifier).loadSales();
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });

      if (_startDate != null && _endDate != null) {
        ref.read(soldHistoryProvider.notifier).filterByDateRange(
              _startDate!.toIso8601String(),
              _endDate!.toIso8601String(),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(soldHistoryProvider);
    final totalSales = ref.watch(totalSalesProvider);
    final totalPaid = ref.watch(totalPaidProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('История продаж'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () =>
                Scaffold.of(context).openDrawer(), // Открывает Drawer
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(soldHistoryProvider.notifier).refreshData(),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Фильтры
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                ),
              ],
            ),
            child: Column(
              children: [
                // Период
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(_startDate == null
                            ? 'Начальная дата'
                            : DateFormat('dd.MM.yyyy').format(_startDate!)),
                        onPressed: () => _selectDate(context, true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(_endDate == null
                            ? 'Конечная дата'
                            : DateFormat('dd.MM.yyyy').format(_endDate!)),
                        onPressed: () => _selectDate(context, false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Кнопка сброса фильтров
                if (_startDate != null ||
                    _endDate != null ||
                    historyState.selectedClientId != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                      });
                      ref.read(soldHistoryProvider.notifier).clearFilters();
                    },
                    child: const Text('Сбросить фильтры'),
                  ),
              ],
            ),
          ),

          // Статистика
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text(
                      'Всего продаж',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${NumberFormat('#,##0', 'en_EN').format(totalSales)} UZS',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      'Оплачено',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${NumberFormat('#,##0', 'en_EN').format(totalPaid)} UZS',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Список продаж
          Expanded(
            child: historyState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : historyState.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              historyState.error!,
                              style: const TextStyle(color: Colors.orange),
                            ),
                            TextButton(
                              onPressed: () => ref
                                  .read(soldHistoryProvider.notifier)
                                  .refreshData(),
                              child: const Text('Повторить'),
                            ),
                          ],
                        ),
                      )
                    : historyState.sales.isEmpty
                        ? const Center(child: Text('Нет данных'))
                        : RefreshIndicator(
                            onRefresh: () => ref
                                .read(soldHistoryProvider.notifier)
                                .refreshData(),
                            child: ListView.separated(
                              reverse: true,
                              padding: const EdgeInsets.all(16),
                              itemCount: historyState.sales.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 32),
                              itemBuilder: (context, index) {
                                final sale = historyState.sales[index];
                                return _SaleCard(sale: sale);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _SaleCard extends ConsumerWidget {
  final Sold sale;

  const _SaleCard({required this.sale});

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'Дата не указана';
    }

    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd.MM.yyyy HH:mm').format(date);
    } catch (e) {
      print('❌ Ошибка форматирования даты: $e');
      return 'Некорректная дата';
    }
  }

  double calculateTotal(List<SoldItem> items) {
    return items.fold(
      0.0,
      (sum, item) =>
          sum + (double.tryParse(item.price.toString()) ?? 0) * item.quantity,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clients = ref.watch(clientsProvider);
    final products = ref.watch(productsProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                clients[sale.client] ?? 'Клиент #${sale.client}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                sale.formattedCreatedAt,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Список товаров
          ...sale.outcome.map((item) {
            final product = products[item.product];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  // Изображение товара
                  if (product?.imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product!.imageUrl!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported),
                    ),
                  const SizedBox(width: 12),

                  // Информация о товаре
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product?.title ?? 'Товар #${item.product}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${item.quantity} шт × ${NumberFormat('#,##0', 'en_EN').format(item.price)} UZS',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Сумма за товар
                  Text(
                    '${NumberFormat('#,##0', 'en_EN').format(item.quantity * (double.tryParse(item.price.toString()) ?? 0))} UZS',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

          const Divider(height: 24),

          // Итоги
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Итого: ${NumberFormat('#,##0', 'en_EN').format(calculateTotal(sale.outcome))} UZS',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              Text(
                'Оплачено: ${NumberFormat('#,##0', 'en_EN').format(sale.paid)} UZS',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

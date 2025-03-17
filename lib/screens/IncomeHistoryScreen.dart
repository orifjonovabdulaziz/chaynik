import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../components/shared/drawer.dart';
import '../models/income.dart';
import '../provider/income_history_provider.dart';
import '../provider/product_provider.dart';
import '../provider/sold_history_provider.dart';

class IncomeHistoryScreen extends ConsumerStatefulWidget {
  const IncomeHistoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<IncomeHistoryScreen> createState() => _IncomeHistoryScreenState();
}

class _IncomeHistoryScreenState extends ConsumerState<IncomeHistoryScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(incomeHistoryProvider.notifier).loadIncomes();
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
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
        ref.read(incomeHistoryProvider.notifier).loadIncomes(
          startDate: _startDate!.toIso8601String(),
          endDate: _endDate!.toIso8601String(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(incomeHistoryProvider);
    final totalItems = state.incomes.fold(
      0,
          (sum, income) => sum + income.items.fold(
        0,
            (itemSum, item) => itemSum + item.quantity,
      ),
    );
    final totalAmount = state.incomes.fold(
      0.0,
          (sum, income) => sum + income.items.fold(
        0.0,
            (itemSum, item) =>
        itemSum + (double.tryParse(item.formattedPrice) ?? 0) * item.quantity,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('История приходов'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(incomeHistoryProvider.notifier).refreshIncomes(),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Фильтры по дате
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
                if (_startDate != null || _endDate != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                      });
                      ref.read(incomeHistoryProvider.notifier).loadIncomes();
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
                      'Всего товаров',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalItems шт',
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
                      'На сумму',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${totalAmount.toStringAsFixed(2)} \$',
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

          // Список приходов
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  TextButton(
                    onPressed: () => ref
                        .read(incomeHistoryProvider.notifier)
                        .refreshIncomes(),
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            )
                : state.incomes.isEmpty
                ? const Center(child: Text('Нет данных'))
                : RefreshIndicator(
              onRefresh: () => ref
                  .read(incomeHistoryProvider.notifier)
                  .refreshIncomes(),
              child: ListView.separated(
    reverse: true,
                padding: const EdgeInsets.all(16),
                itemCount: state.incomes.length,
                separatorBuilder: (context, index) =>
                const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final income = state.incomes[index];
                  return _IncomeCard(income: income);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IncomeCard extends ConsumerWidget {
  final Income income;

  const _IncomeCard({required this.income});



  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          // Дата прихода
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Приход #${income.id ?? "Новый"}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                income.formattedCreatedAt,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Список товаров
          // Список товаров
          ...income.items.map((item) {
            final product = products[item.product]; // Получаем продукт из Map по ID
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product == null ? 'Удаленный товар' : 'Название товара',
                          style: TextStyle(
                            color: item.product == null ? Colors.grey : Colors.black,
                            decoration: item.product == null ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        Text(
                          '${item.quantity} шт × ${item.formattedPrice} \$',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${(item.quantity * (double.tryParse(item.formattedPrice) ?? 0)).toStringAsFixed(2)} \$',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

          const Divider(height: 24),

          // Итоговая сумма
          Text(
            'Итого: ${income.items.fold(
              0.0,
                  (sum, item) =>
              sum + (double.tryParse(item.formattedPrice) ?? 0) * item.quantity,
            ).toStringAsFixed(2)} \$',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
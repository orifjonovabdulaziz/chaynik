import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/sold.dart';
import '../../provider/client_provider.dart';
import '../../provider/product_provider.dart';
import '../../provider/sold_provider.dart';
import '../../repositories/sold_repository.dart';

void showPayBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Consumer(
        builder: (context, ref, child) {
          return _PayBottomSheetContent(
            ref: ref,
          );
        },
      );
    },
  );
}

class _PayBottomSheetContent extends StatefulWidget {
  final WidgetRef ref;

  const _PayBottomSheetContent({
    Key? key,
    required this.ref,
  }) : super(key: key);

  @override
  State<_PayBottomSheetContent> createState() => _PayBottomSheetContentState();
}

class _PayBottomSheetContentState extends State<_PayBottomSheetContent> {
  late final TextEditingController _amountController;
  final SoldRepository _soldRepository = SoldRepository();

  Future<void> _createSale() async {
    final saleState = widget.ref.read(soldProvider);

    final List<SoldItem> soldItems = saleState.products
        .map((product) => SoldItem(
              product: product.id,
              quantity: product.quantity,
              price: product.price,
            ))
        .toList();
    try {
      final saleState = widget.ref.read(soldProvider);
      await _soldRepository.createSale(
        saleState.client!.id,
        saleState.paidAmount,
        soldItems,
      );

      // Очищаем состояние после успешного создания продажи
      widget.ref.read(soldProvider.notifier).clear();
      widget.ref.read(productProvider.notifier).fetchProducts();
      widget.ref.read(clientProvider.notifier).fetchClients();

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при создании продажи: ${e.toString()}'),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final saleState = widget.ref.read(soldProvider);
    _amountController = TextEditingController(
      text: saleState.paidAmount.toString(),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _updatePayment() {
    try {
      final amount = double.parse(_amountController.text);
      widget.ref.read(soldProvider.notifier).state =
          widget.ref.read(soldProvider.notifier).state.copyWith(
                paidAmount: amount,
              );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пожалуйста, введите корректную сумму'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer(
                builder: (context, ref, child) {
                  final saleState = ref.watch(soldProvider);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'К оплате:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${NumberFormat('#,###').format(saleState.totalAmount)} UZS',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextFormField(
                        controller: _amountController,
                        textAlign: TextAlign.end,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            _updatePayment();
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'UZS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Consumer(
                builder: (context, ref, child) {
                  final saleState = ref.watch(soldProvider);
                  final remainingAmount =
                      saleState.totalAmount - saleState.paidAmount;

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Оплачено:',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '${NumberFormat('#,###').format(saleState.paidAmount)} UZS',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Остаток:',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '${NumberFormat('#,###').format(remainingAmount)} UZS',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Назад'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Consumer(
                      builder: (context, ref, child) {
                        final saleState = ref.watch(soldProvider);
                        final remainingAmount =
                            saleState.totalAmount - saleState.paidAmount;

                        return ElevatedButton(
                          onPressed: () async {
                            _updatePayment();
                            await _createSale();
                            context.go("/sold");
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Подтвердить',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

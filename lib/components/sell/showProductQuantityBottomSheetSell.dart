import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/product.dart';
import '../../models/selected_product.dart';
import '../../provider/sold_provider.dart';

void showProductQuantityBottomSheetSell(BuildContext context, Product product) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Consumer(
        builder: (context, ref, child) {
          final existingProduct = ref.watch(soldProvider).products
              .firstWhere((p) => p.id == product.id,
              orElse: () => SelectedProduct(
                id: product.id,
                title: product.title,
                price: product.price,
                quantity: 0,
                total: 0,
                imageUrl: product.imageUrl,));

          return _BottomSheetContent(
            product: product,
            existingProduct: existingProduct,
            ref: ref,
          );
        },
      );
    },
  );
}

class _BottomSheetContent extends StatefulWidget {
  final Product product;
  final SelectedProduct existingProduct;
  final WidgetRef ref;



  const _BottomSheetContent({
    Key? key,
    required this.product,
    required this.existingProduct,
    required this.ref,
  }) : super(key: key);

  @override
  State<_BottomSheetContent> createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<_BottomSheetContent> {
  late final TextEditingController _priceController;
  late final TextEditingController _quantityController;
  double _totalAmount = 0;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.existingProduct.quantity > 0
          ? widget.existingProduct.price.toString()
          : widget.product.price.toString(),
    );
    _quantityController = TextEditingController(
      text: widget.existingProduct.quantity > 0
          ? widget.existingProduct.quantity.toString()
          : '1',
    );
    updateTotal();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void validateQuantity(String value) {
    final quantity = int.tryParse(value) ?? 0;
    if (quantity > widget.product.quantity) {
      setState(() {
        _errorText = 'На складе только ${widget.product.quantity} шт';
      });
    } else if (quantity <= 0) {
      setState(() {
        _errorText = 'Количество должно быть больше 0';
      });
    } else {
      setState(() {
        _errorText = null;
      });
    }
  }

  void updateTotal() {
    try {
      final quantity = int.parse(_quantityController.text);
      final price = double.parse(_priceController.text);
      validateQuantity(_quantityController.text);
      setState(() {
        _totalAmount = quantity * price;
      });
    } catch (e) {
      setState(() {
        _totalAmount = 0;
      });
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
              // Заголовок с крестиком
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.product.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Количество в наличии
              Text(
                'В наличии: ${widget.product.quantity} шт',
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              // Выбор количества
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey[300]!,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('шт', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 16),

                  // Кнопка минус
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          final currentValue = int.tryParse(_quantityController.text) ?? 0;
                          if (currentValue > 1) {
                            setState(() {
                              _quantityController.text = (currentValue - 1).toString();
                              updateTotal();
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.remove,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Поле ввода количества
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          height: 44,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _errorText != null ? Colors.red : Colors.grey[300]!,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: TextFormField(
                            controller: _quantityController,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              updateTotal();
                            },
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (_errorText != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 8),
                            child: Text(
                              _errorText!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Кнопка плюс
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          final currentValue = int.tryParse(_quantityController.text) ?? 0;
                          if (currentValue < widget.product.quantity) {
                            setState(() {
                              _quantityController.text = (currentValue + 1).toString();
                              updateTotal();
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.add,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Выбор цены
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Стандартная',
                        style: TextStyle(fontSize: 20)),
                  ),
                  Expanded(
                    child: Container(
                      height: 44,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: TextFormField(
                        controller: _priceController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          updateTotal();
                        },
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    'UZS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Итого
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Итого',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        _totalAmount.toStringAsFixed(2),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'UZS',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Кнопки действий
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        if (widget.existingProduct.quantity > 0) {
                          widget.ref.read(soldProvider.notifier)
                              .removeProduct(widget.product.id);
                        }
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        widget.existingProduct.quantity > 0 ? 'Удалить' : 'Отмена',
                        style: TextStyle(
                          color: widget.existingProduct.quantity > 0
                              ? Colors.red
                              : Colors.grey[600],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _errorText == null ? () {
                        final quantity = int.tryParse(_quantityController.text) ?? 0;
                        final price = double.tryParse(_priceController.text) ?? 0.0;

                        if (quantity > 0 && quantity <= widget.product.quantity && price > 0) {
                          widget.ref.read(soldProvider.notifier).addOrUpdateProduct(
                            SelectedProduct(
                              id: widget.product.id,
                              title: widget.product.title,
                              price: price,
                              quantity: quantity,
                              total: price * quantity,
                              imageUrl: widget.product.imageUrl,
                            ),
                          );
                          Navigator.pop(context);
                        }
                      } : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: _errorText == null && _totalAmount > 0
                            ? Colors.blue
                            : Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        widget.existingProduct.quantity > 0 ? 'Обновить' : 'Добавить',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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

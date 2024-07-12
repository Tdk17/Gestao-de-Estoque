class Product {
  int? id;
  String name;
  double price;
  int quantity;
  String? barcode; // Adicionando campo para código de barras
  String? imagePath;

  Product(
      {this.id,
      required this.name,
      required this.price,
      required this.quantity,
      this.barcode,
      this.imagePath});

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'price': price,
      'quantity': quantity,
      'barcode': barcode, // Incluindo no mapa
      'imagePath': imagePath,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      quantity: map['quantity'],
      barcode: map['barcode'], // Incluindo no factory
      imagePath: map['imagePath'],
    );
  }
}

class PriceHistory {
  final String date;
  final double price;
  final String supplier;

  PriceHistory({
    required this.date,
    required this.price,
    required this.supplier,
  });
}

class SupplierPrice {
  final String supplier;
  final double price;

  SupplierPrice({
    required this.supplier,
    required this.price,
  });
}

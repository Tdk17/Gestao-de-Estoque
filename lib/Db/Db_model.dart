import 'package:gestaoestoque/model/produt_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper.internal();

  Database? _db;

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'products.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  void _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE Product(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, price REAL, quantity INTEGER, barcode TEXT, imagePath TEXT)',
    );
  }

  Future<int> saveProduct(Product product) async {
    final dbClient = await db;
    return await dbClient!.insert('Product', product.toMap());
  }

  Future<List<Product>> getProducts() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> result = await dbClient!.query('Product');
    return result.map((data) => Product.fromMap(data)).toList();
  }

  Future<Map<String, dynamic>> getStockSummary() async {
    final dbClient = await db;
    final totalItemsResult =
        await dbClient!.rawQuery('SELECT COUNT(*) as total FROM Product');
    final outOfStockItemsResult = await dbClient.rawQuery(
        'SELECT COUNT(*) as outOfStock FROM Product WHERE quantity = 0');
    final lastUpdateResult =
        await dbClient.rawQuery('SELECT MAX(id) as lastUpdate FROM Product');

    return {
      'totalItems': totalItemsResult.first['total'],
      'outOfStockItems': outOfStockItemsResult.first['outOfStock'],
      'lastUpdate': lastUpdateResult.first['lastUpdate'],
    };
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    final dbClient = await db;
    final List<Map<String, dynamic>> result = await dbClient!
        .query('Product', where: 'barcode = ?', whereArgs: [barcode]);
    if (result.isNotEmpty) {
      return Product.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateProduct(Product product) async {
    final dbClient = await db;
    return await dbClient!.update(
      'Product',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  // Adicionando o método updateProductQuantity
  Future<int> updateProductQuantity(int id, int newQuantity) async {
    final dbClient = await db;
    return await dbClient!.update(
      'Product',
      {'quantity': newQuantity},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

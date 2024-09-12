class G2SStorage {
  final String? id;
  final String projectID, name, description;
  final num criticalStock, stored, destocking, stock;
  final bool warning;
  final String unit;
  final num unitPrice;
  final DateTime created, modified;

  const G2SStorage({
    this.id,
    required this.projectID,
    required this.name,
    required this.description,
    this.criticalStock = 0,
    this.stored = 0,
    this.destocking = 0,
    this.stock = 0,
    this.warning = false,
    required this.unit,
    this.unitPrice = 1,
    required this.created,
    required this.modified,
  });

  static G2SStorage convertToG2SStorage({required Map<String, dynamic> data}) {
    return G2SStorage(
      id: data['id'],
      projectID: data['projectID'],
      name: data['name'],
      description: data['description'],
      criticalStock: data['criticalStock'],
      stored: data['stored'],
      destocking: data['destocking'],
      stock: data['stock'],
      warning: data['warning'],
      unit: data['unit'],
      unitPrice: data['unitPrice'],
      created: DateTime.parse(data['created']),
      modified: DateTime.parse(data['modified']),
    );
  }

  static Map<String, dynamic> convertToMap({required G2SStorage g2sStorage}) {
    return {
      if (g2sStorage.id is String) 'id': g2sStorage.id,
      'projectID': g2sStorage.projectID,
      'name': g2sStorage.name,
      'description': g2sStorage.description,
      'criticalStock': g2sStorage.criticalStock,
      'stored': g2sStorage.stored,
      'destocking': g2sStorage.destocking,
      'stock': g2sStorage.stock,
      'warning': g2sStorage.warning,
      'unit': g2sStorage.unit,
      'unitPrice': g2sStorage.unitPrice,
      'created': g2sStorage.created.toString(),
      'modified': g2sStorage.modified.toString(),
    };
  }
}

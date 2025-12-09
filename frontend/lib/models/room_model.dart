class Room {
  final int id;
  final String type;
  final double price;
  final int capacity;
  final String? imageUrl;
  final bool isAvailable;

  Room({
    required this.id,
    required this.type,
    required this.price,
    required this.capacity,
    this.imageUrl,
    required this.isAvailable,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      type: json['type'],
      price: (json['price'] is int) 
          ? (json['price'] as int).toDouble() 
          : json['price'],
      capacity: json['capacity'],
      imageUrl: json['imageUrl'],
      isAvailable: json['isAvailable'] ?? true,
    );
  }
}
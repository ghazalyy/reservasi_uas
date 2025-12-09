import 'room_model.dart'; 

class Hotel {
  final int id;
  final String name;
  final String address;
  final String description;
  final String? imageUrl;
  final double rating;
  final List<Room>? rooms; 

  Hotel({
    required this.id,
    required this.name,
    required this.address,
    required this.description,
    this.imageUrl,
    required this.rating,
    this.rooms, 
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    List<Room>? parsedRooms;
    if (json['rooms'] != null) {
      parsedRooms = (json['rooms'] as List)
          .map((roomJson) => Room.fromJson(roomJson))
          .toList();
    }

    return Hotel(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      rating: (json['rating'] is int) 
          ? (json['rating'] as int).toDouble() 
          : json['rating'],
      rooms: parsedRooms,
    );
  }
}
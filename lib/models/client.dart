import 'dart:ffi';

class Client {
  final int id;
  final String created_at;
  final String updated_at;
  final String full_name;
  final String content;
  final double debt;

  Client({
    required this.id,
    required this.created_at,
    required this.updated_at,
    required this.full_name,
    required this.content,
    required this.debt,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      created_at: json['created_at'],
      updated_at: json['updated_at'],
      full_name: json['full_name'],
      content: json['content'],
      debt: double.parse(json['debt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "created_at": created_at,
      "updated_at": updated_at,
      "full_name": full_name,
      "content": content,
      "debt": debt.toString(),
    };
  }
}

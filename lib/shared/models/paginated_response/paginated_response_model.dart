class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.data,
    required this.count,
    this.json = const {},
  });

  factory PaginatedResponse.fromJson(Map<String, dynamic> json) => PaginatedResponse<T>(
        data: json['data'] as List<T>,
        count: json['count'] as int,
        json: json,
      );

  final List<T> data;
  final int count;
  final Map<String, dynamic> json;

  Map<String, dynamic> toJson() => {
        'data': data,
        'count': count,
        'json': json,
      };

  @override
  String toString() {
    return 'PaginatedResponse(data: $data, count: $count)';
  }

  static PaginatedResponse<T> empty<T>() => PaginatedResponse(data: <T>[], count: 0);
}

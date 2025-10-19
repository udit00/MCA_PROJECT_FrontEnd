class CommonApiResponse {
  final int status;
  final dynamic data;
  final String? error;

  const CommonApiResponse({
    required this.status,
    this.data,
    this.error,
  });

  factory CommonApiResponse.fromJson(Map<String, dynamic> json) {
    return CommonApiResponse(
      status: json['status'] as int,
      data: json['data'],
      error: json['error'] as String?,
    );
  }

  /// Returns true if the response has an error or the status code is not in the 2xx range.
  bool get hasError => error != null || (status < 200 || status >= 300);
}

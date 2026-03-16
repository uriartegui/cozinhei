class UnsplashResponse {
  final List<UnsplashPhoto> results;
  UnsplashResponse({required this.results});
  factory UnsplashResponse.fromJson(Map<String, dynamic> json) => UnsplashResponse(
    results: (json['results'] as List).map((p) => UnsplashPhoto.fromJson(p)).toList(),
  );
}

class UnsplashPhoto {
  final UnsplashUrls urls;
  UnsplashPhoto({required this.urls});
  factory UnsplashPhoto.fromJson(Map<String, dynamic> json) => UnsplashPhoto(
    urls: UnsplashUrls.fromJson(json['urls']),
  );
}

class UnsplashUrls {
  final String small;
  final String regular;
  UnsplashUrls({required this.small, required this.regular});
  factory UnsplashUrls.fromJson(Map<String, dynamic> json) => UnsplashUrls(
    small: json['small'],
    regular: json['regular'],
  );
}

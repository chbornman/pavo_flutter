/// Flutter best practice: Use immutable data classes with const constructors
/// and proper equality/hashCode implementations

/// Generic pagination parameters matching Pavo web patterns
class PaginationParams {
  final int page;
  final int limit;
  final String? sortBy;
  final String? filter;
  final Map<String, dynamic>? additionalParams;

  const PaginationParams({
    this.page = 1,
    this.limit = 50,
    this.sortBy,
    this.filter,
    this.additionalParams,
  });

  /// Flutter pattern: copyWith for immutable updates
  PaginationParams copyWith({
    int? page,
    int? limit,
    String? sortBy,
    String? filter,
    Map<String, dynamic>? additionalParams,
  }) {
    return PaginationParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      sortBy: sortBy ?? this.sortBy,
      filter: filter ?? this.filter,
      additionalParams: additionalParams ?? this.additionalParams,
    );
  }

  /// Convert to query parameters for API calls
  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (sortBy != null) params['sortBy'] = sortBy;
    if (filter != null) params['filter'] = filter;
    if (additionalParams != null) params.addAll(additionalParams!);

    return params;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaginationParams &&
        other.page == page &&
        other.limit == limit &&
        other.sortBy == sortBy &&
        other.filter == filter;
  }

  @override
  int get hashCode =>
      page.hashCode ^
      limit.hashCode ^
      sortBy.hashCode ^
      filter.hashCode;
}

/// Generic paginated response matching Pavo web structure
/// Using generics for type safety - a key Flutter best practice
class PaginatedResponse<T> {
  final List<T> items;
  final bool hasMore;
  final int totalCount;
  final int currentPage;
  final String? error;

  const PaginatedResponse({
    required this.items,
    required this.hasMore,
    required this.totalCount,
    this.currentPage = 1,
    this.error,
  });

  /// Check if the response is successful
  bool get isSuccess => error == null;

  /// Check if the response has error
  bool get hasError => error != null;

  /// Check if the response is empty
  bool get isEmpty => items.isEmpty;

  /// Factory constructor for empty response
  factory PaginatedResponse.empty() {
    return PaginatedResponse<T>(
      items: [],
      hasMore: false,
      totalCount: 0,
    );
  }

  /// Factory constructor for error response
  factory PaginatedResponse.error(String error) {
    return PaginatedResponse<T>(
      items: [],
      hasMore: false,
      totalCount: 0,
      error: error,
    );
  }

  /// Flutter pattern: copyWith for immutable updates
  PaginatedResponse<T> copyWith({
    List<T>? items,
    bool? hasMore,
    int? totalCount,
    int? currentPage,
    String? error,
  }) {
    return PaginatedResponse<T>(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      error: error ?? this.error,
    );
  }

  /// Merge with another response (useful for infinite scroll)
  PaginatedResponse<T> merge(PaginatedResponse<T> other) {
    return PaginatedResponse<T>(
      items: [...items, ...other.items],
      hasMore: other.hasMore,
      totalCount: other.totalCount,
      currentPage: other.currentPage,
      error: other.error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaginatedResponse<T> &&
        other.items == items &&
        other.hasMore == hasMore &&
        other.totalCount == totalCount &&
        other.currentPage == currentPage &&
        other.error == error;
  }

  @override
  int get hashCode =>
      items.hashCode ^
      hasMore.hashCode ^
      totalCount.hashCode ^
      currentPage.hashCode ^
      error.hashCode;
}

/// State enum for pagination status
/// Flutter best practice: Use enums for finite state representation
enum PaginationStatus {
  initial,
  loading,
  loadingMore,
  success,
  error,
  empty,
}

/// Complete pagination state for state management
/// This can be used with Riverpod, Bloc, or any state management solution
class PaginationState<T> {
  final List<T> items;
  final PaginationStatus status;
  final bool hasMore;
  final int currentPage;
  final String? error;

  const PaginationState({
    this.items = const [],
    this.status = PaginationStatus.initial,
    this.hasMore = true,
    this.currentPage = 1,
    this.error,
  });

  bool get isLoading => status == PaginationStatus.loading;
  bool get isLoadingMore => status == PaginationStatus.loadingMore;
  bool get hasError => status == PaginationStatus.error;
  bool get isEmpty => status == PaginationStatus.empty;
  bool get isSuccess => status == PaginationStatus.success;

  PaginationState<T> copyWith({
    List<T>? items,
    PaginationStatus? status,
    bool? hasMore,
    int? currentPage,
    String? error,
  }) {
    return PaginationState<T>(
      items: items ?? this.items,
      status: status ?? this.status,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error ?? this.error,
    );
  }
}
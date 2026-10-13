/// A business rule was broken (e.g. overpayment, a second active tenancy on
/// a unit). [code] is stable for programmatic checks; [message] is for
/// people.
class DomainException implements Exception {
  const DomainException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'DomainException($code): $message';
}

/// A record looked up by ID for an update did not exist. Plain lookups
/// return null instead.
class RecordNotFoundException extends DomainException {
  RecordNotFoundException(String type, String id)
    : super('not-found', '$type "$id" was not found');
}

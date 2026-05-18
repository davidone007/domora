import 'package:dartz/dartz.dart';
import 'package:domora/core/error/failures.dart';
import '../entities/address_suggestion.dart';
import '../repo/address_repository.dart';

class AutocompleteAddressUseCase {
  final AddressRepository repository;

  AutocompleteAddressUseCase(this.repository);

  Future<Either<Failure, List<AddressSuggestion>>> call(String query) {
    return repository.autocomplete(query);
  }
}

import 'package:fpdart/fpdart.dart';
import 'package:todist/core/failure.dart';
import 'package:todist/core/response_data.dart';


typedef FutureEitherVoid = Future<Either<Failure, void>>;
typedef FutureEitherString<T> = Future<Either<Failure<T>, String>>;
typedef FutureEither<T> = Future<Either<Failure<T>, T>>;
typedef FutureResponse<T> = FutureEither<ResponseData<T>>;

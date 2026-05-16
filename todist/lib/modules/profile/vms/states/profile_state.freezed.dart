// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ProfileState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(UserModel user) updated,
    required TResult Function() updating,
    required TResult Function(String message) updateError,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(UserModel user)? updated,
    TResult? Function()? updating,
    TResult? Function(String message)? updateError,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(UserModel user)? updated,
    TResult Function()? updating,
    TResult Function(String message)? updateError,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(IdleProfileState value) idle,
    required TResult Function(UpdatedProfile value) updated,
    required TResult Function(UpdatingProfile value) updating,
    required TResult Function(UpdateErrorProfile value) updateError,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(IdleProfileState value)? idle,
    TResult? Function(UpdatedProfile value)? updated,
    TResult? Function(UpdatingProfile value)? updating,
    TResult? Function(UpdateErrorProfile value)? updateError,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(IdleProfileState value)? idle,
    TResult Function(UpdatedProfile value)? updated,
    TResult Function(UpdatingProfile value)? updating,
    TResult Function(UpdateErrorProfile value)? updateError,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileStateCopyWith<$Res> {
  factory $ProfileStateCopyWith(
          ProfileState value, $Res Function(ProfileState) then) =
      _$ProfileStateCopyWithImpl<$Res, ProfileState>;
}

/// @nodoc
class _$ProfileStateCopyWithImpl<$Res, $Val extends ProfileState>
    implements $ProfileStateCopyWith<$Res> {
  _$ProfileStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$IdleProfileStateImplCopyWith<$Res> {
  factory _$$IdleProfileStateImplCopyWith(_$IdleProfileStateImpl value,
          $Res Function(_$IdleProfileStateImpl) then) =
      __$$IdleProfileStateImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$IdleProfileStateImplCopyWithImpl<$Res>
    extends _$ProfileStateCopyWithImpl<$Res, _$IdleProfileStateImpl>
    implements _$$IdleProfileStateImplCopyWith<$Res> {
  __$$IdleProfileStateImplCopyWithImpl(_$IdleProfileStateImpl _value,
      $Res Function(_$IdleProfileStateImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$IdleProfileStateImpl implements IdleProfileState {
  _$IdleProfileStateImpl();

  @override
  String toString() {
    return 'ProfileState.idle()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$IdleProfileStateImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(UserModel user) updated,
    required TResult Function() updating,
    required TResult Function(String message) updateError,
  }) {
    return idle();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(UserModel user)? updated,
    TResult? Function()? updating,
    TResult? Function(String message)? updateError,
  }) {
    return idle?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(UserModel user)? updated,
    TResult Function()? updating,
    TResult Function(String message)? updateError,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(IdleProfileState value) idle,
    required TResult Function(UpdatedProfile value) updated,
    required TResult Function(UpdatingProfile value) updating,
    required TResult Function(UpdateErrorProfile value) updateError,
  }) {
    return idle(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(IdleProfileState value)? idle,
    TResult? Function(UpdatedProfile value)? updated,
    TResult? Function(UpdatingProfile value)? updating,
    TResult? Function(UpdateErrorProfile value)? updateError,
  }) {
    return idle?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(IdleProfileState value)? idle,
    TResult Function(UpdatedProfile value)? updated,
    TResult Function(UpdatingProfile value)? updating,
    TResult Function(UpdateErrorProfile value)? updateError,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle(this);
    }
    return orElse();
  }
}

abstract class IdleProfileState implements ProfileState {
  factory IdleProfileState() = _$IdleProfileStateImpl;
}

/// @nodoc
abstract class _$$UpdatedProfileImplCopyWith<$Res> {
  factory _$$UpdatedProfileImplCopyWith(_$UpdatedProfileImpl value,
          $Res Function(_$UpdatedProfileImpl) then) =
      __$$UpdatedProfileImplCopyWithImpl<$Res>;
  @useResult
  $Res call({UserModel user});
}

/// @nodoc
class __$$UpdatedProfileImplCopyWithImpl<$Res>
    extends _$ProfileStateCopyWithImpl<$Res, _$UpdatedProfileImpl>
    implements _$$UpdatedProfileImplCopyWith<$Res> {
  __$$UpdatedProfileImplCopyWithImpl(
      _$UpdatedProfileImpl _value, $Res Function(_$UpdatedProfileImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
  }) {
    return _then(_$UpdatedProfileImpl(
      null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as UserModel,
    ));
  }
}

/// @nodoc

class _$UpdatedProfileImpl implements UpdatedProfile {
  _$UpdatedProfileImpl(this.user);

  @override
  final UserModel user;

  @override
  String toString() {
    return 'ProfileState.updated(user: $user)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdatedProfileImpl &&
            (identical(other.user, user) || other.user == user));
  }

  @override
  int get hashCode => Object.hash(runtimeType, user);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdatedProfileImplCopyWith<_$UpdatedProfileImpl> get copyWith =>
      __$$UpdatedProfileImplCopyWithImpl<_$UpdatedProfileImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(UserModel user) updated,
    required TResult Function() updating,
    required TResult Function(String message) updateError,
  }) {
    return updated(user);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(UserModel user)? updated,
    TResult? Function()? updating,
    TResult? Function(String message)? updateError,
  }) {
    return updated?.call(user);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(UserModel user)? updated,
    TResult Function()? updating,
    TResult Function(String message)? updateError,
    required TResult orElse(),
  }) {
    if (updated != null) {
      return updated(user);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(IdleProfileState value) idle,
    required TResult Function(UpdatedProfile value) updated,
    required TResult Function(UpdatingProfile value) updating,
    required TResult Function(UpdateErrorProfile value) updateError,
  }) {
    return updated(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(IdleProfileState value)? idle,
    TResult? Function(UpdatedProfile value)? updated,
    TResult? Function(UpdatingProfile value)? updating,
    TResult? Function(UpdateErrorProfile value)? updateError,
  }) {
    return updated?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(IdleProfileState value)? idle,
    TResult Function(UpdatedProfile value)? updated,
    TResult Function(UpdatingProfile value)? updating,
    TResult Function(UpdateErrorProfile value)? updateError,
    required TResult orElse(),
  }) {
    if (updated != null) {
      return updated(this);
    }
    return orElse();
  }
}

abstract class UpdatedProfile implements ProfileState {
  factory UpdatedProfile(final UserModel user) = _$UpdatedProfileImpl;

  UserModel get user;
  @JsonKey(ignore: true)
  _$$UpdatedProfileImplCopyWith<_$UpdatedProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UpdatingProfileImplCopyWith<$Res> {
  factory _$$UpdatingProfileImplCopyWith(_$UpdatingProfileImpl value,
          $Res Function(_$UpdatingProfileImpl) then) =
      __$$UpdatingProfileImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$UpdatingProfileImplCopyWithImpl<$Res>
    extends _$ProfileStateCopyWithImpl<$Res, _$UpdatingProfileImpl>
    implements _$$UpdatingProfileImplCopyWith<$Res> {
  __$$UpdatingProfileImplCopyWithImpl(
      _$UpdatingProfileImpl _value, $Res Function(_$UpdatingProfileImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$UpdatingProfileImpl implements UpdatingProfile {
  _$UpdatingProfileImpl();

  @override
  String toString() {
    return 'ProfileState.updating()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$UpdatingProfileImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(UserModel user) updated,
    required TResult Function() updating,
    required TResult Function(String message) updateError,
  }) {
    return updating();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(UserModel user)? updated,
    TResult? Function()? updating,
    TResult? Function(String message)? updateError,
  }) {
    return updating?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(UserModel user)? updated,
    TResult Function()? updating,
    TResult Function(String message)? updateError,
    required TResult orElse(),
  }) {
    if (updating != null) {
      return updating();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(IdleProfileState value) idle,
    required TResult Function(UpdatedProfile value) updated,
    required TResult Function(UpdatingProfile value) updating,
    required TResult Function(UpdateErrorProfile value) updateError,
  }) {
    return updating(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(IdleProfileState value)? idle,
    TResult? Function(UpdatedProfile value)? updated,
    TResult? Function(UpdatingProfile value)? updating,
    TResult? Function(UpdateErrorProfile value)? updateError,
  }) {
    return updating?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(IdleProfileState value)? idle,
    TResult Function(UpdatedProfile value)? updated,
    TResult Function(UpdatingProfile value)? updating,
    TResult Function(UpdateErrorProfile value)? updateError,
    required TResult orElse(),
  }) {
    if (updating != null) {
      return updating(this);
    }
    return orElse();
  }
}

abstract class UpdatingProfile implements ProfileState {
  factory UpdatingProfile() = _$UpdatingProfileImpl;
}

/// @nodoc
abstract class _$$UpdateErrorProfileImplCopyWith<$Res> {
  factory _$$UpdateErrorProfileImplCopyWith(_$UpdateErrorProfileImpl value,
          $Res Function(_$UpdateErrorProfileImpl) then) =
      __$$UpdateErrorProfileImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$UpdateErrorProfileImplCopyWithImpl<$Res>
    extends _$ProfileStateCopyWithImpl<$Res, _$UpdateErrorProfileImpl>
    implements _$$UpdateErrorProfileImplCopyWith<$Res> {
  __$$UpdateErrorProfileImplCopyWithImpl(_$UpdateErrorProfileImpl _value,
      $Res Function(_$UpdateErrorProfileImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$UpdateErrorProfileImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$UpdateErrorProfileImpl implements UpdateErrorProfile {
  _$UpdateErrorProfileImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'ProfileState.updateError(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateErrorProfileImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateErrorProfileImplCopyWith<_$UpdateErrorProfileImpl> get copyWith =>
      __$$UpdateErrorProfileImplCopyWithImpl<_$UpdateErrorProfileImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(UserModel user) updated,
    required TResult Function() updating,
    required TResult Function(String message) updateError,
  }) {
    return updateError(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(UserModel user)? updated,
    TResult? Function()? updating,
    TResult? Function(String message)? updateError,
  }) {
    return updateError?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(UserModel user)? updated,
    TResult Function()? updating,
    TResult Function(String message)? updateError,
    required TResult orElse(),
  }) {
    if (updateError != null) {
      return updateError(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(IdleProfileState value) idle,
    required TResult Function(UpdatedProfile value) updated,
    required TResult Function(UpdatingProfile value) updating,
    required TResult Function(UpdateErrorProfile value) updateError,
  }) {
    return updateError(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(IdleProfileState value)? idle,
    TResult? Function(UpdatedProfile value)? updated,
    TResult? Function(UpdatingProfile value)? updating,
    TResult? Function(UpdateErrorProfile value)? updateError,
  }) {
    return updateError?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(IdleProfileState value)? idle,
    TResult Function(UpdatedProfile value)? updated,
    TResult Function(UpdatingProfile value)? updating,
    TResult Function(UpdateErrorProfile value)? updateError,
    required TResult orElse(),
  }) {
    if (updateError != null) {
      return updateError(this);
    }
    return orElse();
  }
}

abstract class UpdateErrorProfile implements ProfileState {
  factory UpdateErrorProfile(final String message) = _$UpdateErrorProfileImpl;

  String get message;
  @JsonKey(ignore: true)
  _$$UpdateErrorProfileImplCopyWith<_$UpdateErrorProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

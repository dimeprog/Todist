import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:todist/models/user_model.dart';

part 'profile_state.freezed.dart';

@freezed
abstract class ProfileState with _$ProfileState {
  factory ProfileState.idle() = IdleProfileState;
  factory ProfileState.updated(UserModel user) = UpdatedProfile;
  factory ProfileState.updating() = UpdatingProfile;
  factory ProfileState.updateError(String message) = UpdateErrorProfile;
  
}

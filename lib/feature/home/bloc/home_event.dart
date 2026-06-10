import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeData extends HomeEvent {}

class DismissBiometricsPrompt extends HomeEvent {}

class EnableBiometrics extends HomeEvent {}

class ChangeCurrency extends HomeEvent {
  final String currency;

  const ChangeCurrency(this.currency);

  @override
  List<Object?> get props => [currency];
}


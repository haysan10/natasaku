import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/datasources/local/local_storage.dart';

class SecurityState {
  final bool isLocked;
  final bool hasPin;
  final String? pinCode;

  const SecurityState({
    this.isLocked = false,
    this.hasPin = false,
    this.pinCode,
  });

  SecurityState copyWith({
    bool? isLocked,
    bool? hasPin,
    String? pinCode,
  }) {
    return SecurityState(
      isLocked: isLocked ?? this.isLocked,
      hasPin: hasPin ?? this.hasPin,
      pinCode: pinCode ?? this.pinCode,
    );
  }
}

class SecurityNotifier extends StateNotifier<SecurityState> with WidgetsBindingObserver {
  final LocalStorage _storage;

  SecurityNotifier(this._storage) : super(const SecurityState()) {
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _init() async {
    final pin = await _storage.getAppPin();
    if (pin != null && pin.isNotEmpty) {
      state = state.copyWith(
        hasPin: true,
        pinCode: pin,
        isLocked: true, // Lock immediately on boot if PIN is enabled
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (this.state.hasPin) {
      if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
        // Lock the app when it goes to background
        this.state = this.state.copyWith(isLocked: true);
      }
    }
  }

  bool verifyPin(String enteredPin) {
    if (state.pinCode == enteredPin) {
      state = state.copyWith(isLocked: false);
      return true;
    }
    return false;
  }

  Future<void> setPin(String newPin) async {
    await _storage.saveAppPin(newPin);
    state = state.copyWith(hasPin: true, pinCode: newPin, isLocked: false);
  }

  Future<void> removePin() async {
    await _storage.saveAppPin(null);
    state = state.copyWith(hasPin: false, pinCode: null, isLocked: false);
  }
  
  void lockManually() {
    if (state.hasPin) {
      state = state.copyWith(isLocked: true);
    }
  }
}

final securityProvider = StateNotifierProvider<SecurityNotifier, SecurityState>((ref) {
  return SecurityNotifier(LocalStorage());
});

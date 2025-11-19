import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:tour_ease/Services/ApiService.dart';
import 'package:tour_ease/const.dart';
import 'package:tour_ease/model/userManagment/user.dart';

class StripeService {
  StripeService._();
  static final StripeService _instance = StripeService._();
  static StripeService get instance => _instance;

  late APIServiceNodeJS _apiService;
  bool _isInitialized = false;

  /// Initialize Stripe with publishable key
  Future<void> initialize(UserModel user) async {
    if (_isInitialized) return;

    try {
      // Initialize Stripe with publishable key
      Stripe.publishableKey = stripePublishableKey;

      // Initialize API service for payment intent creation
      _apiService = APIServiceNodeJS('https://api.tourease.me/api', user.id);

      _isInitialized = true;
      print('✅ Stripe initialized successfully');
    } catch (e) {
      print('❌ Error initializing Stripe: $e');
      rethrow;
    }
  }

  /// Create payment intent on backend
  Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String currency,
    required String bookingId,
    required String customerEmail,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        path: '/payments/create-payment-intent',
        body: {
          'amount': amount,
          'currency': currency,
          'bookingId': bookingId,
          'customerEmail': customerEmail,
        },
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (response['success'] == true) {
        return response['data'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create payment intent');
      }
    } catch (e) {
      print('❌ Error creating payment intent: $e');
      rethrow;
    }
  }

  /// Process payment using Stripe Payment Sheet
  Future<Map<String, dynamic>> makePayment({
    required double amount,
    required String currency,
    required int bookingId,
    required String customerEmail,
    required UserModel user,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize(user);
      }

      // Step 1: Create payment intent on backend
      print('🔄 Creating payment intent for \$${amount.toStringAsFixed(2)}...');
      final paymentIntentData = await createPaymentIntent(
        amount: amount,
        currency: currency,
        bookingId: bookingId.toString(),
        customerEmail: customerEmail,
      );

      final clientSecret = paymentIntentData['clientSecret'];
      final paymentIntentId = paymentIntentData['paymentIntentId'];

      if (clientSecret == null || clientSecret.isEmpty) {
        throw Exception('Invalid client secret received');
      }

      // Step 2: Initialize payment sheet
      print('📋 Initializing payment sheet...');
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'TourEase',
          style: ThemeMode.system,
          customFlow: false,
          allowsDelayedPaymentMethods: true,
          appearance: PaymentSheetAppearance(
            primaryButton: PaymentSheetPrimaryButtonAppearance(
              colors: PaymentSheetPrimaryButtonTheme(
                light: PaymentSheetPrimaryButtonThemeColors(
                  background: null,
                  text: null,
                  border: null,
                ),
              ),
            ),
          ),
          // Override the currency symbol in payment sheet
          customerId: null,
          customerEphemeralKeySecret: null,
        ),
      );

      // Step 3: Present payment sheet
      print('💳 Presenting payment sheet...');
      await Stripe.instance.presentPaymentSheet();

      // Step 4: Payment successful
      print('✅ Payment successful! Payment Intent ID: $paymentIntentId');
      return {
        'success': true,
        'paymentIntentId': paymentIntentId,
        'message': 'Payment completed successfully',
      };
    } on StripeException catch (e) {
      print('❌ Stripe error: ${e.error.localizedMessage}');

      if (e.error.code == FailureCode.Canceled) {
        return {
          'success': false,
          'error': 'Payment was cancelled',
          'cancelled': true,
        };
      }

      return {
        'success': false,
        'error': e.error.localizedMessage ?? 'Payment failed',
      };
    } catch (e) {
      print('❌ Payment error: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Check if Stripe is initialized
  bool get isInitialized => _isInitialized;
}

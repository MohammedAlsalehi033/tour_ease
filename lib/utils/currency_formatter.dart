import 'package:intl/intl.dart';

/// Utility class for formatting currency amounts in PKR (Pakistani Rupees)
class CurrencyFormatter {
  /// Formats amount in PKR with proper locale formatting
  /// Example: 168000 -> "Rs. 168,000"
  static String formatPKR(double amount) {
    final formatter = NumberFormat('#,##,###', 'en_PK');
    return 'Rs. ${formatter.format(amount)}';
  }

  /// Formats amount in PKR with compact notation for large numbers
  /// Example: 1000000 -> "Rs. 10 lakh"
  static String formatPKRCompact(double amount) {
    if (amount >= 10000000) {
      // Crore (10 million)
      return 'Rs. ${(amount / 10000000).toStringAsFixed(2)} crore';
    } else if (amount >= 100000) {
      // Lakh (100 thousand)
      return 'Rs. ${(amount / 100000).toStringAsFixed(2)} lakh';
    } else {
      return formatPKR(amount);
    }
  }

  /// Formats amount in PKR without symbol
  /// Example: 168000 -> "168,000"
  static String formatAmount(double amount) {
    final formatter = NumberFormat('#,##,###', 'en_PK');
    return formatter.format(amount);
  }

  /// Parses PKR string to double
  /// Example: "Rs. 168,000" -> 168000.0
  static double parsePKR(String pkrString) {
    final cleaned = pkrString.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  /// Estimates budget based on travelers, nights, and quality
  static double estimateBudget(int travelers, int nights, String quality) {
    double perPersonPerNight;
    switch (quality.toLowerCase()) {
      case 'budget':
        perPersonPerNight = 20000;
        break;
      case 'mid':
      case 'comfortable':
        perPersonPerNight = 35000;
        break;
      case 'luxury':
        perPersonPerNight = 60000;
        break;
      default:
        perPersonPerNight = 35000;
    }
    return travelers * nights * perPersonPerNight;
  }

  /// Provides budget recommendation text
  static String getBudgetRecommendation(int travelers, int nights) {
    final budget = estimateBudget(travelers, nights, 'budget');
    final comfortable = estimateBudget(travelers, nights, 'comfortable');
    final luxury = estimateBudget(travelers, nights, 'luxury');
    
    return 'Budget: ${formatPKR(budget)} • Comfortable: ${formatPKR(comfortable)} • Luxury: ${formatPKR(luxury)}';
  }
}

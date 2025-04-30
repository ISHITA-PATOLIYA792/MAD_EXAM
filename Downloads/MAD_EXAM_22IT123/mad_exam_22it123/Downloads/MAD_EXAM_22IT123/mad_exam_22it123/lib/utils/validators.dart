class Validators {
  // validate card name
  static String? validateCardName(String? value) {
    if (value == null || value.isEmpty) {
      return 'card name is required';
    }
    if (value.length < 2) {
      return 'card name must be at least 2 characters';
    }
    return null;
  }
  
  // validate card number
  static String? validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'card number is required';
    }
    
    // allow alphanumeric characters, spaces, and hyphens
    final regex = RegExp(r'^[a-zA-Z0-9\- ]+$');
    if (!regex.hasMatch(value)) {
      return 'card number can only contain letters, numbers, spaces, and hyphens';
    }
    
    return null;
  }
  
  // validate barcode
  static String? validateBarcode(String? value) {
    if (value == null || value.isEmpty) {
      return 'barcode is required';
    }
    
    // numeric barcode
    final numericRegex = RegExp(r'^[0-9]+$');
    if (!numericRegex.hasMatch(value)) {
      return 'barcode must contain only numbers';
    }
    
    return null;
  }
  
  // validate expiration date
  static String? validateExpirationDate(DateTime? value) {
    if (value == null) {
      return 'expiration date is required';
    }
    
    // ensure expiration date is in the future
    if (value.isBefore(DateTime.now())) {
      return 'expiration date must be in the future';
    }
    
    return null;
  }
} 
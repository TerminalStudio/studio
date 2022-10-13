import 'package:studio/src/util/internet_address.dart';

bool isIPv4(String address) {
  try {
    InternetAddress(address, type: InternetAddressType.ipv4);
    return true;
  } catch (e) {
    return false;
  }
}

bool isIPv6(String address) {
  try {
    InternetAddress(address, type: InternetAddressType.ipv6);
    return true;
  } catch (e) {
    return false;
  }
}

bool isDomain(String address) {
  const pattern =
      r'^[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9](\.[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9])*$';
  return RegExp(pattern).hasMatch(address);
}

bool isHostOrIP(String value) {
  return isIPv4(value) || isIPv6(value) || isDomain(value);
}

bool isPort(String input) {
  final value = int.tryParse(input);
  if (value == null) return false;
  return value >= 0 && value <= 65535;
}

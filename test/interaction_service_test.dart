import 'package:flutter_test/flutter_test.dart';
import 'package:only_flick_flutter/services/content_interaction_service.dart';

void main() {
  test('ContentInteractionService can be instantiated', () {
    final service = ContentInteractionService();
    expect(service, isNotNull);
    expect(service.getLikeCount(1), equals(0));
  });
}

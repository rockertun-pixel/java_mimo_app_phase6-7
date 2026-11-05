import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myanmar_code_learning/data/repositories/progress_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('migrates old saved XP and completed lessons without data loss', () async {
    SharedPreferences.setMockInitialValues({
      'user_progress': '{"completedLessonIds":["java-001"],"totalXp":10}',
    });

    const repository = LocalProgressRepository();
    final migrated = await repository.load();
    final preferences = await SharedPreferences.getInstance();

    expect(migrated.completedLessonIds, {'java-001'});
    expect(migrated.totalXp, 10);
    expect(migrated.energy, 5);
    expect(migrated.currentStreak, 0);
    expect(preferences.getString('user_progress'), isNull);
    expect(preferences.getString('user_progress_v2'), isNotNull);
  });
}

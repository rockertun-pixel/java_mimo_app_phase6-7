import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/local_course_data_source.dart';
import '../../../data/models/course_model.dart';
import '../../../data/models/lesson_model.dart';
import '../../../data/repositories/course_repository.dart';

export '../../progress/providers/progress_provider.dart';

final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  return LocalCourseRepository(LocalCourseDataSource());
});

final courseListProvider = FutureProvider<List<CourseModel>>((ref) {
  return ref.watch(courseRepositoryProvider).getCourses();
});

final lessonsProvider = FutureProvider.family<List<LessonModel>, String>((ref, courseId) {
  return ref.watch(courseRepositoryProvider).getLessons(courseId);
});

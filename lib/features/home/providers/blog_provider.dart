import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/blog_service.dart';
import '../../admin/admin_mock.dart';

final blogServiceProvider = Provider((ref) => BlogService());

final blogProvider = FutureProvider<List<BlogPost>>((ref) async {
  final blogService = ref.watch(blogServiceProvider);
  return blogService.fetchLatestBlogs();
});

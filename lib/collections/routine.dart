import 'package:Routines/collections/category.dart';
import 'package:isar/isar.dart';

part 'routine.g.dart';

// Rutin koleksiyon modeli.
@Collection()
class Routine {
  // Rutin ID'si, Isar tarafından otomatik olarak atanır.
  Id id = Isar.autoIncrement;
  // Rutin başlığı.
  late String title;
  // Kategori bağlantısı. Kategoriye referans alır.
  @Index(composite: [CompositeIndex('title')])
  final category = IsarLink<Category>();
  // Rutin başlama saati.
  @Index()
  late String startTime;
  // Rutinin günü.
  @Index(caseSensitive: false)
  late String day;
}

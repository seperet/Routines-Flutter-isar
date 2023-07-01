import 'package:isar/isar.dart';
part 'category.g.dart';

// Kategori koleksiyon modeli.
@Collection()
class Category {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  late String name; // Kategorinin adı.
}

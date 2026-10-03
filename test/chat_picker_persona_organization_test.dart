import 'package:flutter_test/flutter_test.dart';
import 'package:pyre/models/models.dart';
import 'package:pyre/screens/chat_picker_screens.dart';

void main() {
  Persona persona(
    String id,
    String name, {
    bool favorite = false,
    bool deleted = false,
    int createdAt = 0,
  }) =>
      Persona(
        id: id,
        name: name,
        favorite: favorite,
        deleted: deleted,
        createdAt: createdAt,
        updatedAt: createdAt,
      );

  group('persona picker organization', () {
    test('excludes tombstones and floats favorites', () {
      final result = organizePickerPersonas(
        all: [
          persona('normal', 'Beta'),
          persona('favorite', 'Alpha', favorite: true),
          persona('deleted', 'Ghost', deleted: true),
        ],
        sortKey: 'alpha',
      );

      expect(result.favs.map((p) => p.id), ['favorite']);
      expect(result.rest.map((p) => p.id), ['normal']);
    });

    test('search matches name, tagline, and description', () {
      final personas = [
        Persona(id: 'name', name: 'Navigator'),
        Persona(id: 'tagline', name: 'One', tagline: 'Star pilot'),
        Persona(id: 'description', name: 'Two', description: 'Deep space medic'),
      ];

      expect(
        organizePickerPersonas(all: personas, query: 'navigator').rest.map((p) => p.id),
        ['name'],
      );
      expect(
        organizePickerPersonas(all: personas, query: 'pilot').rest.map((p) => p.id),
        ['tagline'],
      );
      expect(
        organizePickerPersonas(all: personas, query: 'medic').rest.map((p) => p.id),
        ['description'],
      );
    });

    test('recent sorting uses supplied last-used timestamps', () {
      final result = organizePickerPersonas(
        all: [persona('old', 'Old'), persona('new', 'New')],
        sortKey: 'recent',
        lastUsedAt: const {'old': 10, 'new': 20},
      );

      expect(result.rest.map((p) => p.id), ['new', 'old']);
    });
  });
}

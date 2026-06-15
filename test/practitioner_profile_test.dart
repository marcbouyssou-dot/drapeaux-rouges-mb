import 'package:drapeaux_rouges_mb/models/practitioner_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('serializes direct access practice fields', () {
    const profile = PractitionerProfile(
      nom: 'Martin',
      prenom: 'Claire',
      adresse: '12 rue de la Santé',
      adeli: '123456789',
      rpps: '10101010101',
      exerciceAccesDirect: true,
      nomStructure: 'MSP Centre',
      adresseStructure: '4 place de la Santé',
      departement: '33',
    );

    final restored = PractitionerProfile.fromJson(profile.toJson());

    expect(restored.exerciceAccesDirect, isTrue);
    expect(restored.nomStructure, 'MSP Centre');
    expect(restored.adresseStructure, '4 place de la Santé');
    expect(restored.departement, '33');
    expect(restored.hasDirectAccess, isTrue);
    expect(
      restored.practiceStructureLine,
      contains('Exercice en accès direct'),
    );
    expect(restored.practiceStructureLine, contains('Département : 33'));
  });

  test('one direct access item is enough to validate the status', () {
    const profile = PractitionerProfile(
      nom: '',
      prenom: '',
      adresse: '',
      adeli: '',
      rpps: '',
      nomStructure: 'Maison de santé',
    );

    expect(profile.exerciceAccesDirect, isFalse);
    expect(profile.hasDirectAccess, isTrue);
    expect(profile.practiceStructureLine, contains('Maison de santé'));
  });

  test('keeps legacy practitioner profile compatible', () {
    final profile = PractitionerProfile.fromJson(const {
      'nom': 'Durand',
      'prenom': 'Marc',
      'adresse': '1 rue Test',
    });

    expect(profile.exerciceAccesDirect, isFalse);
    expect(profile.adresseStructure, isEmpty);
    expect(profile.departement, isEmpty);
    expect(profile.practiceStructureLine, isEmpty);
  });
}

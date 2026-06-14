import 'package:drapeaux_rouges_mb/models/attestation/attestation_template.dart';
import 'package:drapeaux_rouges_mb/models/attestation/attestation_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('attestation library exposes expected templates', () {
    expect(attestationTemplates, hasLength(4));
    expect(
      attestationTemplates.map((template) => template.title),
      containsAll([
        'MK le plus proche disponible',
        'Refus d’orientation médicale proposée',
        'Consentement éclairé renforcé',
        'Prise en charge en accès direct',
      ]),
    );
  });

  test('nearest available MK template is active', () {
    final template = attestationTemplates.singleWhere(
      (item) => item.type == AttestationType.nearestAvailableMk,
    );

    expect(template.isActive, isTrue);
    expect(template.statusLabel, 'Actif');
  });

  test('future attestation templates are prepared', () {
    final prepared = attestationTemplates.where(
      (item) => item.status == AttestationTemplateStatus.prepared,
    );

    expect(prepared, hasLength(3));
    expect(prepared.every((item) => item.statusLabel == 'Préparé'), isTrue);
  });
}

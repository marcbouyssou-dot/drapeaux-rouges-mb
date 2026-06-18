import 'bdk_session_service.dart';

class BDKAutoFillService {
  static void fillFromEvaluation({
    required String motif,
    required String evaluation,
    required String limitations,
    required String diagnostic,
    required List<String> redFlags,
  }) {
    BDKSessionService.motif = motif;

    BDKSessionService.evaluation = evaluation;

    BDKSessionService.limitations = limitations;

    BDKSessionService.diagnostic = diagnostic;

    BDKSessionService.redFlags = redFlags;

    if (redFlags.isNotEmpty) {
      BDKSessionService.vigilance =
          'Présence de signes de vigilance nécessitant une surveillance clinique.';
    }

    BDKSessionService.syntheseClinique =
        '''
Patient présentant $motif.

Les principaux éléments cliniques retrouvés sont :

$evaluation

Les limitations fonctionnelles principales sont :

$limitations

Une prise en charge kinésithérapique adaptée semble indiquée.
''';
  }
}

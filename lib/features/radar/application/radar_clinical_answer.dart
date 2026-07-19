enum RadarClinicalAnswer { yes, no, bilateral, unknown }

extension RadarClinicalAnswerRuntimeSupport on RadarClinicalAnswer {
  bool get isSupportedByRuntimeV5 {
    return switch (this) {
      RadarClinicalAnswer.yes || RadarClinicalAnswer.no => true,
      RadarClinicalAnswer.bilateral || RadarClinicalAnswer.unknown => false,
    };
  }

  bool? get runtimeBooleanValue {
    return switch (this) {
      RadarClinicalAnswer.yes => true,
      RadarClinicalAnswer.no => false,
      RadarClinicalAnswer.bilateral || RadarClinicalAnswer.unknown => null,
    };
  }
}

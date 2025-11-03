<?php

use CRM_Customtabgrouping_ExtensionUtil as E;

class CRM_Customtabgrouping_Utils {

  /**
   * Get layout width options.
   *
   * @return array
   *   Associative array of layout width options.
   */
  public static function getLayoutWidth() {
    return [
      '100' => E::ts('Full Width (100%)'),
      '50' => E::ts('Half Width (50%)'),
      '33' => E::ts('Third Width (33%)'),
      '25' => E::ts('Quarter Width (25%)'),
    ];
  }

  public static function getLayoutFloatStyle() {
    $floatStyles = [
      'none' => E::ts('Stack (Default)'),
      'left' => E::ts('Float Left'),
      'right' => E::ts('Float Right'),
      'both' => E::ts('Allow Float'),
    ];
    return $floatStyles;
  }

}
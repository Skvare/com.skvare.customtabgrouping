<?php

use CRM_Customtabgrouping_ExtensionUtil as E;

/**
 * Collection of upgrade steps.
 */
class CRM_Customtabgrouping_Upgrader extends CRM_Extension_Upgrader_Base {

  // By convention, functions that look like "function upgrade_NNNN()" are
  // upgrade tasks. They are executed in order (like Drupal's hook_update_N).

  /**
   * Example: Run an external SQL script when the module is installed.
   *
   * Note that if a file is present sql\auto_install that will run regardless of this hook.
   */
  public function install(): void {
    if (!CRM_Core_BAO_SchemaHandler::checkIfFieldExists('civicrm_custom_group', 'tab_name')) {
      CRM_Core_DAO::executeQuery("
        ALTER TABLE civicrm_custom_group
        ADD COLUMN tab_name VARCHAR(255) NULL DEFAULT NULL COMMENT 'Name of the tab where this custom group should appear'
      ");
    }

    if (!CRM_Core_BAO_SchemaHandler::checkIfFieldExists('civicrm_custom_group', 'tab_group_order')) {
      CRM_Core_DAO::executeQuery("
        ALTER TABLE civicrm_custom_group
        ADD COLUMN tab_group_order int NOT NULL DEFAULT '1' COMMENT 'Controls display order when multiple groups share the same tab'
      ");
    }
  }


  /**
   * Example: Run an external SQL script when the module is uninstalled.
   *
   * Note that if a file is present sql\auto_uninstall that will run regardless of this hook.
   */
  public function uninstall(): void {
    if (CRM_Core_BAO_SchemaHandler::checkIfFieldExists('civicrm_custom_group', 'tab_name')) {
      CRM_Core_DAO::executeQuery("ALTER TABLE civicrm_custom_group DROP COLUMN tab_name");
    }

    if (CRM_Core_BAO_SchemaHandler::checkIfFieldExists('civicrm_custom_group', 'tab_group_order')) {
      CRM_Core_DAO::executeQuery("ALTER TABLE civicrm_custom_group DROP COLUMN tab_group_order");
    }
  }

  /**
   * Example: Run a couple simple queries.
   *
   * @return TRUE on success
   * @throws CRM_Core_Exception
   */
  public function upgrade_1100(): bool {
    $this->ctx->log->info('Applying update 4200');
    if (!CRM_Core_BAO_SchemaHandler::checkIfFieldExists('civicrm_custom_group', 'tab_group_order')) {
      CRM_Core_DAO::executeQuery("
        ALTER TABLE civicrm_custom_group
        ADD COLUMN tab_group_order int NOT NULL DEFAULT '1' COMMENT 'Controls display order when multiple groups share the same tab'
      ");
    }
    return TRUE;
  }
}

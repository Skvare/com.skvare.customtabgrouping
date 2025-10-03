<?php

require_once 'customtabgrouping.civix.php';

use CRM_Customtabgrouping_ExtensionUtil as E;

/**
 * Implements hook_civicrm_config().
 *
 * @link https://docs.civicrm.org/dev/en/latest/hooks/hook_civicrm_config/
 */
function customtabgrouping_civicrm_config(&$config): void {
  _customtabgrouping_civix_civicrm_config($config);
}

/**
 * Implements hook_civicrm_enable().
 *
 * @link https://docs.civicrm.org/dev/en/latest/hooks/hook_civicrm_enable
 */
function customtabgrouping_civicrm_enable(): void {
  _customtabgrouping_civix_civicrm_enable();
}

/**
 * Implements hook_civicrm_install().
 */
function customtabgrouping_civicrm_install() {
  _customtabgrouping_civix_civicrm_install();
}

/**
 * Implements hook_civicrm_uninstall().
 */
function customtabgrouping_civicrm_uninstall() {
  _customtabgrouping_civix_civicrm_uninstall();
}

/**
 * Implements hook_civicrm_buildForm().
 *
 * Add tab name field to custom group form.
 */
function customtabgrouping_civicrm_buildForm($formName, &$form) {
  if ($formName == 'CRM_Custom_Form_Group') {
    // Add the tab name field
    $form->add(
      'text',
      'tab_name',
      E::ts('Tab Name'),
      ['class' => 'huge', 'placeholder' => E::ts('Enter tab name (e.g., "Other Stuff")')],
      FALSE
    );

    // Set default value if editing existing group
    if ($form->getAction() == CRM_Core_Action::UPDATE) {
      $groupId = $form->getVar('_id');
      if ($groupId) {
        try {
          $customGroup = civicrm_api3('CustomGroup', 'getsingle', [
            'id' => $groupId,
            'return' => ['tab_name'],
          ]);

          if (!empty($customGroup['tab_name'])) {
            $defaults['tab_name'] = $customGroup['tab_name'];
            $form->setDefaults($defaults);
          }
        } catch (Exception $e) {
          // Group not found or no tab_name, continue
        }
      }
    }

    // Add help text and styling via template
    CRM_Core_Region::instance('page-body')->add([
      'template' => 'CRM/Customtabgrouping/CustomGroupFormExtra.tpl',
    ]);
  }
}

/**
 * Implements hook_civicrm_postProcess().
 *
 * Save the tab name when custom group is saved.
 */
function customtabgrouping_civicrm_postProcess($formName, &$form) {
  if ($formName == 'CRM_Custom_Form_Group') {
    $values = $form->exportValues();
    $groupId = $form->getVar('_id');

    if ($groupId && isset($values['tab_name'])) {
      CRM_Core_DAO::executeQuery("
        UPDATE civicrm_custom_group 
        SET tab_name = %1 
        WHERE id = %2
      ", [
        1 => [$values['tab_name'], 'String'],
        2 => [$groupId, 'Integer'],
      ]);

      // Clear cache
      //CRM_Core_BAO_Cache::deleteGroup('contact fields');
    }
  }
}

/**
 * Implements hook_civicrm_tabs().
 *
 * Group custom field groups with the same tab_name into a single tab.
 */
function customtabgrouping_civicrm_tabset($tabsetName, &$tabs, $context) {
  //return;
  if ($tabsetName !== 'civicrm/contact/view') {
    return;
  }
  // Get all custom groups with tab_name set
  try {
    $customGroups = civicrm_api3('CustomGroup', 'get', [
      'extends' => 'Contact',
      'style' => ['IN' => ["Tab", "Tab with table"]],
      'is_active' => 1,
      'options' => ['limit' => 0],
    ]);
  }
  catch (Exception $e) {
    return;
  }

  $groupedTabs = [];
  $customGroupsToRemove = [];
  // CRM_Core_Error::debug_var('Custom Groups', $customGroups);
  // Group custom groups by tab_name
  foreach ($customGroups['values'] as $group) {
    // Check if custom group has a tab_name column value
    $result = CRM_Core_DAO::executeQuery("
      SELECT tab_name FROM civicrm_custom_group WHERE id = %1
    ", [
      1 => [$group['id'], 'Integer'],
    ]);

    $tabName = NULL;
    if ($result->fetch()) {
      $tabName = $result->tab_name;
    }

    // Only process groups with tab_name set
    if (!empty($tabName)) {
      if (!isset($groupedTabs[$tabName])) {
        $groupedTabs[$tabName] = [];
      }
      $groupedTabs[$tabName][] = $group;
      $customGroupsToRemove[] = 'custom_' . $group['id'];
    }
  }

  // Remove individual custom group tabs that are being grouped
  foreach ($tabs as $key => $tab) {
    if (in_array($tab['id'], $customGroupsToRemove)) {
      unset($tabs[$key]);
    }
  }

  // Add grouped tabs
  foreach ($groupedTabs as $tabName => $groups) {
    // Generate a unique tab ID based on the tab name
    $tabId = 'grouped_custom_' . md5($tabName);

    // Calculate weight (use the average weight of grouped items)
    $totalWeight = 0;
    foreach ($groups as $group) {
      $totalWeight += CRM_Utils_Array::value('weight', $group, 100);
    }
    $avgWeight = count($groups) > 0 ? $totalWeight / count($groups) : 100;

    // Build group IDs parameter
    $groupIds = array_map(function ($g) {
      return $g['id'];
    }, $groups);

    $tabs[] = [
      'id' => $tabId,
      'title' => $tabName,
      'weight' => $avgWeight,
      'icon' => 'crm-i fa-list-alt',
      'url' => CRM_Utils_System::url('civicrm/contact/view/custom-grouped', [
        'reset' => 1,
        'cid' => $context['contact_id'],
        'group_ids' => implode(',', $groupIds),
      ]),
      'count' => count($groups),
    ];
  }
}

/**
 * Implements hook_civicrm_entityTypes().
 */
function customtabgrouping_civicrm_entityTypes(&$entityTypes) {
  $civiVersion = CRM_Utils_System::version();
  $membershipType = 'CRM_Core_DAO_CustomGroup';
  if (version_compare($civiVersion, '5.75.0') >= 0) {
    $membershipType = 'CustomGroup';
  }
  $entityTypes[$membershipType]['fields_callback'][]
    = function ($class, &$fields) {
    $fields['tab_name'] = [
      'name' => 'tab_name',
      'type' => CRM_Utils_Type::T_STRING,
      'title' => ts('Tab Name'),
      'description' => 'tab name.',
      'localizable' => 0,
      'maxlength' => 128,
      'size' => CRM_Utils_Type::HUGE,
      'import' => TRUE,
      'where' => 'civicrm_custom_group.tab_name',
      'export' => TRUE,
      'table_name' => 'civicrm_custom_group',
      'entity' => 'CustomGroup',
      'bao' => 'CRM_Core_BAO_CustomGroup',
      'localizable' => 1,
      'html' => [
        'type' => 'Text',
        'label' => ts("Tab Name."),
      ],
    ];

    $fields['tab_group_order'] = [
      'name' => 'tab_group_order',
      'type' => CRM_Utils_Type::T_INT,
      'title' => ts('Custom Group Order in Tab'),
      'description' => 'Custom Group Order in Tab',
      'localizable' => 0,
      'maxlength' => 10,
      'size' => CRM_Utils_Type::T_INT,
      'import' => TRUE,
      'where' => 'civicrm_custom_group.tab_group_order',
      'export' => TRUE,
      'table_name' => 'civicrm_custom_group',
      'entity' => 'CustomGroup',
      'bao' => 'CRM_Core_BAO_CustomGroup',
      'localizable' => 1,
      'html' => [
        'type' => 'Text',
        'label' => ts("Custom Group Order in Tab"),
      ],
    ];
  };
}

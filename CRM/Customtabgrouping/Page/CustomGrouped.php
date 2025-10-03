<?php

/**
 * Page to display multiple custom field groups in a single tab.
 * This loads CiviCRM's native custom data display via AJAX.
 */
class CRM_Customtabgrouping_Page_CustomGrouped extends CRM_Core_Page {

  /**
   * Run the page.
   */
  public function run() {
    $contactId = CRM_Utils_Request::retrieve('cid', 'Positive', $this, TRUE);
    $groupIdsString = CRM_Utils_Request::retrieve('group_ids', 'String', $this, TRUE);

    // Parse group IDs
    $groupIds = explode(',', $groupIdsString);
    $groupIds = array_map('intval', $groupIds);

    // Get contact details
    try {
      $contact = civicrm_api3('Contact', 'getsingle', [
        'id' => $contactId,
        'return' => ['display_name', 'contact_type'],
      ]);

      $this->assign('contactId', $contactId);
      $this->assign('displayName', $contact['display_name']);
    } catch (Exception $e) {
      CRM_Core_Error::statusBounce('Contact not found');
    }

    // Build custom group data for each group
    $customGroups = [];
    foreach ($groupIds as $groupId) {
      try {
        // Get custom group details
        $group = civicrm_api3('CustomGroup', 'getsingle', [
          'id' => $groupId,
        ]);

        // Generate the URL for this custom group's display page
        // Use the snippet parameter to get just the content without chrome
        $groupUrl = CRM_Utils_System::url('civicrm/contact/view/cd', [
          'reset' => 1,
          'gid' => $groupId,
          'cid' => $contactId,
          'snippet' => 4, // Snippet mode to get just the content
        ]);

        $customGroups[] = [
          'id' => $groupId,
          'title' => $group['title'],
          'url' => $groupUrl,
        ];
      } catch (Exception $e) {
        CRM_Core_Error::debug_log_message('Error loading custom group ' . $groupId . ': ' . $e->getMessage());
      }
    }

    $this->assign('customGroups', $customGroups);

    // Set page title
    CRM_Utils_System::setTitle(ts('Custom Fields'));

    parent::run();
  }

  /**
   * Get the template file name.
   */
  public function getTemplateFileName() {
    return 'CRM/Customtabgrouping/CustomGrouped.tpl';
  }
}
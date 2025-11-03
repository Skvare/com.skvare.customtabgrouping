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
    $groupIds = CRM_Utils_Request::retrieve('group_ids', 'String', $this, TRUE);

    // Convert comma-separated group IDs to array
    $groupIdArray = explode(',', $groupIds);
    $groupIdArray = array_map('intval', $groupIdArray);
    $groupIdArray = array_filter($groupIdArray);
    if (empty($groupIdArray)) {
      CRM_Core_Error::statusBounce(ts('No custom groups specified.'));
    }

    // Verify contact access
    if (!CRM_Contact_BAO_Contact_Permission::allow($contactId)) {
      CRM_Core_Error::statusBounce(ts('You do not have permission to access this contact.'));
    }

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
    foreach ($groupIdArray as $groupId) {
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
          // Adjust for padding/margin.
          'layout_width' => $group['layout_width'] ? $group['layout_width'] - 3 : '98',
          // Default to 'none' if not set
          'layout_float' => $group['layout_float'] ?? 'none',
        ];
      }
      catch (Exception $e) {
        CRM_Core_Error::debug_log_message('Error loading custom group ' . $groupId . ': ' . $e->getMessage());
      }
    }

    $this->assign('customGroups', $customGroups);
    $this->assign('layoutMode', 'width-' . $this->getAverageLayoutWidth($customGroups));
    $this->assign('floatMode', $this->determinePrimaryFloatMode($customGroups));

    // Set page title
    CRM_Utils_System::setTitle(ts('Custom Fields'));

    parent::run();
  }

  // Helper methods to determine overall layout
  private function getAverageLayoutWidth($groups) {
    if (empty($groups)) {
      return '100';
    }
    $widths = array_column($groups, 'layout_width');
    $avgWidth = array_sum($widths) / count($widths);

    $layouts = ['25', '33', '50', '100'];

    // Simple approach to find closest width
    $closestLayout = '100'; // default
    $smallestDiff = PHP_FLOAT_MAX;

    foreach ($layouts as $layout) {
      $diff = abs($layout - $avgWidth);
      if ($diff < $smallestDiff) {
        $smallestDiff = $diff;
        $closestLayout = $layout;
      }
    }

    return $closestLayout;
  }

  private function determinePrimaryFloatMode($groups) {
    $floatCounts = array_count_values(array_column($groups, 'layout_float'));
    return $floatCounts['both'] ?? $floatCounts['left'] ?? $floatCounts['right'] ?? 'none';
  }

  /**
   * Get the template file name.
   */
  public function getTemplateFileName() {
    return 'CRM/Customtabgrouping/CustomGrouped.tpl';
  }
}
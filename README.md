# CiviCRM Custom Tab Grouping Extension

## Overview

This extension allows you to group multiple custom field groups into a single tab on the CiviCRM contact summary page. Instead of having each custom field group create its own tab, you can assign the same "Tab Name" to multiple groups and they will all appear together in one unified tab.

## Features

- **Tab Name Field**: Adds a "Tab Name" field to custom group settings
- **Automatic Grouping**: Multiple custom groups with the same tab name are automatically grouped together
- **Collapsible Sections**: Each custom group within a tab is displayed as a collapsible accordion for better organization
- **Edit Links**: Quick edit buttons for each custom group section
- **Backwards Compatible**: Doesn't affect existing custom groups without tab names

## Use Case Example

**Before this extension:**
- Custom Group "Contact Extras" → Separate tab
- Custom Group "More Contact Extras" → Another separate tab
- Custom Group "Additional Info" → Yet another tab
- Result: Too many tabs cluttering the contact summary page

**After this extension:**
- Custom Group "Contact Extras" → Tab Name: "Other Stuff"
- Custom Group "More Contact Extras" → Tab Name: "Other Stuff"
- Custom Group "Additional Info" → Tab Name: "Other Stuff"
- Result: All three groups display together in a single "Other Stuff" tab

## Installation

### Method 1: Manual Installation

1. Download or clone this repository
2. Place the extension folder in your CiviCRM extensions directory:
   ```
   /path/to/civicrm/ext/com.skvare.customtabgrouping/
   ```

3. Navigate to **Administer » System Settings » Extensions**

4. Click **Refresh** to detect the new extension

5. Find "Custom Tab Grouping" and click **Install**

### Method 2: Using cv command

```bash
cd /path/to/civicrm/ext/
git clone [repository-url] com.skvare.customtabgrouping
cv en customtabgrouping
```

## Usage

### Setting Up Grouped Tabs

1. Navigate to **Administer » Customize Data and Screens » Custom Fields**

2. Create or edit a custom field group

3. In the custom group settings:
    - Set **Used For**: Contacts (or appropriate entity)
    - Set **Display Style**: Tab
    - Enter a **Tab Name**: e.g., "Other Stuff"
    - Save the custom group

4. Repeat for other custom groups you want to group together, using the **same Tab Name**

5. View any contact summary page to see the grouped tabs in action

### Example Configuration

```
Custom Group 1:
  Name: Contact Extras
  Display Style: Tab
  Tab Name: Other Stuff

Custom Group 2:
  Name: More Contact Extras
  Display Style: Tab
  Tab Name: Other Stuff

Custom Group 3:
  Name: Additional Info
  Display Style: Tab
  Tab Name: Other Stuff
```

All three groups will appear in a single "Other Stuff" tab on the contact summary page.

## Technical Details

### Database Changes

The extension adds one column to the `civicrm_custom_group` table:

```sql
ALTER TABLE civicrm_custom_group 
ADD COLUMN tab_name VARCHAR(255) NULL DEFAULT NULL 
COMMENT 'Name of the tab where this custom group should appear';
```

This column is automatically added during installation and removed (optionally) during uninstallation.

## Known Issues & Limitations

1. Currently only works for Contact custom groups (can be extended to other entities)
2. Tab weight is calculated as average of grouped items (may need manual adjustment)
3. Custom groups without a tab name continue to work as before

## Troubleshooting

### Tab name field doesn't appear

1. Clear CiviCRM cache: **Administer » System Settings » Cleanup Caches and Update Paths**
2. Ensure extension is enabled
3. Check browser console for JavaScript errors

### Grouped tabs not showing

1. Verify all custom groups have exactly the same tab name (case-sensitive)
2. Ensure Display Style is set to "Tab" for all groups
3. Clear browser cache and CiviCRM cache
4. Check that custom groups are active

### Database error during installation

The extension needs permission to alter the database schema. Ensure your CiviCRM database user has ALTER privileges.

## Uninstallation

1. Navigate to **Administer » System Settings » Extensions**
2. Find "Custom Tab Grouping" and click **Disable**
3. Click **Uninstall**

**Note**: Uninstalling will remove the `tab_name` column from the database. Any tab name values will be lost.

### Testing

1. Create multiple custom field groups
2. Assign same tab name to multiple groups
3. View contact summary page
4. Verify all grouped fields appear in single tab
5. Test edit functionality for each group
6. Test with different field types (text, date, select, etc.)
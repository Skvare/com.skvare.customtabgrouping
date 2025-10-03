{* Template to enhance the Custom Group form with tab_name field *}
<table class="form-layout-compressed" style="display: none">
  <tr class="crm-section tab-name-section">
    <td class="label">{$form.tab_name.label}</td>
    <td>{$form.tab_name.html}
    </td>
  </tr>
</table>
{literal}
<script type="text/javascript">
  CRM.$(function($) {
    // Find the style field and add our tab name field after it
    var $styleField = $('tr.field-style');
    if ($styleField.length) {
      // Insert after style field
      $('.tab-name-section').insertAfter('.field-style');

      // Get existing tab_name value if present
      var existingTabName = $('input[name="tab_name"]').val();
      if (existingTabName) {
        $('#tab_name').val(existingTabName);
      }

      // Show/hide tab name field based on style selection
      function toggleTabNameField() {
        var styleValue = $('select[name="style"]').val();
        if (styleValue === 'Tab' || styleValue === 'Tab with table') {
          $('.tab-name-section').slideDown();
        } else {
          $('.tab-name-section').slideUp();
          $('#tab_name').val('');
        }
      }

      // Initial state
      toggleTabNameField();

      // Watch for changes
      $('select[name="style"]').on('change', toggleTabNameField);

      // Add info box about grouped tabs
      var $infoBox = $(
        '<tr class="crm-section crm-info-box" style="margin-top: 15px; padding: 10px; background: #e7f3ff; border-left: 4px solid #2196F3; display:none;"><td colspan=2>' +
        '  <strong>{/literal}{ts}Tip:{/ts}{literal}</strong> ' +
        '  {/literal}{ts}To group multiple custom field groups in the same tab, give them the same tab name. They will all appear together in that tab on the contact summary page.{/ts}{literal}' +
        '</td></tr>'
      );

      $('.tab-name-section').after($infoBox);

      function toggleInfoBox() {
        var styleValue = $('select[name="style"]').val();
        if (styleValue === 'Tab' || styleValue === 'Tab with table') {
          $infoBox.slideDown();
        } else {
          $infoBox.slideUp();
        }
      }

      toggleInfoBox();
      $('select[name="style"]').on('change', toggleInfoBox);
    }
  });
</script>

  <style>
    .tab-name-section .description {
      font-style: italic;
      color: #666;
      margin-top: 5px;
      font-size: 12px;
    }

    .crm-info-box {
      border-radius: 4px;
    }

    .tab-name-section input#tab_name {
      width: 100%;
      max-width: 400px;
    }
  </style>
{/literal}
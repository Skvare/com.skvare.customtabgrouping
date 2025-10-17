{* Template to enhance the Custom Group form with tab_name and tab_group_order fields *}
<table class="form-layout-compressed" style="display: none">
  <tr class="crm-section tab-name-section">
    <td class="label">{$form.tab_name.label}</td>
    <td>{$form.tab_name.html}
    </td>
  </tr>
  <tr class="crm-section tab-group-order-section">
    <td class="label">{$form.tab_group_order.label}</td>
    <td>{$form.tab_group_order.html}
      <div class="description">{ts}Controls the display order of this group within the tab (lower numbers appear first).{/ts}</div>
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
      $('.tab-group-order-section').insertAfter('.tab-name-section');

      // Get existing values if present
      var existingTabName = $('input[name="tab_name"]').val();
      var existingTabGroupOrder = $('input[name="tab_group_order"]').val();

      if (existingTabName) {
        $('#tab_name').val(existingTabName);
      }
      if (existingTabGroupOrder) {
        $('#tab_group_order').val(existingTabGroupOrder);
      }

      // Show/hide tab name and order fields based on style selection
      function toggleTabFields() {
        var styleValue = $('select[name="style"]').val();
        if (styleValue === 'Tab' || styleValue === 'Tab with table' || styleValue === 'Inline') {
          $('.tab-name-section').slideDown();

          // Only show tab_group_order if tab_name has a value
          var tabNameValue = $('#tab_name').val();
          if (tabNameValue && tabNameValue.trim() !== '') {
            $('.tab-group-order-section').slideDown();
          } else {
            $('.tab-group-order-section').slideUp();
          }
        } else {
          $('.tab-name-section').slideUp();
          $('.tab-group-order-section').slideUp();
          $('#tab_name').val('');
          $('#tab_group_order').val('1');
        }
      }

      // Show/hide tab_group_order based on tab_name value
      function toggleTabGroupOrder() {
        var tabNameValue = $('#tab_name').val();
        var styleValue = $('select[name="style"]').val();

        if ((styleValue === 'Tab' || styleValue === 'Tab with table' || styleValue === 'Inline') &&
          tabNameValue && tabNameValue.trim() !== '') {
          $('.tab-group-order-section').slideDown();
        } else {
          $('.tab-group-order-section').slideUp();
          if (!tabNameValue || tabNameValue.trim() === '') {
            $('#tab_group_order').val('1');
          }
        }
      }

      // Initial state
      toggleTabFields();

      // Watch for changes
      $('select[name="style"]').on('change', toggleTabFields);
      $('#tab_name').on('input change', toggleTabGroupOrder);

      // Validate tab_group_order input (only allow positive integers)
      $('#tab_group_order').on('input', function() {
        var value = $(this).val();
        // Remove non-numeric characters
        value = value.replace(/[^0-9]/g, '');
        // Ensure minimum value of 1
        if (value === '' || parseInt(value) < 1) {
          value = '1';
        }
        $(this).val(value);
      });

      // Add info box about grouped tabs
      var $infoBox = $(
        '<tr class="crm-section crm-info-box" style="margin-top: 15px; padding: 10px; background: #e7f3ff; border-left: 4px solid #2196F3; display:none;"><td colspan=2>' +
        '  <strong>{/literal}{ts}Tip:{/ts}{literal}</strong> ' +
        '  {/literal}{ts}To group multiple custom field groups in the same tab, give them the same tab name. Use the "Order within Tab" field to control the sequence in which groups appear within that tab (lower numbers appear first).{/ts}{literal}' +
        '</td></tr>'
      );

      $('.tab-group-order-section').after($infoBox);

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

    .tab-group-order-section .description {
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

    .tab-group-order-section input#tab_group_order {
      width: 60px;
      text-align: center;
    }

    .tab-group-order-section {
      padding-left: 20px;
      border-left: 3px solid #f0f0f0;
      margin-left: 10px;
    }
  </style>
{/literal}
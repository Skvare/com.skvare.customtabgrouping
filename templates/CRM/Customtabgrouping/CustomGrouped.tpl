{* Template for displaying multiple custom field groups in one tab *}
{* Loads CiviCRM's native custom data display via AJAX *}

<div class="crm-block crm-content-block crm-custom-data-grouped">

  {if $customGroups}
    {foreach from=$customGroups item=group name=groupLoop}
      <div class="crm-block crm-content-block crm-records-listing crm-multivalue-selector-{$group.id}">
      <div class="crm-accordion-wrapper crm-custom-accordion {if $smarty.foreach.groupLoop.first}open{else}collapsed{/if}" data-group-id="{$group.id}">
        <div class="crm-accordion-header">
          <span class="crm-custom-group-title">{$group.title}</span>
        </div>

        <div class="crm-accordion-body">
          {* Container where native CiviCRM content will be loaded *}
          <div class="crm-custom-data-content"
               id="custom-group-{$group.id}"
               data-load-url="{$group.url}">
            <div class="crm-loading-element">
              <span class="crm-i fa-spinner fa-spin"></span> {ts}Loading...{/ts}
            </div>
          </div>
        </div>
      </div>
      </div>
    {/foreach}
  {else}
    <div class="messages status no-popup">
      <div class="icon inform-icon"></div>
      {ts}No custom data to display.{/ts}
    </div>
  {/if}

</div>

{* Styling *}
{literal}
<style>
  .crm-custom-data-grouped {
    margin: 20px 0;
  }

  .crm-custom-accordion {
    margin-bottom: 15px;
    border: 1px solid #ddd;
    border-radius: 4px;
    background: #fff;
  }

  .crm-custom-accordion .crm-accordion-header {
    background: #f7f7f7;
    padding: 12px 15px;
    cursor: pointer;
    border-bottom: 1px solid #ddd;
    font-weight: bold;
    font-size: 14px;
    position: relative;
    color: #000;
  }

  .crm-custom-accordion .crm-accordion-header:before {
    content: "\f078";
    font-family: "FontAwesome";
    position: absolute;
    right: 15px;
    top: 12px;
    transition: transform 0.3s;
  }

  .crm-custom-accordion.collapsed .crm-accordion-header:before {
    transform: rotate(-90deg);
  }

  .crm-custom-accordion .crm-accordion-header:hover {
    background: #efefef;
  }

  .crm-custom-accordion.collapsed .crm-accordion-body {
    display: none;
  }

  .crm-custom-accordion .crm-accordion-body {
    padding: 0;
  }

  .crm-custom-data-content {
    min-height: 50px;
  }

  .crm-loading-element {
    padding: 20px;
    text-align: center;
    color: #666;
  }

  .crm-loading-element .fa-spinner {
    margin-right: 8px;
  }
</style>

<script type="text/javascript">
{/literal}
  CRM.$(function($) {

    /**
     * Load custom group content via AJAX
     */
    function loadCustomGroup($container) {
      var url = $container.data('load-url');

      if (!url || $container.data('loaded')) {
        return;
      }

      $.ajax({
        url: url,
        dataType: 'html',
        success: function(data) {
          $container.html(data);
          $container.data('loaded', true);

          // Add crm-popup class to edit/add links after content loads
          initializePopupLinks($container);
          
          // Watch for dynamically added content (DataTables, etc.)
          observeContentChanges($container);
          
          // Also re-initialize after a short delay for DataTables
          setTimeout(function() {
            initializePopupLinks($container);
          }, 1000);

          // Trigger CiviCRM's standard initialization for any forms/buttons
          if (typeof CRM.loadPage === 'function') {
            $container.trigger('crmLoad');
          }
        },
        error: function() {
          $container.html('<div class="messages error"><div class="icon inform-icon"></div>Error loading custom data.</div>');
        }
      });
    }

    /**
     * Add crm-popup class to edit and add links
     */
    function initializePopupLinks($container) {
      // Find all links that should open in popup
      $container.find('a').each(function() {
        var $link = $(this);
        var href = $link.attr('href') || '';
        
        // Skip delete links
        if ($link.hasClass('delete-custom-row') || href.indexOf('action=delete') > -1) {
          return;
        }
        
        // Check if it's an edit, add, update, or view link for custom data
        if (href.indexOf('/cd/edit') > -1 || 
            href.indexOf('/cd?') > -1 ||
            href.indexOf('action=add') > -1 || 
            href.indexOf('action=update') > -1 ||
            href.indexOf('action=browse') > -1 ||
            href.indexOf('multiRecordDisplay=single') > -1) {
          
          // Add crm-popup class
          if (!$link.hasClass('crm-popup')) {
            $link.addClass('crm-popup');
          }
        }
      });
    }
    
    /**
     * Watch for dynamically added content (like DataTables rows)
     */
    function observeContentChanges($container) {
      // Use MutationObserver to watch for DOM changes
      if (typeof MutationObserver !== 'undefined') {
        var observer = new MutationObserver(function(mutations) {
          mutations.forEach(function(mutation) {
            if (mutation.addedNodes.length > 0) {
              // Re-initialize popup links when new content is added
              initializePopupLinks($container);
            }
          });
        });
        
        observer.observe($container[0], {
          childList: true,
          subtree: true
        });
        
        // Store observer reference
        $container.data('mutationObserver', observer);
      }
    }

    /**
     * Initialize: Load the first (open) accordion
     */
    $('.crm-custom-accordion.open .crm-custom-data-content').each(function() {
      loadCustomGroup($(this));
    });

    /**
     * Make accordions collapsible and load content when opened
     */
    $('.crm-custom-accordion .crm-accordion-header').on('click', function(e) {
      // Prevent any default behavior and event bubbling
      e.preventDefault();
      e.stopPropagation();

      var $accordion = $(this).parent('.crm-custom-accordion');
      var $content = $accordion.find('.crm-custom-data-content');

      $accordion.toggleClass('collapsed');

      // Load content if opening and not yet loaded
      if (!$accordion.hasClass('collapsed')) {
        loadCustomGroup($content);
      }
    });

    /**
     * Handle inline edit forms from native CiviCRM display
     * Reload the content after save
     */
    $(document).on('crmFormSuccess crmPopupFormSuccess', '.crm-custom-data-content', function(e, data) {
      var $container = $(this).closest('.crm-custom-data-content');
      if ($container.data('loaded')) {
        $container.data('loaded', false);
        loadCustomGroup($container);
      }
    });
  });
{literal}
</script>
{/literal}

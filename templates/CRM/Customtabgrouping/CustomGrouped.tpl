{* Template for displaying multiple custom field groups in one tab *}
{* Loads CiviCRM's native custom data display via AJAX *}

<div class="crm-block crm-content-block crm-custom-data-grouped layout-{$layoutMode} float-{$floatMode}">

    {if $customGroups}
        {foreach from=$customGroups item=group name=groupLoop}
          <div class="custom-group" data-width="{$group.layout_width}" data-float="{$group.layout_float}"style="width: {$group.layout_width}%;float: {if $group.layout_float == 'left'}left{elseif $group.layout_float == 'right'}right{else}none{/if};">
          <div class="crm-block crm-content-block crm-records-listing crm-multivalue-selector-{$group.id}">
            <div class="crm-accordion-wrapper crm-custom-accordion collapsed" data-group-id="{$group.id}">
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
    .crm-custom-data-grouped {
      display: flex;
      flex-wrap: wrap;
      gap: 15px;
    }

    .crm-custom-data-grouped.float-left .custom-group[data-float="left"] {
      float: left;
    }

    .crm-custom-data-grouped.float-right .custom-group[data-float="right"] {
      float: right;
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
      user-select: none;
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

    @media (max-width: 768px) {
      .crm-custom-data-grouped .custom-group {
        width: 100% !important;
        float: none !important;
      }
    }
  </style>

<script type="text/javascript">
    {/literal}
    CRM.$(function($) {
      'use strict';

      // Flag to track if we've initialized
      var isInitialized = false;
      var initializationLock = false;

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
          // Disconnect existing observer if any
          var existingObserver = $container.data('mutationObserver');
          if (existingObserver) {
            existingObserver.disconnect();
          }

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
       * Initialize accordion click handlers
       */
      function initializeAccordions() {
        // Prevent double initialization
        if (initializationLock) {
          return;
        }

        initializationLock = true;

        // Remove ALL existing handlers first (using namespace)
        $('.crm-custom-accordion .crm-accordion-header').off('click.customAccordion');

        // Attach new handlers with namespace
        $('.crm-custom-accordion .crm-accordion-header').on('click.customAccordion', function(e) {
          // Prevent any default behavior and event bubbling
          e.preventDefault();
          e.stopPropagation();
          e.stopImmediatePropagation();

          var $accordion = $(this).closest('.crm-custom-accordion');
          var $content = $accordion.find('.crm-custom-data-content');

          $accordion.toggleClass('collapsed');

          // Load content if opening and not yet loaded
          if (!$accordion.hasClass('collapsed')) {
            loadCustomGroup($content);
          }
        });

        // Mark as initialized
        isInitialized = true;

        // Release lock after short delay
        setTimeout(function() {
          initializationLock = false;
        }, 500);
      }

      /**
       * Initial load: Load the first (open) accordion
       */
      function initialLoad() {
        $('.crm-custom-accordion.open .crm-custom-data-content').each(function() {
          loadCustomGroup($(this));
        });
      }

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

      // Initialize on page load
      if (!isInitialized) {
        initializeAccordions();
        initialLoad();
      }

      // Re-initialize when tab becomes visible
      // Method 1: CiviCRM's crmLoad event
      $(document).on('crmLoad', '.crm-custom-data-grouped', function() {
        if (!initializationLock) {
          setTimeout(function() {
            initializeAccordions();
          }, 100);
        }
      });

      // Method 2: jQuery UI tabs events
      $(document).on('tabsactivate tabsshow', function(event, ui) {
        if (ui.newPanel && ui.newPanel.find('.crm-custom-data-grouped').length > 0) {
          if (!initializationLock) {
            setTimeout(function() {
              initializeAccordions();
            }, 100);
          }
        }
      });

      // Method 3: Visibility change detection
      if (typeof IntersectionObserver !== 'undefined') {
        var visibilityObserver = new IntersectionObserver(function(entries) {
          entries.forEach(function(entry) {
            if (entry.isIntersecting && !initializationLock) {
              setTimeout(function() {
                initializeAccordions();
              }, 100);
            }
          });
        }, { threshold: 0.1 });

        $('.crm-custom-data-grouped').each(function() {
          visibilityObserver.observe(this);
        });
      }
    });
    {literal}
</script>
{/literal}
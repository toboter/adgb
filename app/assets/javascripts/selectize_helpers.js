/*global $*/
// Shared Selectize init helpers for @selectize/selectize 0.15 + Cocoon / Bootstrap modals.
window.AdgbSelectize = {
  uninitialized: function ($els) {
    return $($els).filter(function () {
      return !this.selectize;
    });
  },

  revealInput: function (instance) {
    if (!instance || !instance.$control_input) return;
    instance.showInput();
    instance.$control_input.css({
      opacity: 1,
      position: "relative",
      left: 0,
      maxWidth: "none"
    });
    instance.$control_input.data("grow", true);
    // Re-measure placeholder width after the control is visible.
    instance.$control_input.trigger("update");
    if (instance.updatePlaceholder) instance.updatePlaceholder();
  },

  defaults: function (extra) {
    var self = this;
    return $.extend(
      {
        dropdownParent: "body",
        allowEmptyOption: true,
        hideSelected: false,
        onInitialize: function () {
          self.revealInput(this);
        },
        onFocus: function () {
          self.revealInput(this);
        },
        onType: function () {
          self.revealInput(this);
        },
        onDropdownOpen: function ($dropdown) {
          $dropdown.css("z-index", 2000);
        }
      },
      extra || {}
    );
  },

  init: function ($els, options) {
    return this.uninitialized($els).selectize(this.defaults(options));
  },

  initWhenVisible: function ($els, options) {
    var $targets = $($els);
    $targets.each(function () {
      if (this.selectize) {
        AdgbSelectize.revealInput(this.selectize);
      }
    });
    return this.init($targets, options);
  },

  // True when the element is inside a Bootstrap modal that is not yet shown.
  inHiddenModal: function ($el) {
    var $modal = $($el).closest(".modal");
    return $modal.length > 0 && !$modal.hasClass("in") && !$modal.hasClass("show");
  },

  visibleIn: function ($scope, selector) {
    return $scope.find(selector).filter(function () {
      return !AdgbSelectize.inHiddenModal(this);
    });
  },

  // Re-run all known Selectize setups inside a container (modals, cocoon rows, AJAX).
  boot: function ($root) {
    var $scope = $root && $root.length ? $root : $(document);

    if (typeof selectize_concepts === "function") {
      selectize_concepts(this.visibleIn($scope, ".concepts_selectize"));
    }
    if (typeof selectize_source === "function") {
      selectize_source(this.visibleIn($scope, ".source_id"));
    }
    if (typeof selectize_literature_item === "function") {
      selectize_literature_item(this.visibleIn($scope, ".literature_items"));
    }
    if (typeof selectize_biblio_search === "function") {
      selectize_biblio_search(
        this.visibleIn($scope, "#literature_item_biblio_data, .biblio_search")
      );
    }
    if (typeof initShareToSelectize === "function") {
      var $share = this.visibleIn($scope, "#share_to");
      if ($share.length) {
        initShareToSelectize($share.first().closest(".modal, form, body"));
      }
    }

    this.init(this.visibleIn($scope, ".user_group_list_item"), {
      plugins: ["remove_button"]
    });
    this.init(this.visibleIn($scope, "#source_archive_name, .archive_name_selectize"), {
      create: true,
      placeholder: "Archive…"
    });
  }
};

$(document).on("turbolinks:load", function () {
  AdgbSelectize.boot($(document));
});

$(document).on("cocoon:after-insert", function (_e, insertedItem) {
  AdgbSelectize.boot($(insertedItem));
});

// Modal content is often injected while hidden; init after it is visible.
$(document).on("shown.bs.modal", ".modal", function () {
  AdgbSelectize.boot($(this));
});

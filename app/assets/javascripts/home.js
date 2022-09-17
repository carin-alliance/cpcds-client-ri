(function ($) {
	window.landing = {
		patientFilter: function () {
			dirtySearchTerms = $("input.patient-filter").val().split(/\s+/);
			searchTerms = dirtySearchTerms.filter(function (el) {
				return el;
			});
			if (searchTerms.length == 0) {
				$(".patient-option").each(function () {
					if (!$(this).hasClass("show")) $(this).addClass("show");
				});
			} else {
				$(".patient-option").each(function () {
					text = $(this).text();
					matches = true;
					searchTerms.forEach(function (term) {
						if (matches)
							matches = text.toUpperCase().includes(term.toUpperCase());
					});
					if (matches) {
						if (!$(this).hasClass("show")) $(this).addClass("show");
					} else {
						$(this).removeClass("show");
					}
				});
			}
		},

		patientFilterListener: function () {
			$("input.patient-filter").on("keyup", window.landing.patientFilter);
		},

		eobTypeFilterListener: function () {
			$(document).on(
				"change",
				"#claim-type, #claim-status, #claim-provider, #claim-daterange",
				function () {
					$("#no-result").removeClass("d-flex");
					$("#no-result").addClass("d-none");
					var value = $(this).find(":selected").val().toLowerCase();
					var text = $(this).find(":selected").text();
					if (this.id == "claim-provider") {
						$("#eob-list article").each(function () {
							if ($(this).text().indexOf(text) > -1) $(this).addClass(value);
						});
					} else if (this.id == "claim-daterange") {
						switch (value) {
							case "currentyear":
								text = new Date().getFullYear().toString();
								break;
							case "lastyear":
								text = (new Date().getFullYear() - 1).toString();
						}

						$("#eob-list article").each(function () {
							if ($(this).text().indexOf(text) > -1) $(this).addClass(value);
						});
					}
					var selected = $("select").map(function () {
						return $(this).find(":selected").val().toLowerCase().trim();
					});
					var all_equals = true;
					for (let index = 0; index < selected.length; index++) {
						all_equals = selected[index] == "all";
						if (!all_equals) break;
					}
					var shownElements = 0;
					if (all_equals) {
						shownElements++;
						$("#total-claims").show();
						$("#eob-list article").show();
					} else {
						$("#total-claims").hide();
						$("#eob-list article").hide();
						$("#eob-list article").each(function () {
							if (
								$(this).hasClass(selected[0]) &&
								$(this).hasClass(selected[1]) &&
								$(this).hasClass(selected[2]) &&
								$(this).hasClass(selected[3])
							) {
								shownElements++;
								$(this).show();
							}
						});
					}
					if (shownElements == 0) {
						$("#no-result").removeClass("d-none");
						$("#no-result").addClass("d-flex");
					}
				}
			);
		},
	};

	$(document).on("turbolinks:load", window.landing.patientFilterListener);
	$(document).on("turbolinks:load", window.landing.eobTypeFilterListener);
})(jQuery);

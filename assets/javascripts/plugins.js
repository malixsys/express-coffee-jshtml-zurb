; (function (a) { a.backstretch = function (l, b, j) { function m(c) { try { h = { left: 0, top: 0 }, e = f.width(), d = e / k, d >= f.height() ? (i = (d - f.height()) / 2, g.centeredY && a.extend(h, { top: "-" + i + "px" })) : (d = f.height(), e = d * k, i = (e - f.width()) / 2, g.centeredX && a.extend(h, { left: "-" + i + "px" })), a("#backstretch, #backstretch img:not(.deleteable)").width(e).height(d).filter("img").css(h) } catch (b) { } "function" == typeof c && c() } var n = { centeredX: !0, centeredY: !0, speed: 0 }, c = a("#backstretch"), g = c.data("settings") || n; c.data("settings"); var f = "onorientationchange" in window ? a(document) : a(window), k, e, d, i, h; b && "object" == typeof b && a.extend(g, b); b && "function" == typeof b && (j = b); a(document).ready(function () { if (l) { var b; 0 == c.length ? c = a("<div />").attr("id", "backstretch").css({ left: 0, top: 0, position: "fixed", overflow: "hidden", zIndex: -999999, margin: 0, padding: 0, height: "100%", width: "100%" }) : c.find("img").addClass("deleteable"); b = a("<img />").css({ position: "absolute", display: "none", margin: 0, padding: 0, border: "none", zIndex: -999999 }).bind("load", function (b) { var d = a(this), e; d.css({ width: "auto", height: "auto" }); e = this.width || a(b.target).width(); b = this.height || a(b.target).height(); k = e / b; m(function () { d.fadeIn(g.speed, function () { c.find(".deleteable").remove(); "function" == typeof j && j() }) }) }).appendTo(c); 0 == a("body #backstretch").length && a("body").append(c); c.data("settings", g); b.attr("src", l); a(window).resize(m) } }); return this } })(jQuery);

/*
 * jQuery dropdown: A simple dropdown plugin
 *
 * Inspired by Bootstrap: http://twitter.github.com/bootstrap/javascript.html#dropdowns
 *
 * Copyright 2011 Cory LaViska for A Beautiful Site, LLC. (http://abeautifulsite.net/)
 *
 * Dual licensed under the MIT or GPL Version 2 licenses
 *
*/
if(jQuery) (function($) {
  
	$.extend($.fn, {
		dropdown: function(method, data) {
			
			switch( method ) {
				case 'hide':
					hideDropdowns();
					return $(this);
				case 'attach':
					return $(this).attr('data-dropdown', data);
				case 'detach':
					hideDropdowns();
					return $(this).removeAttr('data-dropdown');
				case 'disable':
					return $(this).addClass('dropdown-disabled');
				case 'enable':
					hideDropdowns();
					return $(this).removeClass('dropdown-disabled');
			}
			
		}
	});
	
	function showMenu(event) {
		
		var trigger = $(this),
			dropdown = $( $(this).attr('data-dropdown') ),
			isOpen = trigger.hasClass('dropdown-open'),
			hOffset = parseInt($(this).attr('data-horizontal-offset') || 0),
			vOffset = parseInt($(this).attr('data-vertical-offset') || 0);
		
		if( trigger !== event.target && $(event.target).hasClass('dropdown-ignore') ) return;
		
		event.preventDefault();
		event.stopPropagation();
		
		hideDropdowns();
		
		if( isOpen || trigger.hasClass('dropdown-disabled') ) return;
		
		dropdown
			.css({
				left: dropdown.hasClass('anchor-right') ? 
					trigger.offset().left - (dropdown.outerWidth() - trigger.outerWidth()) + hOffset : trigger.offset().left + hOffset,
				top: trigger.offset().top + trigger.outerHeight() + vOffset
			})
			.show();
		
    $('i', trigger).removeClass("icon-reorder").addClass("icon-caret-down");
		trigger.addClass('dropdown-open');
		
	};
	
	function hideDropdowns(event) {
		
		var targetGroup = event ? $(event.target).parents().andSelf() : null;
		if( targetGroup && targetGroup.is('.dropdown-menu') && !targetGroup.is('A') ) return;
		
		$('BODY')
			.find('.dropdown-menu').hide().end()
			.find('[data-dropdown]').removeClass('dropdown-open')
      .find('i').removeClass("icon-caret-down").addClass("icon-reorder");
    
	};
	
	$(function () {
		$('BODY').on('click.dropdown', '[data-dropdown]', showMenu);
		$('HTML').on('click.dropdown', hideDropdowns);
		// Hide on resize (IE7/8 trigger this when any element is resized...)
		if( !$.browser.msie || ($.browser.msie && $.browser.version >= 9) ) {
			$(window).on('resize.dropdown', hideDropdowns);
		}
	});
	
})(jQuery);


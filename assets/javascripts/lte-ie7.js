/* Use this script if you need to support IE 7 and IE 6. */

window.onload = function() {
	function addIcon(el, entity) {
		var html = el.innerHTML;
		el.innerHTML = '<span style="font-family: \'ecjz\'">' + entity + '</span>' + html;
	}
	var icons = {
			'icon-ecjz-calendar' : '&#xe005;',
			'icon-ecjz-disk' : '&#xe009;',
			'icon-ecjz-bubbles' : '&#xe00a;',
			'icon-ecjz-home' : '&#xe000;',
			'icon-ecjz-pencil' : '&#xe001;',
			'icon-ecjz-image' : '&#xe002;',
			'icon-ecjz-images' : '&#xe003;',
			'icon-ecjz-file-upload' : '&#xe004;',
			'icon-ecjz-phone' : '&#xe008;',
			'icon-ecjz-envelop' : '&#xe006;',
			'icon-ecjz-direction' : '&#xe007;',
			'icon-ecjz-user' : '&#xe00b;',
			'icon-ecjz-users' : '&#xe00c;',
			'icon-ecjz-user-plus' : '&#xe00d;',
			'icon-ecjz-user-block' : '&#xe01a;',
			'icon-ecjz-spinner' : '&#xe00e;',
			'icon-ecjz-vcard' : '&#xe00f;',
			'icon-ecjz-key' : '&#xe010;',
			'icon-ecjz-cog' : '&#xe011;',
			'icon-ecjz-lock' : '&#xe012;',
			'icon-ecjz-unlocked' : '&#xe013;',
			'icon-ecjz-paw' : '&#xe014;',
			'icon-ecjz-remove' : '&#xe015;',
			'icon-ecjz-truck' : '&#xe016;',
			'icon-ecjz-switch' : '&#xe01d;',
			'icon-ecjz-menu' : '&#xe017;',
			'icon-ecjz-earth' : '&#xe018;',
			'icon-ecjz-star' : '&#xe019;',
			'icon-ecjz-star-2' : '&#xe01b;',
			'icon-ecjz-star-3' : '&#xe01c;',
			'icon-ecjz-thumbs-up' : '&#xe01e;',
			'icon-ecjz-thumbs-up-2' : '&#xe01f;',
			'icon-ecjz-close' : '&#xe020;',
			'icon-ecjz-checkmark' : '&#xe021;',
			'icon-ecjz-minus' : '&#xe022;',
			'icon-ecjz-plus' : '&#xe023;',
			'icon-ecjz-enter' : '&#xe024;',
			'icon-ecjz-exit' : '&#xe025;',
			'icon-ecjz-arrow-up' : '&#xe026;',
			'icon-ecjz-arrow-right' : '&#xe027;',
			'icon-ecjz-arrow-down' : '&#xe028;',
			'icon-ecjz-arrow-left' : '&#xe029;',
			'icon-ecjz-checkbox' : '&#xe02a;',
			'icon-ecjz-checkbox-unchecked' : '&#xe02b;',
			'icon-ecjz-google' : '&#xe031;',
			'icon-ecjz-new-tab' : '&#xe02c;',
			'icon-ecjz-seven-segment-0' : '&#xe02d;',
			'icon-ecjz-seven-segment-1' : '&#xe02e;',
			'icon-ecjz-seven-segment-2' : '&#xe02f;',
			'icon-ecjz-seven-segment-3' : '&#xe030;',
			'icon-ecjz-seven-segment-4' : '&#xe032;',
			'icon-ecjz-seven-segment-5' : '&#xe033;',
			'icon-ecjz-seven-segment-6' : '&#xe034;',
			'icon-ecjz-seven-segment-7' : '&#xe035;',
			'icon-ecjz-seven-segment-8' : '&#xe036;',
			'icon-ecjz-seven-segment-9' : '&#xe037;'
		},
		els = document.getElementsByTagName('*'),
		i, attr, html, c, el;
	for (i = 0; i < els.length; i += 1) {
		el = els[i];
		attr = el.getAttribute('data-icon');
		if (attr) {
			addIcon(el, attr);
		}
		c = el.className;
		c = c.match(/icon-ecjz-[^\s'"]+/);
		if (c && icons[c[0]]) {
			addIcon(el, icons[c[0]]);
		}
	}
};

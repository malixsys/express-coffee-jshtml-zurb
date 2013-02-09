  $.validator.addMethod('postalCodeCanada', function (value) { 
      return /^([ABCEGHJKLMNPRSTVXY]\d[ABCEGHJKLMNPRSTVWXYZ]) ?(\d[ABCEGHJKLMNPRSTVWXYZ]\d)$/i.test(value); 
  });
  
  $.validator.addMethod('fullName', function (value) { 
      return /^(?:[\u00c0-\u01ffa-zA-Z'-]){2,}(?:\s[\u00c0-\u01ffa-zA-Z'-]{2,})+$/i.test(value); 
  });

  jQuery.validator.addMethod("phoneNA", function(phone_number, element) {
      phone_number = phone_number.replace(/\s+/g, "");
      return this.optional(element) || phone_number.length > 9 &&
          phone_number.match(/^\D?([2-9]\d{2})\D?\D?([2-9]\d{2})\D?(\d{4})$/);
  });

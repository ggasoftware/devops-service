define ([

  'backbone'

], function(Backbone) {

  'use strict';
  return Backbone.Model.extend({
	
		parse: function(res) {
			return {
				displayName: res,
				keyName: res
			};
		}

  });

});

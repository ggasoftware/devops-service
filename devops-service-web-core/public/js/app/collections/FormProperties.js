define([

  'jquery',
  'backbone',

  'models/Flavor',

  'App',

  'models/FormProperty'

], function ($, Backbone, Flavor, App, FormProperty) {

  'use strict';

  return Backbone.Collection.extend({

    model: FormProperty,

    restrictedFields: function () {
      return {
        image: 'ami-8c51e3e4',
        group: 'default',
        subnet: 'subnet-63f5be4b',
        flavor: 't2.micro'
      };
    },

    initialize: function (models, options) {
      var env = options.deployEnv;
      var envIndex = env.collection.indexOf(env);
      var deps = options.deps;
      var isOpenstack = env.get('provider') === 'openstack';
      var self = this;
      // var denvsString = 'deploy_envs[' + env.get('identifier') + '][]';
      var denvsString = function (arg, pFix) {
        var pFixSym = '';
        if (pFix) {
          pFixSym = '[]';
        }
        return 'deploy_envs[' + envIndex + '][' + arg + ']' + pFixSym;
      };

      var isLowerThanLevel3 = function () {
        var aLevels = App.request('get:accessLevels');
        if (aLevels.level3()) {
          return false;
        }
        return true;
      };

      var isLowerThanLevel2 = function () {
        var aLevels = App.request('get:accessLevels');
        if (aLevels.level2()) {
          return false;
        }
        return true;
      };

      this.set([

        {
          id: denvsString('identifier'),
          list: App.options.envNames,
          type: 'field',
          label: 'identifier',
          value: env.get('identifier')
        },

        {
          id: denvsString('chef_env'),
          list: deps.chefEnvs,
          type: 'list',
          label: 'chef env',
          value: env.get('chef_env')
        },

        {
          id: denvsString('provider'),
          type: 'list',
          list: deps.providers,
          children: [
            denvsString('groups', true),
            denvsString('subnets', true),
            denvsString('image'),
            denvsString('flavor')

          ],
          label: 'provider',
          value: env.get('provider')
        },


        {
          id: denvsString('run_list', true),
          type: 'field',
          label: 'runlist',
          value: env.get('run_list')
        },

        {
          id: denvsString('expires'),
          type: 'field',
          label: 'expires',
          value: env.get('expires')
        },

        {
          id: denvsString('users', true),
          type: 'field',
          label: 'users',
          value: env.get('users'),
          hidden: isLowerThanLevel2()
        },

        {
          id: denvsString('groups', true),
          type: 'list',
          list: isOpenstack ? deps.groups : deps.groups,
          openstackList: deps.groups,
          ec2List: deps.groups,
          staticList: [],
          label: 'group',
          value: self.restrictedFields().group,
          hidden: isLowerThanLevel3()
        },

        {
          id: denvsString('subnets', true),
          type: 'list',
          list: isOpenstack ? deps.networks : deps.networks,
          openstackList: deps.networks,
          ec2List: deps.networks,
          staticList: [],
          label: 'subnets',
          value: self.restrictedFields().subnet,
          hidden: isLowerThanLevel3()
        },

        {
          id: denvsString('image'),
          type: 'list',
          list: isOpenstack ? deps.images : deps.images,
          openstackList: deps.images,
          staticList: [],
          ec2List: deps.images,
          label: 'image',
          value: env.get('image') || self.restrictedFields().image,
          hidden: isLowerThanLevel3()
        },

        {
          id: denvsString('flavor'),
          type: 'list',
          //list : isOpenstack ? ac.Flavors._openstack : ac.Flavors._EC2,
          list: deps.flavors,
          openstackList: deps.flavors, //App.flavors_openstack,
          ec2List: deps.flavors,
          staticList: [],
          label: 'flavor',
          value: env.get('flavor') || self.restrictedFields().flavor,
          hidden: isLowerThanLevel3()
        }

        //TODO temporary disabled
        /*        { id: "deploy_envs[][users][]",*/
        //type: "list",
        //list: App.users,
        //label: 'Users',
        /*value: env.get('users') },*/

        /*   {*/
        //id : 'deploy_envs[][chef_env]',
        //type : 'list',
        //list : ac.ChefServerEnvironments,
        //label : 'ChefEnv',
        //value : env.get('displayName')
        /*},*/

      ]);

    }

  });

});


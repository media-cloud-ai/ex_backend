exports.config = {
  // See http://brunch.io/#documentation for docs.
  files: {
    javascripts: {
      // To use a separate vendor.js bundle, specify two files path
      // http://brunch.io/docs/config#-files-
      joinTo: {
        "js/app.js": /^js/,
        "js/vendor.js": /^(?!js)/
      },
      //
      // To change the order of concatenation of files, explicitly mention here
      // order: {
      //   after: [
      //     "js/app.js",
      //   ]
      // }
    },
    stylesheets: {
      joinTo: "css/app.css",
      order: {
        after: ["priv/static/css/app.scss"] // concat app.css last
      }
    },
    templates: {
      joinTo: "js/app.js"
    }
  },

  conventions: {
    // This option sets where we should place non-css and non-js assets in.
    // By default, we set this to "/assets/static". Files in this directory
    // will be copied to `paths.public`, which is "priv/static" by default.
    assets: /^(static)/
    // /^(node_modules/font-awesome)/
  },

  // Phoenix paths configuration
  paths: {
    // Dependencies and current project directories to watch
    watched: [
      "static",
      "css",
      "js",
      "vendor",
      'node_modules/font-awesome/fonts/fontawesome-webfont.eot',
      'node_modules/font-awesome/fonts/fontawesome-webfont.svg',
      'node_modules/font-awesome/fonts/fontawesome-webfont.ttf',
      'node_modules/font-awesome/fonts/fontawesome-webfont.woff',
      'node_modules/font-awesome/fonts/fontawesome-webfont.woff2',
    ],
    // Where to compile files to
    public: "../priv/static"
  },

  // Configure your plugins
  plugins: {
    babel: {
      // Do not use ES6 compiler in vendor code
      ignore: [/vendor/]
    },
    copycat: {
      "fonts": ["node_modules/font-awesome/fonts"] // copy node_modules/font-awesome/fonts/* to priv/static/fonts/
    },
    sass: {
      options: {
        includePaths: ["node_modules/font-awesome/scss"], // tell sass-brunch where to look for files to @import
      }
    }
  },

  modules: {
    autoRequire: {
      "js/app.js": ["js/app"]
    }
  },

  npm: {
    enabled: true,
    globals: {
      $: 'jquery',
      jQuery: 'jquery',
      angular: 'angular',
      ngResource: 'angular-resource'
    }
  }
};
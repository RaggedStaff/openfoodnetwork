// config/swc.config.js
// This file is merged with Shakapacker's default SWC configuration
// See: https://swc.rs/docs/configuration/compilation

const { env } = require('shakapacker');

module.exports = {
  options: {
    jsc: {
      // CRITICAL for Stimulus compatibility: Prevents SWC from mangling class names
      // which breaks Stimulus's class-based controller discovery mechanism
      keepClassNames: true,
      transform: {
        react: {
          runtime: 'automatic',
          refresh: env.isDevelopment && env.runningWebpackDevServer,
        },
      },
    },
    // Browserslist config, needed because SWC doesn't automatically pickup browserslist config: https://github.com/swc-project/swc/issues/3365
    env: {
      targets: [ "defaults", "not IE 11" ],
    },
  },
};

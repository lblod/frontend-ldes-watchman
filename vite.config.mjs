import { defineConfig } from 'vite';
import { extensions, classicEmberSupport, ember } from '@embroider/vite';
import { babel } from '@rollup/plugin-babel';
const LOCAL_PATHS = [
  /^\/(\?.*)?$/,
  /^\/index\.html/,
  /^\/statistics/,
  /^\/@vite/,
  /^\/vite/,
  /\/[-@]?embroider/,
  /\/@embroider/,
  /^\/app\//,
  /^\/assets/,
  /^\/node_modules\//,
  /^\/vendor\//,
  /^\/component-library/,
];

const fixAppuniversumAssets = () => ({
  name: 'fix-appuniversum-asset-path',
  configureServer(server) {
    server.middlewares.use((req, _res, next) => {
      if (req.url?.startsWith('/@embroider/@appuniversum/')) {
        req.url = req.url.replace(
          '/@embroider/@appuniversum/',
          '/@appuniversum/',
        );
      }
      next();
    });
  },
});

export default defineConfig({
  plugins: [
    classicEmberSupport(),
    fixAppuniversumAssets(),
    ember(),
    // extra plugins here
    babel({
      babelHelpers: 'runtime',
      extensions,
    }),
  ],
  server: {
    host: '0.0.0.0',
    port: 4200,
    proxy: {
      '/': {
        target: 'http://dispatcher',
        changeOrigin: false,
        secure: false,
        ws: true,
        bypass(req) {
          if (
            req.headers.upgrade === 'websocket' &&
            req.headers['sec-websocket-protocol'] === 'vite-hmr'
          ) {
            return req.url;
          }
          if (LOCAL_PATHS.some((re) => re.test(req.url))) {
            return req.url;
          }
          return null;
        },
      },
    },
    hmr: {
      clientPort: 4200,
    },
  },
});

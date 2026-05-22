module.exports = {
  apps: [
    {
      name: 'mycelium-api',
      script: 'C:\\mycelium\\src\\index.js',
      node_args: '--env-file C:\\mycelium\\.env',
    },
    {
      name: 'lostfound-api',
      script: 'C:\\lostfound\\src\\index.js',
    },
  ],
};

import http from 'node:http';

const PORT = 8081;
const TARGET_HOST = '127.0.0.1';
const TARGET_PORT = 8080;

const server = http.createServer((req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader(
    'Access-Control-Allow-Methods',
    'GET, POST, PUT, DELETE, PATCH, OPTIONS'
  );
  res.setHeader(
    'Access-Control-Allow-Headers',
    'Content-Type, Authorization'
  );

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  const options = {
    hostname: TARGET_HOST,
    port: TARGET_PORT,
    path: req.url,
    method: req.method,
    headers: {
      ...req.headers,
      host: `${TARGET_HOST}:${TARGET_PORT}`,
    },
  };

  const proxyReq = http.request(options, (proxyRes) => {
    const headers = {
      ...proxyRes.headers,
      'access-control-allow-origin': '*',
      'access-control-allow-methods':
        'GET, POST, PUT, DELETE, PATCH, OPTIONS',
      'access-control-allow-headers':
        'Content-Type, Authorization',
    };

    res.writeHead(proxyRes.statusCode ?? 500, headers);
    proxyRes.pipe(res);
  });

  proxyReq.on('error', (error) => {
    console.error('Proxy error:', error.message);

    res.writeHead(502, {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
    });

    res.end(
      JSON.stringify({
        error: 'Cannot connect to OwlBank backend',
      })
    );
  });

  req.pipe(proxyReq);
});

server.listen(PORT, () => {
  console.log(`OwlBank proxy running on http://localhost:${PORT}`);
  console.log(
    `Forwarding requests to http://${TARGET_HOST}:${TARGET_PORT}`
  );
});
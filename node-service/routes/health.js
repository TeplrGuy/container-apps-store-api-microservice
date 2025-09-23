var express = require('express');
var router = express.Router();
const axios = require('axios').default;

const daprPort = process.env.DAPR_HTTP_PORT || 3500;
const daprSidecar = `http://localhost:${daprPort}`;

let startupComplete = false;

// background dependency checks (simple, non-blocking)
async function checkDeps() {
  const maxAttempts = 30;
  let attempt = 0;
  while (attempt < maxAttempts && !startupComplete) {
    try {
      // check dapr sidecar health endpoint
      const r = await axios.get(`${daprSidecar}/v1.0/healthz` , { timeout: 2000 });
      if (r && r.status === 200) {
        startupComplete = true;
        break;
      }
    } catch (e) {
      // ignore and retry
    }
    attempt++;
    await new Promise(res => setTimeout(res, 2000));
  }
}

// start background check without blocking app startup
checkDeps();

// Liveness: very cheap check to see process is alive
router.get('/live', function(req, res) {
  res.sendStatus(200);
});

// Readiness: check that dapr sidecar (and therefore service discovery) is reachable
router.get('/ready', async function(req, res) {
  try {
    const r = await axios.get(`${daprSidecar}/v1.0/healthz`, { timeout: 2000 });
    if (r && r.status === 200) {
      res.sendStatus(200);
    } else {
      res.sendStatus(503);
    }
  } catch (e) {
    res.sendStatus(503);
  }
});

// Startup: returns 200 only after background initialization completes
router.get('/startup', function(req, res) {
  if (startupComplete) {
    res.sendStatus(200);
  } else {
    res.sendStatus(503);
  }
});

module.exports = router;

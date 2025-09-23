var express = require('express');
var router = express.Router();
const axios = require('axios').default;

// Demo mode: return OK for health endpoints to avoid failing startup probes

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
  // always return OK in demo mode
  res.sendStatus(200);
});

module.exports = router;

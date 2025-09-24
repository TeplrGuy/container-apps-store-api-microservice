var express = require('express');
var router = express.Router();
const axios = require('axios').default;

// Demo mode: return OK for health endpoints to avoid failing startup probes
// Doc: https://learn.microsoft.com/en-us/azure/container-apps/health-probes?tabs=arm-template#default-configuration
// Default config: https://learn.microsoft.com/en-us/azure/container-apps/health-probes?tabs=arm-template#default-configuration

// Liveness: Checks to see if a replica is ready to handle incoming requests.
router.get('/live', function(req, res) {

  // check for database availability
  // check filesystem structure
  //  etc.

  // always return OK in demo mode
  
  res.sendStatus(200);
});

// Readiness: Checks to see if a replica is ready to handle incoming requests.
router.get('/ready', async function(req, res) {
  // always return OK in demo mode
    res.sendStatus(200);
});

// Startup: Checks if your application has successfully started. 
// This check is separate from the liveness probe and executes during the initial startup phase of your application.
router.get('/startup', function(req, res) {
  // always return OK in demo mode
  res.sendStatus(200);
});

module.exports = router;

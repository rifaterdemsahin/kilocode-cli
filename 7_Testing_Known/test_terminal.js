#!/usr/bin/env node
/**
 * 🧪 Test Suite: Kilo Terminal (terminal.html)
 *
 * Validates structure, security, and optionally tests live API connectivity.
 *
 * Usage:
 *   node test_terminal.js                  # structure tests only
 *   KILO_API_KEY=xxx node test_terminal.js # structure + live API ping
 */

const fs = require('fs');
const https = require('https');
const path = require('path');

const HTML_PATH = path.join(__dirname, '..', 'terminal.html');
const html = fs.readFileSync(HTML_PATH, 'utf8');

let passed = 0;
let failed = 0;

function check(name, condition) {
  if (condition) {
    passed++;
    console.log('✅', name);
  } else {
    failed++;
    console.log('❌', name);
  }
}

console.log('=== Kilo Terminal Test Suite ===\n');

// ── Structure Tests ──
console.log('📐 Structure Tests');
check('HTML has DOCTYPE', html.includes('<!DOCTYPE html>'));
check('Has <title>', /<title>.*<\/title>/i.test(html));
check('Has viewport meta', html.includes('viewport'));
check('Has STORAGE_KEY constant', html.includes("STORAGE_KEY = 'kilo_api_key'"));
check('Has localStorage getter', html.includes('localStorage.getItem'));
check('Has localStorage setter', html.includes('localStorage.setItem'));
check('Has clearKey function', html.includes('function clearKey'));
check('Has saveKey function', html.includes('function saveKey'));
check('Has setCmd function', html.includes('function setCmd'));
check('Has copyCmd function', html.includes('function copyCmd'));
check('Has openModal function', html.includes('function openModal'));
check('Has closeModal function', html.includes('function closeModal'));
check('Has modal overlay element', html.includes('modal-overlay'));
check('Has terminal body element', html.includes('term-body'));
check('Has command input element', html.includes('cmd-input'));
check('Has current command display', html.includes('current-cmd'));
check('Has toast notification', html.includes('toast'));
check('Has key status badge', html.includes('key-badge'));
check('Links back to index.html', html.includes('index.html'));
check('Links to markdown_renderer', html.includes('markdown_renderer.html'));

// ── Security Tests ──
console.log('\n🔒 Security Tests');
check('No eval() calls', !html.includes('eval('));
check('No hardcoded JWT placeholder', !html.includes('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'));
check('No document.write()', !html.includes('document.write'));
check('No inline event handlers with javascript:', !html.includes('javascript:'));

// ── Accessibility / UX Tests ──
console.log('\n♿ UX Tests');
check('Has placeholder on API key input', html.includes('placeholder='));
check('Has autocomplete=off on input', html.includes('autocomplete="off"'));
check('Has spellcheck=false on input', html.includes('spellcheck="false"'));

// ── Live API Test (optional) ──
const API_KEY = process.env.KILO_API_KEY || '';
if (API_KEY) {
  console.log('\n🌐 Live API Test (KILO_API_KEY is set)');
  check('API key length > 20', API_KEY.length > 20);

  // Simple connectivity test to kilo.ai
  const options = {
    hostname: 'app.kilo.ai',
    port: 443,
    path: '/',
    method: 'HEAD',
    timeout: 10000,
  };

  const req = https.request(options, (res) => {
    const ok = res.statusCode >= 200 && res.statusCode < 500;
    check(`kilo.ai reachable (HTTP ${res.statusCode})`, ok);
    printSummary();
  });

  req.on('error', (err) => {
    console.log('⚠️  API connectivity test failed:', err.message);
    failed++;
    printSummary();
  });

  req.end();
} else {
  console.log('\n⏭️  Skipping live API test — set KILO_API_KEY to enable');
  printSummary();
}

function printSummary() {
  console.log(`\n=== Results: ${passed} passed, ${failed} failed ===`);
  process.exit(failed > 0 ? 1 : 0);
}

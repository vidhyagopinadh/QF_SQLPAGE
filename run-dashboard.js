#!/usr/bin/env node
/**
 * QualityFolio Backend - CORRECTED WORKING VERSION
 * 
 * IMPORTANT: Commands run from /qualityfolio directory!
 * Run this from project root
 * 
 * Usage:
 * node run-dashboard.js
 */

const http = require('http');
const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

// Get the qualityfolio directory
const rootDir = process.cwd();
const qualityfolioDir = path.join(rootDir, 'qualityfolio');

console.log('\n╔════════════════════════════════════════════════╗');
console.log('║  QualityFolio Backend - CORRECTED              ║');
console.log('╚════════════════════════════════════════════════╝\n');

console.log(`Root Directory: ${rootDir}`);
console.log(`QualityFolio Directory: ${qualityfolioDir}`);

// Verify qualityfolio directory exists
if (!fs.existsSync(qualityfolioDir)) {
    console.error('\n❌ ERROR: /qualityfolio directory not found!');
    console.error(`Expected: ${qualityfolioDir}`);
    console.error('\nMake sure you run this from the parent directory of qualityfolio');
    process.exit(1);
}

console.log('✓ qualityfolio directory found\n');

const server = http.createServer((req, res) => {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    res.setHeader('Content-Type', 'application/json');

    if (req.method === 'OPTIONS') {
        res.writeHead(200);
        res.end();
        return;
    }

    if (req.url === '/api/start-dashboard' && req.method === 'POST') {
        console.log('\n' + '='.repeat(70));
        console.log('🚀 STARTING DASHBOARD SERVICES');
        console.log('='.repeat(70) + '\n');

        const commands = [
            {
                name: 'spry rb',
                cmd: 'spry rb run qualityfolio.md',
                cwd: qualityfolioDir,  // ✅ RUN FROM QUALITYFOLIO DIRECTORY
                description: 'Ruby/Spry process'
            },
            {
                name: 'spry sp spc',
                cmd: 'spry sp spc --fs dev-src.auto --destroy-first --conf sqlpage/sqlpage.json --md qualityfolio.md',
                cwd: qualityfolioDir,  // ✅ RUN FROM QUALITYFOLIO DIRECTORY
                description: 'SQLPage compilation'
            },
            {
                name: 'surveilr',
                cmd: 'EOH_INSTANCE=1 PORT=9227 surveilr web-ui -d ./resource-surveillance.sqlite.db --port 9227 --host 0.0.0.0',
                cwd: qualityfolioDir,  // ✅ RUN FROM QUALITYFOLIO DIRECTORY
                description: 'Surveilr dashboard on port 9227'
            },
        ];

        // Pre-flight checks
        console.log('PRE-FLIGHT CHECKS:');
        console.log('─'.repeat(70));

        commands.forEach((service) => {
            console.log(`\n${service.name} - ${service.description}`);
            console.log(`  Working Directory: ${service.cwd}`);
            console.log(`  Command: ${service.cmd}`);

            // Check if working directory exists
            if (fs.existsSync(service.cwd)) {
                console.log(`  ✓ Directory exists`);
            } else {
                console.log(`  ✗ Directory NOT found: ${service.cwd}`);
            }
        });

        console.log('\n' + '─'.repeat(70));
        console.log('STARTING PROCESSES:');
        console.log('─'.repeat(70) + '\n');

        let successCount = 0;
        let failureCount = 0;

        commands.forEach((service, i) => {
            console.log(`[${i + 1}/${commands.length}] ${service.name}`);
            console.log(`  Working from: ${service.cwd}`);
            console.log(`  Running: ${service.cmd}`);

            try {
                // Spawn process from the correct directory
                const child = spawn('bash', ['-c', service.cmd], {
                    cwd: service.cwd,  // ✅ KEY: Run from qualityfolio directory
                    detached: true,
                    stdio: ['ignore', 'inherit', 'inherit'],
                    shell: true,
                    env: Object.assign({}, process.env),
                });

                console.log(`  PID: ${child.pid}`);
                console.log(`  ✓ Process spawned successfully\n`);

                child.on('error', (err) => {
                    console.error(`  ✗ Error: ${err.message}`);
                    failureCount++;
                });

                child.unref();
                successCount++;

            } catch (error) {
                console.error(`  ✗ Exception: ${error.message}\n`);
                failureCount++;
            }
        });

        console.log('='.repeat(70));
        console.log(`✓ RESULT: ${successCount} started, ${failureCount} failed`);
        console.log('='.repeat(70) + '\n');

        console.log('NEXT STEPS:');
        console.log(`  1. Wait 30-60 seconds for services to start`);
        console.log(`  2. Check processes: ps aux | grep -E "spry|surveilr"`);
        console.log(`  3. Check port 9227: curl -I http://localhost:9227/`);
        console.log(`  4. If working, frontend will open dashboard automatically\n`);

        // Send response
        res.writeHead(200);
        res.end(JSON.stringify({
            success: successCount === commands.length,
            message: `Started ${successCount}/${commands.length} services from ${qualityfolioDir}`,
            started: successCount,
            failed: failureCount,
            timestamp: new Date().toISOString(),
        }));
    }

    else if (req.url === '/api/health' && req.method === 'GET') {
        res.writeHead(200);
        res.end(JSON.stringify({
            status: 'running',
            qualityfolioDir: qualityfolioDir,
            exists: fs.existsSync(qualityfolioDir),
        }));
    }

    else if (req.url === '/api/check-processes' && req.method === 'GET') {
        const { exec } = require('child_process');
        exec('ps aux | grep -E "spry|surveilr" | grep -v grep', (error, stdout, stderr) => {
            const processes = stdout.trim().split('\n').filter(p => p);
            res.writeHead(200);
            res.end(JSON.stringify({
                count: processes.length,
                processes: processes,
                timestamp: new Date().toISOString(),
            }));
        });
    }

    else if (req.url === '/api/check-port' && req.method === 'GET') {
        const { exec } = require('child_process');
        exec('curl -s -I http://localhost:9227/ 2>&1', (error, stdout, stderr) => {
            const isOpen = !error && stdout.includes('HTTP');
            res.writeHead(200);
            res.end(JSON.stringify({
                port: 9227,
                open: isOpen,
            }));
        });
    }

    else if (req.url === '/api/status' && req.method === 'GET') {
        res.writeHead(200);
        res.end(JSON.stringify({
            status: 'Backend running',
            qualityfolioDir: qualityfolioDir,
            endpoints: {
                'POST /api/start-dashboard': 'Start all services',
                'GET /api/health': 'Health check',
                'GET /api/check-processes': 'List running processes',
                'GET /api/check-port': 'Check port 9227',
            },
        }));
    }

    else {
        res.writeHead(404);
        res.end(JSON.stringify({ error: 'Not found' }));
    }
});

const PORT = 3000;
const HOST = 'localhost';

server.listen(PORT, HOST, () => {
    console.log('═'.repeat(70));
    console.log(`✓ Backend Server Running`);
    console.log('═'.repeat(70));
    console.log(`\nURL: http://${HOST}:${PORT}`);
    console.log(`Working Directory: ${qualityfolioDir}`);
    console.log(`\nEndpoints:`);
    console.log(`  POST http://localhost:3000/api/start-dashboard`);
    console.log(`  GET  http://localhost:3000/api/health`);
    console.log(`  GET  http://localhost:3000/api/check-processes`);
    console.log(`  GET  http://localhost:3000/api/check-port`);
    console.log(`\n✓ Ready! Click the dashboard button to start services...\n`);
    console.log('═'.repeat(70) + '\n');
});

process.on('SIGINT', () => {
    console.log('\nShutting down gracefully...');
    server.close(() => {
        console.log('Server stopped');
        process.exit(0);
    });
});
/**
 * Simple Express server to serve content files
 */
const express = require('express');
const path = require('path');
const cors = require('cors');
const app = express();
const port = 4202;

// Enable CORS for all routes
app.use(cors());

// Serve static files from the dist/browser directory (where webpack outputs files)
app.use(express.static(path.join(__dirname, 'dist/browser')));
app.use('/md-content', express.static(path.join(__dirname, 'dist/browser/md-content')));

// Special routes for content files with unconventional paths
app.get('/md-content*', (req, res) => {
    console.log(`Content server: Handling request for ${req.path}`);
    const filePath = path.join(__dirname, 'dist/browser', req.path);
    res.sendFile(filePath, err => {
        if (err) {
            console.error(`Error serving ${req.path}: ${err.message}`);

            // Try an alternative path without slashes
            const altPath = path.join(__dirname, 'dist/browser/md-content', req.path.replace('/md-content', ''));
            console.log(`Trying alternative path: ${altPath}`);

            res.sendFile(altPath, altErr => {
                if (altErr) {
                    console.error(`Error serving alternative path ${altPath}: ${altErr.message}`);
                    res.status(404).send(`File not found: ${req.path}`);
                }
            });
        }
    });
});

// Start the server
app.listen(port, () => {
    console.log(`Content server running at http://localhost:${port}`);
    console.log(`Try accessing: http://localhost:${port}/md-contentguide-intro/6024bf20223e39a0.json`);
});

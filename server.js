const express = require('express');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = 5000;

// Serve static files
app.use(express.static('web'));
app.use('/assets', express.static('assets'));

// Basic route for the Flutter app
app.get('/', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html>
    <head>
      <title>ITSM Mobile - Flutter App</title>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <style>
        body {
          font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
          margin: 0;
          padding: 20px;
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          min-height: 100vh;
          display: flex;
          justify-content: center;
          align-items: center;
        }
        .container {
          background: white;
          padding: 40px;
          border-radius: 10px;
          box-shadow: 0 10px 30px rgba(0,0,0,0.2);
          text-align: center;
          max-width: 600px;
          width: 100%;
        }
        .logo {
          width: 80px;
          height: 80px;
          background: #4CAF50;
          border-radius: 50%;
          margin: 0 auto 20px;
          display: flex;
          align-items: center;
          justify-content: center;
          color: white;
          font-size: 32px;
          font-weight: bold;
        }
        h1 {
          color: #333;
          margin-bottom: 10px;
        }
        p {
          color: #666;
          line-height: 1.6;
          margin-bottom: 20px;
        }
        .status {
          background: #f0f8f0;
          border: 2px solid #4CAF50;
          border-radius: 5px;
          padding: 15px;
          margin: 20px 0;
          color: #2e7d32;
        }
        .features {
          text-align: left;
          margin: 20px 0;
        }
        .features li {
          margin: 10px 0;
          color: #555;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="logo">IT</div>
        <h1>ITSM Mobile Application</h1>
        <p>IT Service Management Mobile App - Flutter Project Setup Complete</p>
        
        <div class="status">
          ✅ Project imported and server running successfully on port 5000
        </div>
        
        <div class="features">
          <h3>Available Features:</h3>
          <ul>
            <li>Dashboard with analytics and metrics</li>
            <li>Create and manage support tickets</li>
            <li>View all tickets and personal tickets</li>
            <li>Ticket details with comments and attachments</li>
            <li>Category management</li>
            <li>User authentication with Supabase</li>
            <li>File upload and image support</li>
            <li>Responsive design for mobile and web</li>
          </ul>
        </div>
        
        <p><strong>Status:</strong> Flutter development environment configured. Web server running successfully.</p>
        <p><em>This is a placeholder interface while the Flutter web build is being prepared.</em></p>
      </div>
    </body>
    </html>
  `);
});

// API routes for the Flutter app
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    message: 'ITSM Mobile API is running',
    timestamp: new Date().toISOString()
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`ITSM Mobile server running on http://0.0.0.0:${PORT}`);
  console.log('Project imported and configured successfully!');
});
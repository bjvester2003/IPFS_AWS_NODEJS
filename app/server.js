const express = require('express');
const { exec } = require('child_process');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = 3000;

// Middleware
app.use(express.json());
app.use(express.static('public')); // Serve your HTML/CSS/JS from /public

// Download route
app.post('/download', (req, res) => {
  const { cid, filename } = req.body;

  if (!cid || !filename) {
    return res.status(400).send('CID and filename are required.');
  }

  const outputPath = path.join(__dirname, 'downloads', filename);

  exec(`ipfs get ${cid} -o "${outputPath}"`, (error, stdout, stderr) => {
    if (error) {
      return res.status(500).send(stderr || error.message);
    }

    res.download(outputPath, filename, (err) => {
      // Clean up the file after sending
      fs.unlink(outputPath, () => {});
      if (err) {
        console.error('Error sending file:', err);
      }
    });
  });
});

// Upload setup
const upload = multer({ dest: 'uploads/' });

app.post('/upload', upload.single('file'), (req, res) => {
  const filePath = path.resolve(req.file.path);

  exec(`ipfs-cluster-ctl add ${filePath}`, (error, stdout, stderr) => {
    fs.unlinkSync(filePath); // Cleanup uploaded file

    if (error) return res.status(500).send(stderr);
    res.send(stdout);
  });
});

app.post('/execute', (req, res) => {
  const command = req.body.command;

  // Basic sanitization (DO NOT use in production without full validation)
  if (!/^(ipfs|ipfs-cluster-ctl)/.test(command)) {
    return res.status(400).send('Unauthorized command.');
  }

  exec(command, (error, stdout, stderr) => {
    if (error) return res.status(500).send(stderr || error.message);
    res.send(stdout);
  });
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});

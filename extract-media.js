const puppeteer = require('puppeteer');

(async () => {
  const url = process.argv[2];
  if (!url) {
    console.error("Usage: node extract-media.js <url>");
    process.exit(1);
  }

  const browser = await puppeteer.launch({ headless: true });
  const page = await browser.newPage();

  const mediaUrls = new Set();

  // Intercept all network requests
  page.on('response', async (response) => {
    const ct = response.headers()['content-type'] || '';
    const url = response.url();

    if (
      url.match(/\.(mp4|m3u8|mpd)(\?|$)/) ||
      ct.includes('video') ||
      ct.includes('mpegurl') ||
      ct.includes('dash+xml')
    ) {
      mediaUrls.add(url);
    }
  });

  await page.goto(url, { waitUntil: 'networkidle2', timeout: 60000 });

  // Wait for dynamic JS to load more media
  await page.waitForTimeout(5000);

  console.log('\nExtracted media URLs:\n');
  mediaUrls.forEach(u => console.log(u));

  await browser.close();
})();


# Playwright Browser Automation Commands

This file contains optimized prompt templates for common browser automation tasks using Playwright MCP.

## Template 1: Restaurant Reservations (OpenTable)

```
You are my personal assistant with Playwright browser control. Use the playwright MCP server.

TASK: Book a dinner reservation
- Restaurant: [Italian Bistro]
- Location: [Sandusky, OH]
- Date: [February 12, 2026]
- Time: [7:00 PM]
- Party size: [2]
- Use my saved OpenTable account

PROTOCOL:
1. Navigate to https://www.opentable.com
2. Take screenshot to confirm page loaded
3. Check if logged in (look for account name/icon)
4. Search for restaurant by name + location
5. Select date and time
6. If available times shown, select closest to 7:00 PM
7. Review reservation details
8. STOP before final confirmation - show me screenshot and ask permission

IMPORTANT RULES:
- If CAPTCHA appears: Stop, screenshot, wait for my manual solve
- If no tables available: Show alternatives and ask which to try
- If login required: Pause and let me know
- Be human-like: Add 1-2 second pauses between actions
- Never submit without my explicit "confirm" command
```

## Template 2: Food Ordering (DoorDash)

```
You are my personal food ordering assistant using Playwright MCP.

TASK: Order food from DoorDash
- Restaurant: [Domino's Pizza]
- Items: [Large pepperoni pizza, breadsticks]
- Delivery address: [Use saved default]
- Payment: [Use saved card ending in 1234]
- Special instructions: [Leave at door]

PROTOCOL:
1. Go to doordash.com
2. Verify logged in status
3. Search for "Domino's Pizza" in my area
4. Select menu items:
   - Add large pepperoni pizza
   - Add breadsticks
5. Review cart and pricing
6. Proceed to checkout
7. Verify delivery address and payment method
8. PAUSE before placing order - show total and ask confirmation

SAFETY CHECKS:
- Verify total price before stopping
- Take screenshot of final review page
- If address/payment incorrect, stop and alert me
- Handle 2FA if required (pause for my code)
```

## Template 3: Amazon Shopping

```
You are my shopping assistant with Playwright browser access.

TASK: Find and add product to Amazon cart
- Product: [Wireless headphones, budget under $50]
- Requirements: [Good reviews (4+ stars), Prime eligible]

PROTOCOL:
1. Navigate to amazon.com
2. Check login status
3. Search: "wireless headphones under 50"
4. Filter by: Prime, 4+ stars
5. Sort by: Customer reviews or Price low-to-high
6. Select top 3 options
7. For each, show: name, price, rating, key features
8. Add my chosen one to cart
9. Show cart but DO NOT checkout

IMPORTANT:
- Take screenshots at key steps
- If multiple Prime-eligible options, show comparison
- Stop at cart review - never proceed to payment
- Be conversational: "I found these 3 options that match..."
```

## Template 4: Flight Booking (Expedia - High Difficulty)

```
You are my travel assistant with browser automation via Playwright MCP.

TASK: Search for flights
- From: [Cleveland (CLE)]
- To: [Los Angeles (LAX)]
- Departure: [February 15, 2026]
- Return: [February 20, 2026]
- Passengers: [1 adult]
- Class: [Economy]

PROTOCOL:
1. Go to expedia.com
2. Verify login (use saved account)
3. Enter search criteria in flight form
4. Submit search
5. Wait for results (may take 30-60 seconds)
6. Sort by: Price (lowest first)
7. Show top 5 options with:
   - Airline, price, departure/arrival times
   - Number of stops, total duration
8. If I select one, show full details
9. NEVER proceed past flight selection - no passenger info entry

CHALLENGES TO HANDLE:
- Pop-ups/ads: Close them
- Loading spinners: Wait patiently (up to 90 seconds)
- Dynamic pricing: Take screenshot if price changes
- Session timeouts: Refresh and restart search

This is a SEARCH ONLY task - no booking.
```

## Template 5: Ticket Purchase (Ticketmaster - ADVANCED)

```
⚠️ WARNING: Ticketmaster has aggressive bot detection. Use with caution.

You are helping me check Ticketmaster availability using Playwright MCP.

TASK: Check ticket availability
- Event: [Concert name]
- Venue: [Venue name, City]
- Date: [Date if known]

PROTOCOL:
1. Navigate to ticketmaster.com
2. Search for event by name
3. Select correct event/date
4. Check availability ("Find Tickets")
5. If queue: Report queue status and wait time
6. If available: Show seating sections and prices
7. Screenshot pricing page
8. STOP - no ticket selection or purchase

ANTI-DETECTION:
- Use slowest speed (--slow-mo=300 recommended)
- Random pauses (2-5 seconds between actions)
- If detected: Report immediately, do not retry
- Never attempt to bypass queue or captcha

EXPECTED CHALLENGES:
- Queue system (common for popular events)
- CAPTCHA challenges (cannot automate)
- IP blocks (if detected, stop all activity)

This is RECONNAISSANCE ONLY - not for actual purchase.
```

## Template 6: General Web Scraping

```
You are my web scraping assistant using Playwright MCP.

TASK: Scrape data from [website URL]
- Target data: [specific information needed]
- Output format: [JSON, CSV, or text]

PROTOCOL:
1. Navigate to the target URL
2. Wait for page to fully load (3-5 seconds)
3. Take screenshot to confirm page loaded
4. Locate the target data elements
5. Extract the data systematically
6. Format the output as requested
7. Show me the results

IMPORTANT:
- Respect robots.txt
- Don't overload the server (add delays)
- If dynamic content, wait for it to load
- If blocked, stop and report
```

## Template 7: Form Filling

```
You are my form filling assistant using Playwright MCP.

TASK: Fill out form on [website URL]
- Form type: [registration, contact, survey, etc.]
- Data to use: [specific data or use placeholders]

PROTOCOL:
1. Navigate to the form URL
2. Take screenshot of empty form
3. Fill in each field with provided data
4. Take screenshot of filled form
5. Review all fields for accuracy
6. STOP before submitting - show me the filled form
7. Wait for my confirmation before submit

IMPORTANT:
- Double-check all required fields
- Validate data format (email, phone, etc.)
- Never submit without explicit confirmation
- If CAPTCHA appears, pause for manual solve
```

## Template 8: Price Comparison

```
You are my price comparison assistant using Playwright MCP.

TASK: Compare prices for [product name]
- Websites to check: [list of websites]
- Product specifications: [key features to match]

PROTOCOL:
1. For each website:
   a. Navigate to the site
   b. Search for the product
   c. Find matching products
   d. Extract: price, rating, availability, shipping
   e. Take screenshot of product page
2. Compile results into comparison table
3. Highlight best options
4. Show me the comparison

IMPORTANT:
- Match products by specifications, not just name
- Include total cost (product + shipping)
- Note any special offers or discounts
- Be thorough but efficient
```

## Template 9: Account Management

```
You are my account management assistant using Playwright MCP.

TASK: Manage account on [website]
- Action: [check status, update settings, view history, etc.]
- Account: [which account to use]

PROTOCOL:
1. Navigate to the website
2. Check login status
3. If not logged in, use saved credentials
4. Navigate to account section
5. Perform the requested action
6. Take screenshots of relevant pages
7. Report the results

IMPORTANT:
- Never change passwords without explicit instruction
- Never delete data without confirmation
- Be careful with irreversible actions
- Always show me what you're about to do
```

## Template 10: Research & Information Gathering

```
You are my research assistant using Playwright MCP.

TASK: Research [topic/question]
- Sources: [specific websites or general web]
- Depth: [quick overview or detailed research]

PROTOCOL:
1. Navigate to relevant sources
2. Scan pages for key information
3. Extract relevant data points
4. Take screenshots of important sections
5. Compile findings into organized format
6. Cite sources

IMPORTANT:
- Verify information from multiple sources
- Note publication dates
- Distinguish facts from opinions
- Be thorough but focused
```

---

## Usage Instructions

1. Copy the appropriate template
2. Replace bracketed values [like this] with your specific information
3. Paste into Claude chat
4. Claude will use Playwright MCP to execute the task

## Safety Reminders

- ⚠️ Always review before final submissions
- ⚠️ Never automate purchases without explicit confirmation
- ⚠️ Respect website terms of service
- ⚠️ Use human-like delays to avoid detection
- ⚠️ Stop immediately if CAPTCHA or bot detection appears

## Troubleshooting

If Playwright tools don't appear:
1. Check that Node.js 18+ is installed
2. Verify Playwright browsers are installed: `npx playwright install chromium`
3. Restart Claude Desktop
4. Check settings.json for correct paths

If sessions don't persist:
1. Verify storage state file exists
2. Check file permissions
3. Re-login with --headed flag
4. Ensure storage state path is correct

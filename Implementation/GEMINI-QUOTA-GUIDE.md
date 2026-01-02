# Google Gemini API Quota Increase Guide

**Date:** December 31, 2025  
**Issue:** Free tier quota exhausted (429 Too Many Requests)

---

## Understanding Free Tier Limits

The Google Gemini API free tier has the following limits:

### Current Limits (Free Tier):
- **Requests per minute:** Limited (varies by model)
- **Requests per day:** Limited (varies by model)
- **Input tokens per minute:** Limited
- **Output tokens per minute:** Limited

**Note:** Free tier quotas are shared across all users and reset periodically. Once exhausted, you must wait for reset or upgrade.

---

## Options to Increase Quota

### Option 1: Wait for Quota Reset ⏱️

**Free Tier Quota Resets:**
- **Per-minute quotas:** Reset every 60 seconds
- **Per-day quotas:** Reset at midnight (PST/PDT)

**Action:**
- Wait 1-2 minutes for per-minute quota reset
- Or wait until next day for daily quota reset
- No cost, but limited usage

**Best for:** Testing, low-volume usage

---

### Option 2: Enable Billing (Recommended) 💳

**Upgrade to Paid Tier:**

1. **Go to Google Cloud Console:**
   - Visit: https://console.cloud.google.com/
   - Sign in with your Google account (vospr2@gmail.com)

2. **Enable Billing:**
   - Navigate to: **Billing** > **Link a billing account**
   - Add a payment method (credit card)
   - **Note:** You still get free tier credits, but can exceed limits

3. **Benefits:**
   - Higher quota limits
   - Pay only for usage beyond free tier
   - More reliable access
   - Better rate limits

4. **Cost:**
   - Free tier credits still apply
   - Pay only for overage
   - Typically very low cost for development/testing

**Best for:** Regular usage, development, production

---

### Option 3: Request Quota Increase 📈

**Request Higher Limits:**

1. **Go to Google Cloud Console:**
   - Visit: https://console.cloud.google.com/
   - Navigate to: **APIs & Services** > **Quotas**

2. **Find Gemini API Quotas:**
   - Search for: `Generative Language API`
   - Filter by: `generativelanguage.googleapis.com`

3. **Select Quota to Increase:**
   - `GenerateRequestsPerMinutePerProjectPerModel-FreeTier`
   - `GenerateRequestsPerDayPerProjectPerModel-FreeTier`
   - `GenerateContentInputTokensPerModelPerMinute-FreeTier`

4. **Request Increase:**
   - Click on the quota
   - Click **Edit Quotas**
   - Enter requested limit
   - Provide justification (e.g., "Development and testing")
   - Submit request

5. **Wait for Approval:**
   - Usually approved within 24-48 hours
   - You'll receive email notification

**Best for:** Free tier users who need slightly more quota

---

### Option 4: Use Different Model 🔄

**Try Alternative Models:**

Different Gemini models may have separate quota limits:

1. **Switch Model:**
   ```powershell
   # In dmtools.env, change:
   GEMINI_DEFAULT_MODEL=gemini-pro
   # or
   GEMINI_DEFAULT_MODEL=gemini-1.5-pro
   ```

2. **Available Models:**
   - `gemini-pro` - General purpose
   - `gemini-1.5-pro` - More capable
   - `gemini-2.0-flash-exp` - Experimental (current)

3. **Check Quota:**
   - Each model has separate quotas
   - If one is exhausted, try another

**Best for:** Quick workaround

---

## Step-by-Step: Enable Billing (Recommended)

### 1. Access Google Cloud Console

```
https://console.cloud.google.com/
```

### 2. Select or Create Project

- If you have project `dmtools-ai-teammate` (ID: 192578446190), select it
- Or create a new project

### 3. Enable Billing

1. Go to: **Navigation Menu** > **Billing**
2. Click: **Link a billing account**
3. Create new billing account (if needed)
4. Add payment method (credit card)
5. Link to your project

### 4. Verify API Access

1. Go to: **APIs & Services** > **Enabled APIs**
2. Ensure **Generative Language API** is enabled
3. Check quota status at: https://ai.dev/usage?tab=rate-limit

### 5. Test API Access

After enabling billing, retry your API calls. You should have:
- Higher rate limits
- More reliable access
- Ability to exceed free tier limits (with charges)

---

## Check Current Quota Usage

### Method 1: Google Cloud Console

1. Go to: https://console.cloud.google.com/
2. Navigate to: **APIs & Services** > **Quotas**
3. Search for: `generativelanguage`
4. View current usage vs. limits

### Method 2: Gemini API Usage Dashboard

1. Visit: https://ai.dev/usage?tab=rate-limit
2. Sign in with your Google account
3. View real-time quota usage
4. See reset times

### Method 3: API Response

The 429 error response includes quota information:
```json
{
  "error": {
    "code": 429,
    "message": "You exceeded your current quota...",
    "details": [
      {
        "@type": "type.googleapis.com/google.rpc.RetryInfo",
        "retryDelay": "51s"  // When to retry
      }
    ]
  }
}
```

---

## Best Practices

### 1. Monitor Usage

- Check quota usage regularly
- Set up alerts in Google Cloud Console
- Monitor at: https://ai.dev/usage

### 2. Implement Rate Limiting

Add delays between requests:
```powershell
# Add delay between requests
Start-Sleep -Seconds 2
```

### 3. Use Caching

- Cache responses when possible
- Avoid redundant API calls
- Store results locally

### 4. Optimize Requests

- Batch requests when possible
- Use appropriate model for task
- Minimize token usage

---

## Cost Estimation

### Free Tier (No Billing):
- **Cost:** $0
- **Limits:** Very restrictive
- **Best for:** Testing, learning

### Paid Tier (With Billing):
- **Free Credits:** Still available
- **Overage Cost:** ~$0.00025 per 1K characters (input)
- **Example:** 1000 requests/day ≈ $0.10-0.50 (depending on length)
- **Best for:** Development, production

**Note:** Google provides generous free tier credits even with billing enabled.

---

## Quick Fix: Wait and Retry

**Immediate Solution:**

```powershell
# Wait for quota reset (check error message for retry delay)
$retryDelay = 60  # seconds (from error message)
Write-Host "Waiting $retryDelay seconds for quota reset..."
Start-Sleep -Seconds $retryDelay

# Retry your API call
# (Use your existing PowerShell commands)
```

---

## Recommended Action Plan

### For Development/Testing:

1. ✅ **Enable Billing** (recommended)
   - Low cost (often $0 with free credits)
   - Higher limits
   - More reliable

2. ⏱️ **Wait for Reset** (temporary)
   - Quick fix
   - No cost
   - Limited by free tier

3. 🔄 **Use Different Model** (workaround)
   - Try `gemini-pro` instead
   - Separate quotas
   - Quick test

### For Production:

1. **Must Enable Billing**
2. **Request Quota Increase** if needed
3. **Implement Rate Limiting**
4. **Monitor Usage**

---

## Resources

- **Quota Dashboard:** https://ai.dev/usage?tab=rate-limit
- **Rate Limits Docs:** https://ai.google.dev/gemini-api/docs/rate-limits
- **Google Cloud Console:** https://console.cloud.google.com/
- **Billing Setup:** https://console.cloud.google.com/billing
- **API Documentation:** https://ai.google.dev/gemini-api/docs

---

## Summary

**To increase quota:**

1. **Quick Fix:** Wait 1-2 minutes for per-minute reset, or until next day
2. **Best Solution:** Enable billing in Google Cloud Console (recommended)
3. **Alternative:** Request quota increase (may take 24-48 hours)
4. **Workaround:** Try different model (gemini-pro)

**Recommended:** Enable billing for reliable access with minimal cost.

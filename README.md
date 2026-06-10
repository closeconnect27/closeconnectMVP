# close.connect MVP

A WhatsApp community directory. Browse, discover, and submit communities by interest.

## Stack
- **Frontend** — plain HTML/CSS/JS (no build step)
- **Database** — Supabase (Postgres)
- **Hosting** — Netlify

---

## Setup

### 1. Supabase

1. Create a project at [supabase.com](https://supabase.com) — region: **Southeast Asia (Singapore)**
2. Go to **SQL Editor → New query** and run the contents of `schema.sql`
3. Go to **Project Settings → API** and copy:
   - **Project URL** → `SUPABASE_URL`
   - **anon public key** → `SUPABASE_ANON_KEY`

### 2. Configure index.html

Open `index.html` and replace lines 3–4 in the script block:

```js
const SUPABASE_URL  = 'YOUR_SUPABASE_URL'
const SUPABASE_ANON = 'YOUR_SUPABASE_ANON_KEY'
```

### 3. Deploy to Netlify

1. Go to [netlify.com](https://netlify.com) → **Add new site → Import from Git**
2. Connect this GitHub repo
3. Build command: *(leave blank)*
4. Publish directory: `/`
5. Click **Deploy**

### 4. GitHub Secrets (for keep-alive cron)

Go to **repo Settings → Secrets → Actions** and add:

| Secret | Value |
|---|---|
| `SUPABASE_URL` | your Supabase project URL |
| `SUPABASE_ANON_KEY` | your anon public key |

This prevents the free Supabase project from pausing after 7 days of inactivity.

---

## Moderation

Submissions land as `status = 'pending'` in your Supabase dashboard.

To publish a community:
1. Open Supabase → **Table Editor → communities**
2. Find the row → change `status` to `active`
3. It appears on the site immediately — no redeploy needed

---

## Schema

Run `schema.sql` in the Supabase SQL Editor to create all tables, indexes, RLS policies, and seed categories.

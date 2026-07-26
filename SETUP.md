# Connecting the registry to Supabase

Five steps: create a project, run the schema, create a storage bucket,
create staff logins, plug in your keys.

## 1. Create a Supabase project
Go to [supabase.com](https://supabase.com) → New project. Pick any
name/region/password (the DB password isn't used by this app directly,
just keep it somewhere safe).

## 2. Run the schema
Open your project → **SQL Editor** → New query → paste the entire
contents of `schema.sql` → **Run**.

This creates three tables (`departments`, `personnel_files`,
`documents`), locks them down so only signed-in users can read or
write anything, and seeds the same 9 sample employees the prototype
shipped with (all starting as "pending" since there are no real scans
yet).

## 3. Create the storage bucket
Project → **Storage** → **New bucket**.
- Name: `scans` (must match exactly — this is what the app looks for)
- Public bucket: **OFF** (leave it private — these are ID scans and
  personnel documents)

Then add access policies so only signed-in staff can use it:
Storage → `scans` bucket → **Policies** → New policy → for each of
Select / Insert / Update / Delete, choose "For authenticated users
only" (or write a policy with `auth.role() = 'authenticated'` as the
condition, same as the table policies in schema.sql).

## 4. Create staff logins
This app has a sign-in screen but no public sign-up — that's
intentional, so random people can't create their own accounts.
Add each staff member yourself:

Project → **Authentication** → **Users** → **Add user** → enter their
email and a temporary password. Share that password with them
directly (Slack, in person, etc.) and have them use it to sign in —
Supabase doesn't have a "reset password" flow wired into this app yet,
so if someone forgets theirs, just set a new one for them from this
same screen.

## 5. Plug in your keys
Project → **Settings** → **API**. Copy:
- **Project URL**
- **anon public** key (NOT the `service_role` key — that one must
  never go in front-end code)

Open `index.html`, find this near the top of the `<script>` section:

```js
const SUPABASE_URL = 'YOUR_SUPABASE_URL';
const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY';
```

Replace both placeholder strings with your actual values, save, and
reload the page. You should see a sign-in screen — log in with one of
the staff accounts from step 4, and the app will load real data from
your database instead of sample data.

## What's now real vs. what's still local

| Feature | Status |
|---|---|
| Personnel files (create/edit/delete) | Saved in Supabase — persists across reloads and devices |
| Uploaded scans | Saved in Supabase Storage — persists |
| Departments | Saved in Supabase — persists |
| Who can sign in | Controlled by you, via Authentication → Users |
| Search/filter/sort | Still done in the browser after loading data (fine at this scale) |

## A note on security
The anon key is safe to put in front-end code — it's meant to be
public, and Row Level Security (from `schema.sql`) is what actually
protects the data by requiring a logged-in session for any read or
write. If you ever open this bucket or these tables to `anon`
(unauthenticated) access for convenience during testing, remember to
lock it back down before putting real personnel data in it.

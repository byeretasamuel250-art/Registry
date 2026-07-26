# Personnel Registry

A front-end prototype for a digital personnel records system — built to replace a paper-based archive of employee files with a searchable, filterable digital registry.

## Status

🟡 **Prototype stage.** This is a static front-end only, using in-memory sample data. Nothing persists on page refresh, and there is no backend yet.

## Features

- Dashboard with live stats (total files, % digitized, pending scans)
- Search and filter by name, employee ID, department, or digitization status
- Create new employee files
- Attach scanned documents to a file (marks it "Digitized")
- Detail view per employee showing attached documents

## Running it

Just open `index.html` in a browser — no build step, no dependencies.

Or serve it locally:

```bash
python3 -m http.server 8000
```

Then visit `http://localhost:8000`.

## Next steps

- [ ] Wire up [Supabase](https://supabase.com) as the backend:
  - `personnel_files` table for records
  - Supabase Storage for scanned documents
- [ ] Replace the in-memory `files` array with real Supabase queries
- [ ] Add authentication so only registry staff can access files
- [ ] Decide on deployment target (local server vs. cloud)

## Tech

Plain HTML/CSS/JS — no framework, no build tooling. Intentionally simple until the backend is decided.

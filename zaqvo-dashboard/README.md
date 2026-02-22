# Zaqvo Dashboard

Admin dashboard for reports and analytics. React + Vite + TypeScript + Tailwind CSS + shadcn/ui.

## Setup

```bash
npm install
cp .env.example .env   # VITE_API_BASE_URL
```

## Run

- Dev: `npm run dev`
- Build: `npm run build`
- Preview: `npm run preview`

## Structure

- `src/components/ui/` — shadcn components
- `src/components/layout/` — sidebar, header
- `src/pages/` — dashboard, reports, analytics
- `src/lib/` — API client, auth, utils
- `src/hooks/` — data fetching, auth

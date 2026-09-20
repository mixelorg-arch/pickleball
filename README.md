# Pickle — pickleball open-play manager

Single-file mobile web app: roster with photos, multi-court queue with drag & drop, winners-stay rotation,
sessions with a Player of the Session screen, and dated session history. Local-first (localStorage) with optional
cloud sync by room code.

**Cloud sync setup (once):** run `supabase.sql` in the Supabase SQL Editor. It creates only `pickle_*` objects.

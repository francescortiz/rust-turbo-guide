# sqlx Challenges

1. Setting database string in intellij IDEs:

[Github issue comment](https://github.com/intellij-rust/intellij-rust/issues/6474#issuecomment-738049730)

2. Supabase says `prepared statement "sqlx_s_1" already exists`

Use port 5432 instead of port 6543 in order to avoid pg_bouncer. [Source](https://github.com/supabase/supavisor/issues/239#issuecomment-2085235022)

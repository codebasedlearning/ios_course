[© 2025, Alexander Voß, FH Aachen, codebasedlearning.dev](mailto:info@codebasedlearning.dev)

# iOS Course – Supabase


## Unit 0x04 - Content

> In this unit we are looking at a Managed Realtime SQL Platform - Supabase.

Supabase is an open-source backend-as-a-service (BaaS) that provides PostgreSQL with instant REST and Realtime APIs, Authentication, Storage, and Edge Functions—aiming to be an open alternative to Firebase, but built on top of SQL and open standards.

Almost every project requires a database or node for exchanging data and, potentially, messages. A pure database connection is insecure, so we look for a framework or service that offers secure database functionality. Supabase and Firebase, among others, offer this functionality.

ChatGPT compares it as follows

| Feature                             | **Supabase** (Open Source)                     | **Firebase** (Google Cloud)                        |
|-------------------------------------|------------------------------------------------|---------------------------------------------------|
| **Database**                        | **PostgreSQL (SQL)**                           | **Firestore (NoSQL)** / Realtime Database (NoSQL) |
| **Query Language**                  | SQL (full relational, joins, functions)        | NoSQL-style querying (collections/documents)      |
| **Data Consistency**                | Strong ACID guarantees                        | Eventually consistent (Firestore), Realtime DB is weakly consistent |
| **Authentication**                  | Built-in with RLS integration (email, OAuth)   | Built-in Firebase Authentication (email, OAuth, etc.) |
| **Realtime**                        | **Postgres Realtime (WebSockets)**             | **Realtime Database (WebSockets)** / Firestore listeners |
| **APIs**                            | Auto-generated REST, GraphQL (via extension), Realtime | Client SDKs with custom API |
| **Storage**                         | File/object storage with access control       | Firebase Storage (Google Cloud Storage)          |
| **Functions**                       | Edge Functions (Deno runtime, JavaScript/TypeScript) | Firebase Cloud Functions (Node.js, Google Cloud)  |
| **Self-Hosting**                    | ✅ Yes, fully open-source                      | ❌ No, fully proprietary                          |
| **Pricing Model**                   | Usage-based, free self-hosting option          | Usage-based, no self-hosting                      |
| **Data Ownership**                  | Full (self-host or managed PostgreSQL)         | Google Cloud-hosted only                         |
| **Maturity & Ecosystem**            | Young but rapidly growing                     | Mature, large ecosystem, deep Google integration  |
| **Community & Licensing**           | Open Source (Apache 2.0)                       | Proprietary                                      |

### Summaries

- **Supabase**
  > SQL-first, open-source Firebase alternative with Realtime, Auth, Storage, and Edge Functions on top of PostgreSQL.  
  > Great for teams that want **SQL + Open Source + Flexibility**.

- **Firebase**
  > Google’s proprietary BaaS with NoSQL databases, Realtime capabilities, and seamless Google Cloud integration.  
  > Great for **rapid prototyping** and **scaling with Google Cloud**, but **vendor-locked**.
  

## Supabase

https://supabase.com
https://supabase.com/docs/guides


## SupaApp

> Our focus here has been on implementing essential communication channels and a reasonably sensible architecture. There are many other topics that could have been covered, but we will start here.

We have taken the following into account:
- sign in/out;
- user and security concepts;
- database connection and operations;
- messaging
- broadcasting

### Initial SQL operations (Supabase SQL Editor)

> `channels` and `global_message_queue` mirror the `LocalChannel`/`LocalMessage`
> SwiftData relationship on the client (see `Models/LocalChannel.swift`): one
> channel, many messages. `global_message_queue.channel_id` is the foreign key
> that makes that one-to-many real in Postgres; the `read_all_messages` view
> joins it back in as `channel_name` so the client gets it in one round-trip.
> There is deliberately no channel-management UI/endpoint — the app only ever
> looks for, or creates, a single channel named `global`.

```

-- table channels (the "one" side — created first, global_message_queue
-- below references it)

create table public.channels (
    id uuid primary key default gen_random_uuid(),
    name text not null unique,
    created_at timestamptz not null default now()
);

-- table global_message_queue (the "many" side)

create table public.global_message_queue (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    created_at timestamptz not null default now(),
    message jsonb not null,
    channel_id uuid references public.channels(id)
);

-- enable row level security

alter table public.channels enable row level security;
alter table public.global_message_queue enable row level security;

-- allow authenticated users all operations

create policy "authenticated_users_full_access"
    on public.channels
    for all
    to authenticated
    using (true)
    with check (true);

create policy "authenticated_users_full_access"
    on public.global_message_queue
    for all
    to authenticated
    using (true)
    with check (true);

-- grant access to the tables

grant select, insert, update, delete
    on public.channels
    to authenticated;

grant select, insert, update, delete
    on public.global_message_queue
    to authenticated;

-- create the view (left-joins in both the user's email and the channel's name)

create or replace view public.read_all_messages as
    select q.id, q.created_at, u.email, q.message, q.channel_id, c.name as channel_name
    from public.global_message_queue q
    left outer join auth.users u on q.user_id = u.id
    left outer join public.channels c on q.channel_id = c.id
    order by q.created_at desc;

-- grant access to the view

grant select on public.read_all_messages to authenticated;

-- regisater for real-time event for chaning tables

alter publication supabase_realtime
    add table public.global_message_queue;

alter publication supabase_realtime
    add table public.channels;


-- to get rid of (drop the "many" side first — it holds the FK)

-- drop view public.read_all_messages;
-- drop table public.global_message_queue;
-- drop table public.channels;

```

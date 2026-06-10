-- ═══════════════════════════════════════════
-- close.connect — Supabase schema
-- Run this entire file in SQL Editor once
-- ═══════════════════════════════════════════

-- 1. CATEGORIES
create table if not exists categories (
  id         uuid primary key default gen_random_uuid(),
  name       text not null,
  slug       text not null unique,
  emoji      text,
  color_bg   text,
  color_text text,
  sort_order int default 0
);

-- 2. COMMUNITIES
create table if not exists communities (
  id                  uuid primary key default gen_random_uuid(),
  name                text not null,
  description         text,
  whatsapp_link       text not null,
  category_id         uuid references categories(id) on delete set null,
  status              text not null default 'pending'
    check (status in ('pending','active','rejected','dead_link','archived')),
  is_verified         boolean default false,
  submitted_by_email  text,
  submitted_by_name   text,
  click_count         int default 0,
  created_at          timestamptz default now(),
  updated_at          timestamptz default now()
);

-- 3. CLICK TRACKING
create table if not exists community_clicks (
  id            uuid primary key default gen_random_uuid(),
  community_id  uuid references communities(id) on delete cascade,
  session_id    text,
  referrer      text,
  user_agent    text,
  clicked_at    timestamptz default now()
);

-- 4. REPORTS
create table if not exists reports (
  id            uuid primary key default gen_random_uuid(),
  community_id  uuid references communities(id) on delete cascade,
  reason        text not null
    check (reason in ('dead_link','spam','inappropriate','duplicate','other')),
  description   text,
  reporter_email text,
  status        text default 'open'
    check (status in ('open','resolved','dismissed')),
  created_at    timestamptz default now()
);

-- 5. INDEXES
create index if not exists idx_communities_status       on communities(status);
create index if not exists idx_communities_category     on communities(category_id);
create index if not exists idx_communities_created      on communities(created_at desc);
create index if not exists idx_communities_clicks       on communities(click_count desc);
create index if not exists idx_clicks_community         on community_clicks(community_id);
create index if not exists idx_clicks_at                on community_clicks(clicked_at desc);

-- 6. UPDATED_AT TRIGGER
create or replace function set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger communities_updated_at
  before update on communities
  for each row execute function set_updated_at();

-- 7. INCREMENT CLICK FUNCTION (used by frontend)
create or replace function increment_click(community_id uuid)
returns void language sql security definer as $$
  update communities
  set click_count = click_count + 1
  where id = community_id;
$$;

-- 8. ROW LEVEL SECURITY
alter table communities       enable row level security;
alter table categories        enable row level security;
alter table community_clicks  enable row level security;
alter table reports           enable row level security;

-- Public: read active communities only
create policy "public read active communities"
  on communities for select
  using (status = 'active');

-- Public: read all categories
create policy "public read categories"
  on categories for select
  using (true);

-- Public: submit new community (goes in as pending)
create policy "public submit community"
  on communities for insert
  with check (status = 'pending');

-- Public: log clicks
create policy "public log clicks"
  on community_clicks for insert
  with check (true);

-- Public: submit reports
create policy "public submit reports"
  on reports for insert
  with check (true);

-- 9. SEED CATEGORIES
insert into categories (name, slug, emoji, color_bg, color_text, sort_order) values
  ('sports & fitness',  'sports',       '🏃', '#0d2218', '#6ee7b7', 1),
  ('tech & builders',   'tech',         '💻', '#1a0d2e', '#c4b5fd', 2),
  ('arts & culture',    'arts',         '🎨', '#2a0e0e', '#fca5a5', 3),
  ('food & drinks',     'food',         '☕', '#2a1a0a', '#fdba74', 4),
  ('music',             'music',        '🎵', '#1a1a0d', '#fde68a', 5),
  ('wellness',          'wellness',     '🧘', '#0d2218', '#6ee7b7', 6),
  ('gaming',            'gaming',       '🎮', '#0d0d2e', '#818cf8', 7),
  ('travel & outdoors', 'travel',       '✈️', '#1a2a0a', '#a3e635', 8),
  ('photography',       'photography',  '📸', '#1a0d2e', '#c4b5fd', 9)
on conflict (slug) do nothing;

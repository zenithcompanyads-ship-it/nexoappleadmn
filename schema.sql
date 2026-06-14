-- ════════════════════════════════════════════════════════════
--  NEXO APPLE CONTROLE — Schema Supabase (completo)
--  Cole este arquivo inteiro no SQL Editor do Supabase e clique em "Run"
-- ════════════════════════════════════════════════════════════


-- ────────────────────────────────────────────
-- 1. ESTOQUE
-- Preço pago, frete, data de entrada e status de
-- estoque dos itens do catálogo padrão (Seminovos)
-- ────────────────────────────────────────────
create table if not exists estoque (
  id          uuid primary key default gen_random_uuid(),
  model       text not null,           -- ex: "iPhone 16 Pro"
  sub         text not null,           -- ex: "256GB"
  price       numeric(10,2),           -- preço que você pagou
  frete       numeric(10,2) default 80,-- frete deste item
  entry_date  date,                    -- data que chegou
  in_stock    boolean default true,    -- tem ou não tem
  created_at  timestamptz default now(),
  updated_at  timestamptz default now(),
  unique (model, sub)
);


-- ────────────────────────────────────────────
-- 2. PRODUTOS_CUSTOM
-- Produtos adicionados manualmente pelo usuário
-- (aba "Seminovos" ou "Novos / Lacrados")
-- ────────────────────────────────────────────
create table if not exists produtos_custom (
  id          text primary key,        -- id gerado no app (timestamp)
  tipo        text not null,           -- 'seminovo' | 'novo'
  serie       text,                    -- '12'..'17', 'ipad', 'mac', 'outro'
  model       text not null,           -- ex: "iPhone 17 Pro Max"
  sub         text,                    -- ex: "512GB"
  custo       numeric(10,2) default 0,
  frete       numeric(10,2) default 80,
  obs         text,                    -- observação / garantia
  bateria     text,                    -- saúde da bateria (%) — seminovo
  cor         text,
  in_stock    boolean default true,
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);


-- ────────────────────────────────────────────
-- 3. VENDAS
-- Registro completo de cada venda (Controle de Vendas)
-- ────────────────────────────────────────────
create table if not exists vendas (
  id          text primary key,        -- id gerado no app (timestamp)
  produto     text not null,
  imei        text,
  cor         text,
  storage     text,
  condicao    text,                    -- "Seminovo - Excelente", "Novo (Lacrado)"...
  bateria     text,
  custo       numeric(10,2) default 0,
  frete       numeric(10,2) default 0,
  venda       numeric(10,2) default 0,
  lucro       numeric(10,2) generated always as (venda - custo - frete) stored,
  pgto        text,                    -- PIX, Dinheiro, Cartão Crédito...
  parcelas    text,                    -- "—", "2x".."24x"
  fornecedor  text,
  cliente     text,
  fone        text,
  cpf         text,
  email       text,
  data        date,
  vendedor    text,
  status      text,                    -- Pago, Pendente, Cancelado, Troca
  nf_os       text,                    -- nota fiscal / ordem de serviço
  obs         text,
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);


-- ────────────────────────────────────────────
-- 4. TROCAS
-- Aparelhos recebidos em troca + dados do cliente
-- ────────────────────────────────────────────
create table if not exists trocas (
  id          text primary key,        -- id gerado no app (timestamp)
  modelo      text not null,
  imei        text,
  cor         text,
  storage     text,
  bateria     text,                    -- saúde da bateria (%)
  condicao    text,                    -- Excelente, Bom, Regular, Comprometido
  mercado     numeric(10,2) default 0, -- valor de mercado do aparelho
  desconto    numeric(10,2) default 300,
  oferta      numeric(10,2) default 0, -- valor oferecido ao cliente (mercado - desconto)
  cliente     text not null,
  fone        text,
  cpf         text,
  email       text,
  data        date,
  obs         text,                    -- defeitos / observações
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);


-- ────────────────────────────────────────────
-- 5. ANALISES
-- Comparações feitas na aba "Avaliando" (prints do fornecedor)
-- ────────────────────────────────────────────
create table if not exists analises (
  id          uuid primary key default gen_random_uuid(),
  label       text,                    -- ex: "13 jun · 14:32"
  items       jsonb not null,          -- array de {model, sub, novoPreco, precoRef, status}
  created_at  timestamptz default now()
);


-- ────────────────────────────────────────────
-- 6. FORNECEDORES
-- Lista simples usada no campo "Fornecedor" da venda
-- ────────────────────────────────────────────
create table if not exists fornecedores (
  id          text primary key,
  nome        text not null,
  created_at  timestamptz default now()
);


-- ════════════════════════════════════════════════════════════
--  TRIGGERS — atualiza updated_at automaticamente
-- ════════════════════════════════════════════════════════════
create or replace function update_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists estoque_updated_at on estoque;
create trigger estoque_updated_at
  before update on estoque
  for each row execute function update_updated_at();

drop trigger if exists produtos_custom_updated_at on produtos_custom;
create trigger produtos_custom_updated_at
  before update on produtos_custom
  for each row execute function update_updated_at();

drop trigger if exists vendas_updated_at on vendas;
create trigger vendas_updated_at
  before update on vendas
  for each row execute function update_updated_at();

drop trigger if exists trocas_updated_at on trocas;
create trigger trocas_updated_at
  before update on trocas
  for each row execute function update_updated_at();


-- ════════════════════════════════════════════════════════════
--  ROW LEVEL SECURITY
--  Libera acesso total via chave anônima (anon key).
--  Ideal para uso pessoal/uma loja. Se quiser restringir por
--  usuário/login no futuro, troque "using (true)" por regras
--  baseadas em auth.uid().
-- ════════════════════════════════════════════════════════════
alter table estoque         enable row level security;
alter table produtos_custom enable row level security;
alter table vendas          enable row level security;
alter table trocas          enable row level security;
alter table analises        enable row level security;
alter table fornecedores     enable row level security;

drop policy if exists "acesso_total" on estoque;
drop policy if exists "acesso_total" on produtos_custom;
drop policy if exists "acesso_total" on vendas;
drop policy if exists "acesso_total" on trocas;
drop policy if exists "acesso_total" on analises;
drop policy if exists "acesso_total" on fornecedores;

create policy "acesso_total" on estoque         for all using (true) with check (true);
create policy "acesso_total" on produtos_custom for all using (true) with check (true);
create policy "acesso_total" on vendas          for all using (true) with check (true);
create policy "acesso_total" on trocas          for all using (true) with check (true);
create policy "acesso_total" on analises        for all using (true) with check (true);
create policy "acesso_total" on fornecedores    for all using (true) with check (true);


-- ════════════════════════════════════════════════════════════
--  ÍNDICES — agilizam os filtros mais usados no app
-- ════════════════════════════════════════════════════════════
create index if not exists idx_vendas_data    on vendas (data);
create index if not exists idx_vendas_status  on vendas (status);
create index if not exists idx_trocas_data    on trocas (data);
create index if not exists idx_estoque_model  on estoque (model, sub);

-- ════════════════════════════════════════════════════════════
--  FIM — pronto! Volte ao app, clique em "Supabase" no menu,
--  cole a Project URL e a anon public key, e clique em
--  "Testar conexão" e depois "Salvar".
-- ════════════════════════════════════════════════════════════

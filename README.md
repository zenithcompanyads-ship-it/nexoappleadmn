# Nexo Apple Controle — Configuração do Supabase

Este pacote conecta o app **Nexo Apple Controle** (`nexo-apple.html`) a um
banco de dados gratuito na nuvem (Supabase), para que seus dados de
estoque, vendas, trocas e análises fiquem salvos e sincronizados —
não dependem só do navegador/computador.

## O que vai ser sincronizado automaticamente

| Aba do app          | Tabela no Supabase   |
|---------------------|----------------------|
| Preços → Seminovos  | `estoque` (preço, frete, data de entrada, estoque) |
| Preços → Novos/Lacrados (e seminovos adicionados manualmente) | `produtos_custom` |
| Vendas              | `vendas` (registro completo de cada venda) |
| Trocas              | `trocas` (aparelhos recebidos + dados do cliente) |
| Avaliando           | `analises` (comparações de prints do fornecedor) |
| Fornecedores (campo da venda) | `fornecedores` |

---

## Passo 1 — Criar o projeto no Supabase

1. Acesse **[supabase.com](https://supabase.com)** e crie uma conta gratuita
   (pode entrar com GitHub ou Google).
2. Clique em **"New Project"**.
3. Escolha um nome (ex: `nexo-apple`), uma senha forte para o banco
   (guarde essa senha, mas você não vai precisar dela no app) e a região
   mais próxima (ex: `South America (São Paulo)`).
4. Clique em **"Create new project"** e aguarde 1–2 minutos enquanto o
   Supabase prepara o banco.

---

## Passo 2 — Rodar o schema (criar as tabelas)

1. No menu lateral do seu projeto, clique em **"SQL Editor"**.
2. Clique em **"New query"**.
3. Abra o arquivo **`schema.sql`** (está nesta mesma pasta), copie **todo o
   conteúdo** e cole no editor.
4. Clique em **"Run"** (ou `Ctrl+Enter`).
5. Deve aparecer "Success. No rows returned" — isso significa que todas
   as 6 tabelas (`estoque`, `produtos_custom`, `vendas`, `trocas`,
   `analises`, `fornecedores`) foram criadas com sucesso.

> Pode rodar o script de novo no futuro sem problema — ele usa
> `if not exists` e `drop ... if exists`, então não duplica nada.

---

## Passo 3 — Pegar a URL e a chave do projeto

1. No menu lateral, clique em **"Project Settings"** (ícone de engrenagem)
   → **"Data API"** (ou "API" em versões mais antigas).
2. Copie dois valores:
   - **Project URL** → algo como `https://xxxxxxxxxxxx.supabase.co`
   - **anon public key** (chave pública/anônima) → uma string longa
     começando com `eyJ...`

> ⚠️ Use sempre a chave **anon public**, nunca a `service_role` (essa é
> secreta e não deve ser usada no navegador).

---

## Passo 4 — Conectar no app

1. Abra o `nexo-apple.html` no navegador.
2. Clique no botão **"Supabase"** no topo da tela.
3. Cole a **Project URL** e a **anon public key**.
4. Clique em **"Testar conexão"** — deve aparecer "Conectado!" em verde.
5. Clique em **"Salvar"**.

A partir daqui:
- Toda alteração de preço, frete, estoque, venda, troca ou análise é
  enviada automaticamente para o Supabase.
- Ao abrir o app (com a conexão configurada), ele puxa automaticamente
  todos os dados salvos na nuvem.
- O indicador no topo direito mostra **"Online"** quando conectado.

---

## Usando em mais de um computador / celular

Como os dados ficam no Supabase, você pode abrir o mesmo `nexo-apple.html`
em qualquer outro computador ou celular, configurar a **mesma** Project URL
e anon key (Passo 4), e todos os dados (estoque, vendas, trocas, etc.)
aparecem automaticamente.

---

## Segurança — o que você precisa saber

O schema libera acesso total (`for all using (true)`) usando a chave
**anon**. Isso é simples e funciona bem para uso pessoal/uma loja, mas
significa que **qualquer pessoa que tiver a Project URL + anon key**
consegue ler e escrever nos dados.

Para a maioria dos casos (uso interno da loja) isso é aceitável — a chave
não fica pública em lugar nenhum, só dentro do navegador de quem você
configurar. Mas:

- **Nunca** publique o `nexo-apple.html` já configurado em um site público
  sem proteção (qualquer um que abrir o HTML veria a chave salva no
  `localStorage` do navegador dele... na verdade não, a chave fica salva
  *localmente* no navegador de cada pessoa, então isso só é um risco se
  você mesmo compartilhar a URL + chave).
- Se no futuro quiser login por usuário (cada vendedor só vê seus dados),
  dá pra evoluir o schema com Supabase Auth e trocar as policies de
  `using (true)` para `using (auth.uid() = user_id)`.

---

## Arquivos deste pacote

- **`schema.sql`** — cria todas as tabelas, índices, triggers e
  permissões necessárias. Cole no SQL Editor e rode uma vez.
- **`README.md`** — este guia.

Qualquer dúvida na hora de configurar, é só perguntar! 🚀

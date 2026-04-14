import os
import subprocess
from datetime import datetime
from pathlib import Path
from urllib.parse import quote

from PIL import Image
from playwright.sync_api import expect, sync_playwright


BASE_DIR = Path(r"C:\Users\ss1093839\Desktop\James\Aula 01")
EVIDENCIAS_DIR = BASE_DIR / "evidencias"
EVIDENCIAS_DIR.mkdir(parents=True, exist_ok=True)

PSQL_PATH = Path(r"C:\Program Files\PostgreSQL\16\bin\psql.exe")
DB_HOST = "localhost"
DB_PORT = "5433"
DB_NAME = "bancojames"
DB_USER = "postgres"
DB_PASSWORD = os.getenv("POSTGRES_PASSWORD", "123456")

SWAGGER_URL = "http://localhost:8080/swagger-ui/index.html"


def run_psql(sql: str, unaligned: bool = False) -> str:
    args = [
        str(PSQL_PATH),
        "-h",
        DB_HOST,
        "-p",
        DB_PORT,
        "-U",
        DB_USER,
        "-d",
        DB_NAME,
    ]
    if unaligned:
        args.extend(["-t", "-A", "-F", "|"])
    args.extend(["-c", sql])

    env = os.environ.copy()
    env["PGPASSWORD"] = DB_PASSWORD

    proc = subprocess.run(args, capture_output=True, text=True, env=env, encoding="utf-8", errors="replace")
    if proc.returncode != 0:
        raise RuntimeError(f"Erro no psql: {proc.stderr.strip()}")
    return proc.stdout.strip()


def escape_sql_string(value: str) -> str:
    return value.replace("'", "''")


def open_operation(block) -> None:
    classes = block.get_attribute("class") or ""
    if "is-open" not in classes:
        block.locator(".opblock-summary").first.click()


def ensure_try_it_out(block) -> None:
    try_it_out = block.get_by_role("button", name="Try it out")
    if try_it_out.count() > 0 and try_it_out.first.is_enabled():
        try_it_out.first.click()


def main() -> None:
    if not PSQL_PATH.exists():
        raise FileNotFoundError(f"psql não encontrado em: {PSQL_PATH}")

    categoria_nome = f"CategoriaPrint{datetime.now().strftime('%H%M%S')}"

    # Limpeza completa para evidência clara
    run_psql("TRUNCATE TABLE categorias RESTART IDENTITY CASCADE;")
    run_psql("TRUNCATE TABLE produto RESTART IDENTITY CASCADE;")

    post_png = EVIDENCIAS_DIR / "swagger-post-categoria-sucesso.png"
    get_png = EVIDENCIAS_DIR / "swagger-get-categorias-sucesso.png"
    db_png = EVIDENCIAS_DIR / "banco-postgresql-categoria-cadastrada.png"
    db_html = EVIDENCIAS_DIR / "banco-evidencia.html"
    pdf_path = EVIDENCIAS_DIR / "evidencias-swagger-banco.pdf"
    meta_txt = EVIDENCIAS_DIR / "categoria-criada.txt"

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(viewport={"width": 1920, "height": 1080})
        page = context.new_page()

        page.goto(SWAGGER_URL, wait_until="domcontentloaded", timeout=120000)
        page.wait_for_timeout(2500)

        # POST /api/categorias
        post_block = page.locator("#operations-Categorias-salvar")
        if post_block.count() == 0:
            post_block = page.locator(".opblock.opblock-post", has_text="/api/categorias").first
        else:
            post_block = post_block.first

        open_operation(post_block)
        ensure_try_it_out(post_block)

        body_textarea = post_block.locator("textarea.body-param__text")
        if body_textarea.count() == 0:
            body_textarea = post_block.locator("textarea")
        body_textarea.first.fill('{\n  "nome": "' + categoria_nome + '"\n}')

        post_block.get_by_role("button", name="Execute").first.click()
        expect(post_block.locator(".responses-table .response .response-col_status").first).to_contain_text("201", timeout=30000)
        expect(post_block).to_contain_text(categoria_nome, timeout=30000)
        post_block.screenshot(path=str(post_png))

        # GET /api/categorias
        get_block = page.locator("#operations-Categorias-listarPaginado")
        if get_block.count() == 0:
            get_block = page.locator(".opblock.opblock-get", has_text="/api/categorias").first
        else:
            get_block = get_block.first

        open_operation(get_block)
        ensure_try_it_out(get_block)

        get_block.get_by_role("button", name="Execute").first.click()
        expect(get_block.locator(".responses-table .response .response-col_status").first).to_contain_text("200", timeout=30000)
        expect(get_block).to_contain_text(categoria_nome, timeout=30000)
        get_block.screenshot(path=str(get_png))

        # Evidência do banco (consulta PostgreSQL)
        categoria_nome_sql = escape_sql_string(categoria_nome)
        row = run_psql(
            f"SELECT id, nome FROM categorias WHERE nome = '{categoria_nome_sql}' ORDER BY id DESC LIMIT 1;",
            unaligned=True,
        )
        total = run_psql("SELECT COUNT(*) FROM categorias;", unaligned=True)

        row_parts = row.split("|", 1) if row else ["", ""]
        row_id = row_parts[0].strip() if row_parts else ""
        row_nome = row_parts[1].strip() if len(row_parts) > 1 else ""

        html = f"""<!doctype html>
<html lang="pt-br">
<head>
  <meta charset="utf-8" />
  <title>Evidência PostgreSQL</title>
  <style>
    body {{
      font-family: Arial, sans-serif;
      margin: 24px;
      color: #111;
    }}
    h1 {{
      margin-bottom: 8px;
      font-size: 28px;
    }}
    p {{
      margin: 4px 0;
      font-size: 18px;
    }}
    code {{
      background: #f2f2f2;
      padding: 2px 6px;
      border-radius: 6px;
    }}
    table {{
      margin-top: 18px;
      border-collapse: collapse;
      width: 100%;
      font-size: 20px;
    }}
    th, td {{
      border: 1px solid #cfcfcf;
      padding: 10px;
      text-align: left;
    }}
    th {{
      background: #f7f7f7;
    }}
  </style>
</head>
<body>
  <h1>Evidência no PostgreSQL (bancojames)</h1>
  <p><strong>Banco:</strong> <code>{DB_NAME}</code> | <strong>Host:</strong> <code>{DB_HOST}:{DB_PORT}</code></p>
  <p><strong>Total em categorias após cadastro:</strong> <code>{total}</code></p>
  <p><strong>Categoria criada via Swagger:</strong> <code>{categoria_nome}</code></p>

  <table>
    <thead>
      <tr><th>ID</th><th>Nome</th></tr>
    </thead>
    <tbody>
      <tr><td>{row_id}</td><td>{row_nome}</td></tr>
    </tbody>
  </table>
</body>
</html>"""
        db_html.write_text(html, encoding="utf-8")

        db_page = context.new_page()
        db_page.goto("file:///" + quote(str(db_html).replace("\\", "/"), safe="/:"), wait_until="networkidle")
        db_page.screenshot(path=str(db_png), full_page=True)

        context.close()
        browser.close()

    meta_txt.write_text(categoria_nome, encoding="utf-8")

    # Geração do PDF final
    images = [post_png, get_png, db_png]
    pil_images = [Image.open(str(img)).convert("RGB") for img in images]
    pil_images[0].save(str(pdf_path), save_all=True, append_images=pil_images[1:])
    for img in pil_images:
        img.close()

    print(f"Categoria criada: {categoria_nome}")
    print(f"Print POST Swagger: {post_png}")
    print(f"Print GET Swagger: {get_png}")
    print(f"Print Banco: {db_png}")
    print(f"PDF final: {pdf_path}")


if __name__ == "__main__":
    main()

param(
    [string]$BaseUrl = "http://localhost:8080"
)

$ErrorActionPreference = "Stop"
$falhas = New-Object System.Collections.Generic.List[string]

function Invoke-ApiRequest {
    param(
        [Parameter(Mandatory = $true)][string]$Method,
        [Parameter(Mandatory = $true)][string]$Path,
        [object]$Body = $null
    )

    $uri = "$BaseUrl$Path"
    $headers = @{ Accept = "application/json" }
    $bodyJson = $null

    if ($null -ne $Body) {
        $bodyJson = $Body | ConvertTo-Json -Depth 8 -Compress
    }

    try {
        if ($null -ne $bodyJson) {
            $response = Invoke-WebRequest -Method $Method -Uri $uri -Headers $headers -ContentType "application/json" -Body $bodyJson -UseBasicParsing
        } else {
            $response = Invoke-WebRequest -Method $Method -Uri $uri -Headers $headers -UseBasicParsing
        }
        return [pscustomobject]@{
            StatusCode = [int]$response.StatusCode
            Body       = $response.Content
            Headers    = $response.Headers
        }
    } catch {
        if ($_.Exception -is [System.Net.WebException]) {
            $webResponse = $_.Exception.Response
            if ($null -eq $webResponse) {
                throw
            }

            $statusCode = [int]$webResponse.StatusCode
            $reader = New-Object System.IO.StreamReader($webResponse.GetResponseStream())
            $content = $reader.ReadToEnd()
            $reader.Close()

            return [pscustomobject]@{
                StatusCode = $statusCode
                Body       = $content
                Headers    = $webResponse.Headers
            }
        }

        if ($_.Exception.PSObject.Properties.Name -contains "Response" -and $null -ne $_.Exception.Response) {
            $httpResponse = $_.Exception.Response
            if ($httpResponse -is [System.Net.Http.HttpResponseMessage]) {
                $headers = @{}
                foreach ($header in $httpResponse.Headers) {
                    $headers[$header.Key] = ($header.Value -join ",")
                }

                $errorBody = ""
                if ($_.ErrorDetails -and $_.ErrorDetails.Message) {
                    $errorBody = $_.ErrorDetails.Message
                } else {
                    try {
                        $errorBody = $httpResponse.Content.ReadAsStringAsync().GetAwaiter().GetResult()
                    } catch {
                        $errorBody = ""
                    }
                }

                return [pscustomobject]@{
                    StatusCode = [int]$httpResponse.StatusCode
                    Body       = $errorBody
                    Headers    = $headers
                }
            }
        }

        throw
    }
}

function Assert-StatusCode {
    param(
        [string]$NomeTeste,
        [int]$Esperado,
        [int]$Obtido
    )

    if ($Esperado -ne $Obtido) {
        $falhas.Add("$NomeTeste -> esperado: $Esperado | obtido: $Obtido")
    } else {
        Write-Host "[OK] $NomeTeste ($Obtido)"
    }
}

function Assert-True {
    param(
        [string]$NomeTeste,
        [bool]$Condicao
    )

    if (-not $Condicao) {
        $falhas.Add("$NomeTeste -> condicao nao satisfeita")
    } else {
        Write-Host "[OK] $NomeTeste"
    }
}

Write-Host "Iniciando validacao da API em $BaseUrl"

# Swagger / OpenAPI
$swagger = Invoke-ApiRequest -Method "GET" -Path "/v3/api-docs"
Assert-StatusCode -NomeTeste "Swagger disponivel" -Esperado 200 -Obtido $swagger.StatusCode
Assert-True -NomeTeste "Swagger contem endpoint de categorias" -Condicao ($swagger.Body -match '"/api/categorias"')
Assert-True -NomeTeste "Swagger contem endpoint de produtos" -Condicao ($swagger.Body -match '"/produtos"')

# Categoria - POST valido
$categoriaNome = "Categoria Script $((Get-Random -Minimum 1000 -Maximum 9999))"
$novaCategoria = Invoke-ApiRequest -Method "POST" -Path "/api/categorias" -Body @{ nome = $categoriaNome }
Assert-StatusCode -NomeTeste "POST /api/categorias" -Esperado 201 -Obtido $novaCategoria.StatusCode
$categoriaObj = $null
if ($novaCategoria.StatusCode -eq 201) {
    $categoriaObj = $novaCategoria.Body | ConvertFrom-Json
    Assert-True -NomeTeste "Categoria criada com id" -Condicao ($categoriaObj.data.id -gt 0)
}

# Categoria - validacao
$categoriaInvalida = Invoke-ApiRequest -Method "POST" -Path "/api/categorias" -Body @{ nome = "" }
Assert-StatusCode -NomeTeste "POST /api/categorias invalido" -Esperado 400 -Obtido $categoriaInvalida.StatusCode

# Categoria - listagem paginada
$listaCategorias = Invoke-ApiRequest -Method "GET" -Path "/api/categorias?page=0&size=10&sort=nome,asc"
Assert-StatusCode -NomeTeste "GET /api/categorias paginado" -Esperado 200 -Obtido $listaCategorias.StatusCode

# Categoria - busca por nome com paginacao
$trechoNome = [System.Uri]::EscapeDataString($categoriaNome.Substring(0, [Math]::Min(8, $categoriaNome.Length)))
$buscaCategoria = Invoke-ApiRequest -Method "GET" -Path "/api/categorias?nome=$trechoNome&page=0&size=10&sort=nome,asc"
Assert-StatusCode -NomeTeste "GET /api/categorias?nome=..." -Esperado 200 -Obtido $buscaCategoria.StatusCode
if ($buscaCategoria.StatusCode -eq 200) {
    $buscaCategoriaObj = $buscaCategoria.Body | ConvertFrom-Json
    $encontrou = $false
    foreach ($item in $buscaCategoriaObj.data.content) {
        if ($item.nome -eq $categoriaNome) {
            $encontrou = $true
            break
        }
    }
    Assert-True -NomeTeste "Busca de categoria retorna item criado" -Condicao $encontrou
}

# Categoria - sem resultados (204)
$categoriaVazia = Invoke-ApiRequest -Method "GET" -Path "/api/categorias?nome=__sem_resultado_$(Get-Random)&page=0&size=10&sort=nome,asc"
Assert-StatusCode -NomeTeste "GET /api/categorias vazio" -Esperado 204 -Obtido $categoriaVazia.StatusCode

# Produto - POST valido
$produtoNome = "Produto Script $((Get-Random -Minimum 1000 -Maximum 9999))"
$novoProduto = Invoke-ApiRequest -Method "POST" -Path "/produtos" -Body @{ nome = $produtoNome; preco = 19.90 }
Assert-StatusCode -NomeTeste "POST /produtos" -Esperado 201 -Obtido $novoProduto.StatusCode
$produtoId = $null
if ($novoProduto.StatusCode -eq 201) {
    $novoProdutoObj = $novoProduto.Body | ConvertFrom-Json
    $produtoId = [int64]$novoProdutoObj.data.id
    Assert-True -NomeTeste "Produto criado com id" -Condicao ($produtoId -gt 0)
}

# Produto - listagem paginada
$listaProdutos = Invoke-ApiRequest -Method "GET" -Path "/produtos?page=0&size=10&sort=nome,asc"
Assert-StatusCode -NomeTeste "GET /produtos paginado" -Esperado 200 -Obtido $listaProdutos.StatusCode

# Produto - buscar por id
if ($null -ne $produtoId) {
    $produtoPorId = Invoke-ApiRequest -Method "GET" -Path "/produtos/$produtoId"
    Assert-StatusCode -NomeTeste "GET /produtos/{id}" -Esperado 200 -Obtido $produtoPorId.StatusCode

    # Produto - atualizar
    $produtoAtualizado = Invoke-ApiRequest -Method "PUT" -Path "/produtos/$produtoId" -Body @{ nome = "$produtoNome Atualizado"; preco = 29.90 }
    Assert-StatusCode -NomeTeste "PUT /produtos/{id}" -Esperado 200 -Obtido $produtoAtualizado.StatusCode

    # Produto - excluir
    $produtoExcluido = Invoke-ApiRequest -Method "DELETE" -Path "/produtos/$produtoId"
    Assert-StatusCode -NomeTeste "DELETE /produtos/{id}" -Esperado 204 -Obtido $produtoExcluido.StatusCode

    # Produto - buscar excluido
    $produtoRemovido = Invoke-ApiRequest -Method "GET" -Path "/produtos/$produtoId"
    Assert-StatusCode -NomeTeste "GET /produtos/{id} removido" -Esperado 404 -Obtido $produtoRemovido.StatusCode
}

# Produto - validacao de payload
$produtoInvalido = Invoke-ApiRequest -Method "POST" -Path "/produtos" -Body @{ nome = "A"; preco = -10.0 }
Assert-StatusCode -NomeTeste "POST /produtos invalido" -Esperado 400 -Obtido $produtoInvalido.StatusCode

# Produto - nao encontrado
$produtoNaoEncontrado = Invoke-ApiRequest -Method "GET" -Path "/produtos/99999999"
Assert-StatusCode -NomeTeste "GET /produtos/99999999" -Esperado 404 -Obtido $produtoNaoEncontrado.StatusCode

if ($falhas.Count -gt 0) {
    Write-Host ""
    Write-Host "Falhas encontradas:" -ForegroundColor Red
    foreach ($falha in $falhas) {
        Write-Host " - $falha" -ForegroundColor Red
    }
    exit 1
}

Write-Host ""
Write-Host "Validacao concluida com sucesso. Todos os testes da API passaram." -ForegroundColor Green
exit 0

Add-Type -AssemblyName System.Net.HttpListener
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add('http://127.0.0.1:4231/')
$listener.Start()
$root = 'C:\Users\mavr\source\repos\Codex\workout_journal_flutter\build\web'
while ($listener.IsListening) {
  $context = $listener.GetContext()
  try {
    $path = $context.Request.Url.AbsolutePath.TrimStart('/')
    if ([string]::IsNullOrWhiteSpace($path)) { $path = 'index.html' }
    $filePath = Join-Path $root $path
    if (-not (Test-Path $filePath)) { $filePath = Join-Path $root 'index.html' }
    $ext = [System.IO.Path]::GetExtension($filePath).ToLowerInvariant()
    $contentType = switch ($ext) {
      '.html' { 'text/html; charset=utf-8' }
      '.js' { 'application/javascript; charset=utf-8' }
      '.json' { 'application/json; charset=utf-8' }
      '.css' { 'text/css; charset=utf-8' }
      '.png' { 'image/png' }
      '.jpg' { 'image/jpeg' }
      '.jpeg' { 'image/jpeg' }
      '.svg' { 'image/svg+xml' }
      '.wasm' { 'application/wasm' }
      '.ico' { 'image/x-icon' }
      '.ttf' { 'font/ttf' }
      '.otf' { 'font/otf' }
      '.woff' { 'font/woff' }
      '.woff2' { 'font/woff2' }
      default { 'application/octet-stream' }
    }
    $bytes = [System.IO.File]::ReadAllBytes($filePath)
    $context.Response.ContentType = $contentType
    $context.Response.ContentLength64 = $bytes.Length
    $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    $context.Response.OutputStream.Close()
  } catch {
    $context.Response.StatusCode = 500
    $msg = [System.Text.Encoding]::UTF8.GetBytes($_.Exception.Message)
    $context.Response.OutputStream.Write($msg, 0, $msg.Length)
    $context.Response.OutputStream.Close()
  }
}

$ErrorActionPreference = "Stop"

$PrimaryUrl = "http://192.168.18.86/sdust"
$FallbackUrl1 = "https://hk.gh-proxy.org/https://github.com/Runzelee/sdust-install/raw/refs/heads/main"
$FallbackUrl2 = "https://github.com/Runzelee/sdust-install/raw/refs/heads/main"
$BinDir  = "$env:USERPROFILE\.local\bin"
$BinPath = "$BinDir\sdust.exe"
$Target  = "sdust-x86_64-pc-windows-gnu.exe"

New-Item -ItemType Directory -Force -Path $BinDir | Out-Null

Write-Host "尝试从内网下载 $Target ..."
try {
    Invoke-WebRequest -Uri "$PrimaryUrl/$Target" -OutFile $BinPath -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    Write-Host "已保存到 $BinPath"
} catch {
    Write-Host "内网访问失败，尝试使用备用镜像链接下载..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "$FallbackUrl1/$Target" -OutFile $BinPath -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        Write-Host "已保存到 $BinPath"
    } catch {
        Write-Host "备用镜像访问失败，尝试使用 GitHub 原链接下载..." -ForegroundColor Yellow
        try {
            Invoke-WebRequest -Uri "$FallbackUrl2/$Target" -OutFile $BinPath -UseBasicParsing -ErrorAction Stop
            Write-Host "已保存到 $BinPath"
        } catch {
            Write-Host "下载失败！找不到请去 sdust 仓库的 release 下载。" -ForegroundColor Red
            exit 1
        }
    }
}

# 添加到用户 PATH
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*$BinDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$BinDir", "User")
    # 同时更新当前会话的 PATH，使立即可用
    $env:Path = "$env:Path;$BinDir"
    Write-Host "已将 $BinDir 添加到用户 PATH。"
} else {
    Write-Host "$BinDir 已在 PATH 中。"
}

Write-Host ""
Write-Host "安装完成！请重新打开终端，然后运行 sdust 验证。" -ForegroundColor Green

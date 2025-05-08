# Colors for better visibility
$RED = [System.ConsoleColor]::Red
$GREEN = [System.ConsoleColor]::Green
$YELLOW = [System.ConsoleColor]::Yellow
$CYAN = [System.ConsoleColor]::Cyan

# Global variables
$refreshRate = 2000 # Default refresh rate in milliseconds
$showDetails = $false
$currentPid = $null

function Print-Header {
    Clear-Host
    Write-Host "=== Enhanced System Process Monitor ===" -ForegroundColor $GREEN
    Write-Host "Controls:" -ForegroundColor $YELLOW
    Write-Host "  q - Quit" -ForegroundColor $YELLOW
    Write-Host "  k - Kill process" -ForegroundColor $YELLOW
    Write-Host "  s - Search process" -ForegroundColor $YELLOW
    Write-Host "  d - Toggle process details" -ForegroundColor $YELLOW
    Write-Host "  t - Show process tree" -ForegroundColor $YELLOW
    Write-Host "  n - Show network connections" -ForegroundColor $YELLOW
    Write-Host "  r - Change refresh rate" -ForegroundColor $YELLOW
    Write-Host "  + - Increase refresh rate" -ForegroundColor $YELLOW
    Write-Host "  - - Decrease refresh rate" -ForegroundColor $YELLOW
    Write-Host ""
}

function Show-SystemResources {
    Write-Host "`nSystem Resources:" -ForegroundColor $CYAN
    $cpu = Get-CimInstance Win32_Processor | Select-Object -ExpandProperty LoadPercentage
    $memory = Get-CimInstance Win32_OperatingSystem
    $totalMemory = [math]::Round($memory.TotalVisibleMemorySize / 1MB, 2)
    $freeMemory = [math]::Round($memory.FreePhysicalMemory / 1MB, 2)
    $usedMemory = [math]::Round(($memory.TotalVisibleMemorySize - $memory.FreePhysicalMemory) / 1MB, 2)
    
    Write-Host "CPU Usage: $cpu%" -ForegroundColor $CYAN
    Write-Host "Memory: $usedMemory GB used / $totalMemory GB total ($([math]::Round(($usedMemory/$totalMemory)*100))% used)" -ForegroundColor $CYAN
}

# To kill a process
function Kill-Process {
    Write-Host "Enter PID to kill: " -ForegroundColor $YELLOW -NoNewline
    $pid = Read-Host
    $process = Get-Process -Id $pid -ErrorAction SilentlyContinue
    if ($process) {
        Write-Host "Are you sure you want to kill process $pid? (y/n)" -ForegroundColor $YELLOW
        $confirm = Read-Host
        if ($confirm -eq "y") {
            try {
                Stop-Process -Id $pid -Force
                Write-Host "Process $pid killed successfully" -ForegroundColor $GREEN
            }
            catch {
                Write-Host "Failed to kill process $pid" -ForegroundColor $RED
            }
        }
    }
    else {
        Write-Host "Process $pid does not exist" -ForegroundColor $RED
    }
    Start-Sleep -Seconds 2
}

function Search-Process {
    Write-Host "Enter process name to search: " -ForegroundColor $YELLOW -NoNewline
    $searchTerm = Read-Host
    $processes = Get-Process | Where-Object { $_.ProcessName -like "*$searchTerm*" }
    if ($processes) {
        $processes | Format-Table -Property Id, ProcessName, CPU, WorkingSet
    }
    else {
        Write-Host "No processes found matching '$searchTerm'" -ForegroundColor $RED
    }
    Start-Sleep -Seconds 2
}

function Show-ProcessDetails {
    param($pid)
    if ($pid) {
        $process = Get-Process -Id $pid -ErrorAction SilentlyContinue
        if ($process) {
            Write-Host "`nDetailed Process Information:" -ForegroundColor $CYAN
            Write-Host "Process Name: $($process.ProcessName)"
            Write-Host "PID: $($process.Id)"
            Write-Host "CPU Time: $($process.TotalProcessorTime)"
            Write-Host "Memory Usage: $([math]::Round($process.WorkingSet64 / 1MB, 2)) MB"
            Write-Host "Threads: $($process.Threads.Count)"
            Write-Host "Start Time: $($process.StartTime)"
            Write-Host "Path: $($process.Path)"
        }
    }
}

# To show process tree
function Show-ProcessTree {
    $processes = Get-Process | Where-Object { $_.MainWindowTitle }
    Write-Host "`nProcess Tree:" -ForegroundColor $CYAN
    foreach ($process in $processes) {
        Write-Host "$($process.ProcessName) (PID: $($process.Id))"
        if ($process.MainWindowTitle) {
            Write-Host "  Window: $($process.MainWindowTitle)"
        }
    }
}

function Show-NetworkConnections {
    Write-Host "`nNetwork Connections:" -ForegroundColor $CYAN
    Get-NetTCPConnection | Where-Object State -eq 'Established' | 
    ForEach-Object {
        $process = Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue
        if ($process) {
            Write-Host "$($process.ProcessName) (PID: $($process.Id))"
            Write-Host "  Local: $($_.LocalAddress):$($_.LocalPort)"
            Write-Host "  Remote: $($_.RemoteAddress):$($_.RemotePort)"
        }
    }
}

# refresh rate
function Change-RefreshRate {
    Write-Host "Enter new refresh rate in milliseconds (1000-10000): " -ForegroundColor $YELLOW -NoNewline
    $newRate = Read-Host
    if ($newRate -match '^\d+$' -and $newRate -ge 1000 -and $newRate -le 10000) {
        $script:refreshRate = [int]$newRate
        Write-Host "Refresh rate set to $newRate ms" -ForegroundColor $GREEN
    }
    else {
        Write-Host "Invalid refresh rate. Must be between 1000 and 10000 ms" -ForegroundColor $RED
    }
    Start-Sleep -Seconds 1
}

while ($true) {
    Print-Header
    Show-SystemResources
    
    # Display top processes sorted by CPU usage
    Write-Host "`nTop CPU-consuming processes:" -ForegroundColor $GREEN
    Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 | Format-Table -Property Id, ProcessName, CPU, WorkingSet
    
    Write-Host "`nTop memory-consuming processes:" -ForegroundColor $GREEN
    Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 5 | Format-Table -Property Id, ProcessName, CPU, WorkingSet
    
    if ($showDetails -and $currentPid) {
        Show-ProcessDetails -pid $currentPid
    }
    
    # Check for key press
    if ([Console]::KeyAvailable) {
        $key = [Console]::ReadKey($true)
        switch ($key.KeyChar) {
            'q' { 
                Write-Host "`nExiting..." -ForegroundColor $GREEN
                exit
            }
            'k' {
                Kill-Process
            }
            's' {
                Search-Process
            }
            'd' {
                $showDetails = !$showDetails
                if ($showDetails) {
                    Write-Host "Enter PID to show details: " -ForegroundColor $YELLOW -NoNewline
                    $currentPid = Read-Host
                }
            }
            't' {
                Show-ProcessTree
                Start-Sleep -Seconds 2
            }
            'n' {
                Show-NetworkConnections
                Start-Sleep -Seconds 2
            }
            'r' {
                Change-RefreshRate
            }
            '+' {
                $script:refreshRate = [Math]::Min($refreshRate + 500, 10000)
                Write-Host "Refresh rate increased to $refreshRate ms" -ForegroundColor $GREEN
            }
            '-' {
                $script:refreshRate = [Math]::Max($refreshRate - 500, 1000)
                Write-Host "Refresh rate decreased to $refreshRate ms" -ForegroundColor $GREEN
            }
        }
    }
    
    Start-Sleep -Milliseconds $refreshRate
} 
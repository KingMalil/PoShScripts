param(
    [Switch]$FirstRun
)
if ($FirstRun) {
    [String]$FilePath = 'C:\Backups\AutoDownloads'
    [String]$CopyPath = 'C:\Backups\Duplicates'
    [String]$HashPath = 'C:\Backups\FileHashes.csv'
    [Int]$loops = 0
    Write-Progress -Activity "Running initial check." -Status "Getting file count." -PercentComplete 0
    $hashes = New-Object System.Collections.ArrayList
    [DateTime]$startTime = Get-Date
    [Int]$files = 0
    [Boolean]$FirstTime = $true
    if (Test-Path -Path $HashPath) {Remove-Item -Path $HashPath}

    do {
        [Int]$movedFiles = 0
        [Int]$totalFiles = $(Get-ChildItem -Path $FilePath -Recurse -File).Count
        [DateTime]$lastLoop = Get-Date
        $loops++
        Get-ChildItem -Path $FilePath -Recurse -File | Where-Object {if ($FirstTime) {$true} else {$_.CreationTime -gt $lastLoop}} | ForEach-Object {
            $files++
            if ($files -gt $totalFiles) {
                do {
                    $totalFiles++
                } while ($files -ge $totalFiles)
            }
            [TimeSpan]$TimeSpent = New-TimeSpan -Start $startTime -End (Get-Date)
            $TotalSeconds = $TimeSpent.TotalSeconds * ($totalFiles / $(if ($files -gt 1) {$files - 1} else {$files}))
            [DateTime]$TimeDone = $startTime.AddSeconds($TotalSeconds)
            [TimeSpan]$TimeLeft = New-TimeSpan -Start (Get-Date) -End $TimeDone
            [String]$Time = "$($TimeLeft.Minutes):$(if ($TimeLeft.Seconds -lt 10) {"0$($TimeLeft.Seconds)"} else {"$($TimeLeft.Seconds)"})"
            [String]$hash = $(Get-FileHash $_.FullName).Hash
            if ($hashes.Count -eq 0) {
                #Write-Host "Adding hash $Hash." -ForegroundColor Green
                Write-Progress -Activity "Running initial check, loop $loops" -Status "Adding file $files of $totalFiles, $time left." -PercentComplete $([Math]::Round($($($files) / $totalFiles * 100)))
                $output = New-Object psobject
                $output | Add-Member -MemberType NoteProperty -Name "FileName" -Value $_.FullName
                $output | Add-Member -MemberType NoteProperty -Name "Hash" -Value $hash
                $hashes.Add($output) | Out-Null
            } else {
                if ($hashes.Hash.Contains($hash)) {
                    Move-Item -Path $_.FullName -Destination $CopyPath -Force
                    Write-Host "Moving duplicate $($_.Name)." -ForegroundColor Yellow
                    Write-Progress -Activity "Running initial check, loop $loops" -Status "Moving file $files of $totalFiles, $time left." -PercentComplete $([Math]::Round($($($files) / $totalFiles * 100)))
                    $movedFiles++
                } else {
                    #Write-Host "Adding hash $Hash." -ForegroundColor Green
                    Write-Progress -Activity "Running initial check, loop $loops" -Status "Adding file $files of $totalFiles, $time left." -PercentComplete $([Math]::Round($($($files) / $totalFiles * 100)))
                    $output = New-Object psobject
                    $output | Add-Member -MemberType NoteProperty -Name "FileName" -Value $_.FullName
                    $output | Add-Member -MemberType NoteProperty -Name "Hash" -Value $hash
                    $hashes.Add($output) | Out-Null
                }
            }
        }
        $FirstTime = $false
        [TimeSpan]$timeElapsed = New-TimeSpan -Start $startTime -End $(Get-Date)
        Write-Progress -Activity "Running initial check, loop $loops" -Completed
        Write-Host "`nDone checking files on loop $loop." -ForegroundColor White
        Write-Host "$files file$(if ($files -ne 1) {"s"}) checked in $($timeElapsed.Minutes):$($timeElapsed.Seconds).$($timeElapsed.Milliseconds)" -ForegroundColor Green
        Write-Host "$movedFiles duplicate file$(if ($movedFiles -ne 1) {"s"}) moved." -ForegroundColor Yellow
    } while (
        (Get-ChildItem -Path $path -Recurse -File | Where-Object {$_.CreationTime -gt $lastLoop}).Count -gt 0
    )
    $hashes | Export-Csv -Path $HashPath -Force
    Write-Host "All files checked in $loops loops."
}
#Start-Process -FilePath "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File C:\backups\DuplicateChecker.ps1" -NoNewWindow -Wait
[String]$path = "C:\Backups\AutoDownloads"
[String]$movePath = "C:\Backups\Duplicates"
[String]$hashPath = "C:\Backups\FileHashes.csv"
$fsw = New-Object IO.FileSystemWatcher $path
$fsw.IncludeSubdirectories = $true
$fsw.Filter = "*.*"
$csv = New-Object System.Collections.ArrayList
if (Test-Path -Path $hashPath) {
    Import-Csv $HashPath | ForEach-Object {
        $csv.Add($_) | Out-Null
    }
}
$photoExt = New-Object System.Collections.ArrayList
$videoExt = New-Object System.Collections.ArrayList
$musicExt = New-Object System.Collections.ArrayList
$photos = "ani,bmp,cal,fax,gif,img,jbg,jpe,jpeg,jpg,mac,pem,pcd,pcx,pct,pgm,png,ppm,psd,ras,tga,tiff,wmf"
$videos = "webm,mkv,flv,vob,ogv,ogg,drc,gifv,mng,avi,mov,qt,wmv,yuv,rm,rmvb,asf,amv,mp4,m4p,m4v,mpg,mp2,mpeg,mpe,mpv,m2v,svi,3gp,3g2,mxf,roq,nsv,flv,f4v,f4p,f4a,f4b"
$musics = "3gp,aa,aac,aax,act,aiff,amr,ape,au,awb,dct,dss,dvf,flac,gsm,iklax,ivs,mmf,mp3,mpc,msv,oga,opus,ra,rm,raw,sln,tta,vox,wav,wma,wv,webm,8svx"
$photos.Split(",") | ForEach-Object {
    $photoExt.Add($_) | Out-Null
}
$videos.Split(",") | ForEach-Object {
    $videoExt.Add($_) | Out-Null
}
$musics.Split(",") | ForEach-Object {
    $musicExt.Add($_) | Out-Null
}

Register-ObjectEvent $fsw Created -SourceIdentifier FileCreated -Action {
    [String]$name = $Event.SourceEventArgs.Name
    [String]$fullName = "$path\$name"
    [String]$changeType = $Event.SourceEventArgs.ChangeType
    [String]$extension = $(Get-Item -Path $fullName).Extension.TrimStart(".")
    [DateTime]$timeStamp = $Event.TimeGenerated
    [String]$hash = $(Get-FileHash $fullName).Hash
    if ($(Get-Item -Path $fullName) -is [System.IO.FileInfo] -and $(Get-Item -Path $fullName).Directory.Name -eq "Photos") {
        Write-Host "$name ($fullName) $changeType at $timeStamp" -ForegroundColor Yellow
        if ($csv.Hash.Contains($hash)) {
            if (Test-Path -Path $fullName) {
                Move-Item -Path $fullName -Destination $movePath -Force
                Write-Host "Duplicate moved to $movePath." -ForegroundColor Cyan
            } else {
                Write-Host "Original file no longer exists.  Not moving duplicate." -ForegroundColor DarkYellow
            }
        } else {
            $obj = New-Object psobject
            $obj | Add-Member -MemberType NoteProperty -Name "FileName" -Value $fullName
            $obj | Add-Member -MemberType NoteProperty -Name "Hash" -Value $hash
            $obj | Export-Csv -Path $hashPath -Append -NoTypeInformation
            $csv.Add($obj)
            Write-Host "Hash added to catalog." -ForegroundColor Blue
        }
    }
} | Out-Null

[Boolean]$continue = $true

do {
    Write-Host "Waiting for next change." -ForegroundColor Green
    $fsw.WaitForChanged([System.IO.WatcherChangeTypes]::Created) | Out-Null
} while (
    $continue
)
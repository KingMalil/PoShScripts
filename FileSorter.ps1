[String]$path = "C:\Backups\DropOffs"
[String]$movepath = "C:\backups\AutoDownloads"
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

Write-Host "Looking for files..." -ForegroundColor Yellow

do {
    if ((Get-ChildItem -Path $path -Recurse -File -Hidden).count -gt 0) {
        if ($name -eq (Get-ChildItem -Path $path -Recurse -File | select -First 1).Name) {Start-Sleep -Seconds 30}
        [String]$name = (Get-ChildItem -Path $path -Recurse -File | select -First 1).Name
        [String]$fullName = (Get-ChildItem -Path $path -Recurse -File | select -First 1).FullName
        [String]$extension = (Get-ChildItem -Path $path -Recurse -File | select -First 1).Extension.TrimStart(".")
        if ($photoExt.Contains($extension)) {
            Move-Item -Path $fullName -Destination "$movepath\Photos" -Force -ErrorAction SilentlyContinue
            Write-Host "Moving $name to Photos." -ForegroundColor Green
        } elseif ($videoExt.Contains($extension)) {
            Move-Item -Path $fullName -Destination "$movepath\Videos" -Force -ErrorAction SilentlyContinue
            Write-Host "Moving $name to Videos." -ForegroundColor Green
        } elseif ($musicExt.Contains($extension)) {
            Move-Item -Path $fullName -Destination "$movepath\Music" -Force -ErrorAction SilentlyContinue
            Write-Host "Moving $name to Music." -ForegroundColor Green
        } else {
            Move-Item -Path $fullName -Destination "$movepath\Documents" -Force -ErrorAction SilentlyContinue
            Write-Host "Moving $name to Documents." -ForegroundColor Green
        }
    } else {
        Start-Sleep -Seconds 5
    }
} while (
    $true
)
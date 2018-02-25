[Reflection.Assembly]::LoadFile(“C:\users\Talos.Nirn\documents\scripts\IMAPX\imapx.dll”) | Out-Null
[String]$msgMode = "Full"
[String]$Host = "imap.gmail.com"
[Int]$port = 993
[Int]$maxMsgCount = 100
[Boolean]$Ssl = $true
[String]$username = Get-Content 'C:\Backups\Strings\AutoDLUsername.txt'
$pwd = Get-Content 'C:\Backups\Strings\Password.txt' | ConvertTo-SecureString
[String]$savepath = 'C:\Backups\DropOffs'
[String]$logfile = 'C:\Backups\Logs\AutoDownload.csv'
[String]$searchmode = 'UNSEEN'
do {
    $client = New-Object ImapX.ImapClient
    $client.Behavior.MessageFetchMode = $msgMode
    $client.Host = $Host
    $client.Port = $port
    $client.UseSsl = $Ssl
    $client.Connect() | Out-Null
    if ($client.IsConnected) {
        $client.Login($username,[System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pwd))) | Out-Null
        if ($client.IsAuthenticated) {
            $messages = $client.Folders.Inbox.Search($searchmode, $client.Behavior.MessageFetchMode, $maxMsgCount)
            if ($messages.count -gt 0) {
                foreach($m in $messages) {
                    if (-Not $m.Seen) {
                        $obj = New-Object psobject
                        $obj | Add-Member -MemberType NoteProperty -Name "Subject" -Value $m.Subject
                        $obj | Add-Member -MemberType NoteProperty -Name "From" -Value $m.From
                        $obj | Add-Member -MemberType NoteProperty -Name "DateSent" -Value $m.Date
                        $obj | Add-Member -MemberType NoteProperty -Name "AttachCount" -Value $m.Attachments.Count
                        $m.seen = $true
                        if ($m.Seen) {
                            $obj | Add-Member -MemberType NoteProperty -Name "Processed" -Value "True"
                        }
                        if ($m.Attachments.Count -gt 0) {
                            foreach($a in $m.Attachments) {
                                <#if (-not $(Test-Path -Path "C:\Backups\AutoDownloads\$($m.From)")) {
                                    New-Item -ItemType Directory -Path "C:\Backups\AutoDownloads\$($m.From)" -Force -ErrorVariable err
                                    if ($err) {
                                        $obj | Add-Member -MemberType NoteProperty -Name "Error" -Value $err
                                    }
                                }
                                $a.Save("C:\Backups\AutoDownloads\$($m.From)","$($a.Filename)")#>
                                $a.Save("C:\Backups\AutoDownloads","$($a.FileName)")
                            }
                        }
                        $obj | Export-Csv -Path $logfile -Append -Force
                    }
                }
            }
            $client.Logout()
        }
        $client.Disconnect()
    }
    Start-Sleep 60
} while ($true)
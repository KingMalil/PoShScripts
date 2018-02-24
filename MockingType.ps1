Function Mocking-Type {
    param(

        [Parameter(Mandatory=$True,Position=0,HelpMessage="String to convert.")][ValidateLength(1,2048)][String]$ToMock,
        [Parameter(Mandatory=$false,Position=1,HelpMessage="Number of lowercase letters between each upper case.  Defaults to 1.")][ValidateRange(0,5)][Int32]$spacing = 1

    )

    $array = $ToMock.ToString().ToLower().ToCharArray()
    [String]$Output = ""
    [Int32]$count = $spacing
    
    $array | ForEach-Object {
        if ($_ -match '[a-z]') {
            if ($count -eq $spacing) {
                $count = 0
                $output += $_.ToString().ToUpper()
            } else {
                $output += $_.ToString()
                $count++
            }
        } else {
            $output += $_.ToString()
        }
    }

    Write-Host $Output
    
}
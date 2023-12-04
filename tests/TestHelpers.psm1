
function Get-SourceFilePath {
    [CmdletBinding()]
    param()
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        <#------------------------------------------------------------------
         #! We assume that the source directory is structured the same
         #! as the tests directory
        ------------------------------------------------------------------#>
        $callStack = Get-PSCallStack
        $caller = $callStack[1]
        $testFileName = Split-Path $caller.ScriptName -LeafBase
        $testFileDir = Split-Path $caller.ScriptName -Parent

        #-------------------------------------------------------------------------------
        #region Source file name
        if (-not ([string]::IsNullorEmpty($testFileName))) {
            $sourceFileName = $testFileName -replace '\.Tests', ''
            $sourceFileName = "$sourceFileName.ps1"
        } else {
            throw "Could not determine the test file name"
        }

        #endregion Source file name
        #-------------------------------------------------------------------------------

        #-------------------------------------------------------------------------------
        #region Source directory
        if (-not ([string]::IsNullorEmpty($testFileDir))) {
            $sourceFileDir = $testFileDir -replace '[\\|/]Unit', '' -replace 'tests', 'source'
        } else {
            throw "Could not determine the test file name"
        }
        #endregion Source directory
        #-------------------------------------------------------------------------------

        #-------------------------------------------------------------------------------
        #region Get source file
        $sourcePath = (Join-Path $sourceFileDir $sourceFileName)

        if (Test-Path $sourcePath) {
            $sourcePath | Write-Output
        } else {
            throw (-join (
                "Could not find source item for '$testFileName' :`n",
                "Computed source filename :  $sourceFileName`n",
                "Computed source directory : $sourceFileDir`n",
                "Final: $sourcePath"
            ))
        }
        #endregion Get source file
        #-------------------------------------------------------------------------------
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}

function Get-TestDataPath {
    <#
    .SYNOPSIS
        Return the data directory associated with the test
    #>
    [CmdletBinding()]
    param( )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        $callStack = Get-PSCallStack
        $caller = $callStack[1]
        if ($caller.ScriptName -like $callStack[0].ScriptName) {
            $caller = $callStack[2]
        }

        $dataDirectory = ($caller.ScriptName -replace '\.Tests\.ps1', '.Data')
        if (-not ([string]::IsNullorEmpty($dataDirectory))) {
            $dataDirectory | Write-Output
        } else {
            throw "Could not determine the data directory"
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}

function Resolve-Dependency {
    <#
    .SYNOPSIS
        Attempt to find the file for the resource requested
    .DESCRIPTION
        Provide a means for a test to lookup the path to a needed function, class , etc.
    .EXAMPLE
        $myTest = 'Test-MyItem' | Resolve-Dependency
        if ($null -ne $myTest) {
            . $myTest
        }
    #>
    [CmdletBinding()]
    param(
        # Name of the function or resource
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string]$Name
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        $sourceItem = Get-SourceItem | Where-Object Name -Like $Name -ErrorAction SilentlyContinue
        if ($null -ne $sourceItem) {
            $sourceItem.Path
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}

function Get-TestData {
    [CmdletBinding()]
    param(
        # The filter to apply (as a script block)
        [Parameter(
        )]
        [scriptblock]$Filter
    )

    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
    process {
        $dataDir = Get-TestDataPath
        if (-not ([string]::IsNullorEmpty($dataDir))) {
            if (-not ([string]::IsNullorEmpty($Filter))) {
                Get-ChildItem -Path $dataDir
                | Where-Object $Filter
            } else {
                Get-ChildItem -Path $dataDir
            }
        } else {
            throw "Could not find data Directory for $((Get-PSCallStack)[1].ScriptName) "
        }
    }
    end {
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}

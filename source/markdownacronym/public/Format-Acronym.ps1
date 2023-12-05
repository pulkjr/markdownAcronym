
function Format-Acronym {
    <#
    .SYNOPSIS
        Replace specific keywords in a markdown file with React.js elements, but not in Codeblocks
    #>
    [CmdletBinding()]
    param(
        # The markdown content to look for keywords in and replace them in the output
        [Parameter(
            ValueFromPipeline
        )]
        [string[]]$Content,

        # A hashtable of acronyms
        [Parameter(
        )]
        [hashtable]$Acronyms
    )
    begin {
        Write-Debug "`n$('-' * 80)`n-- Begin $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
        if ($null -eq $Acronyms) {
            throw "No Acronyms provided to replace in Content"
        }
        $collect = ''
    }
    process {
        #! We want all the Content, and it may be coming in from the pipeline, so collect it up first
        $collect += $Content
    }
    end {
        if (-not ([string]::IsNullorEmpty($collect))) {
            try {
                $doc = $collect | ConvertTo-MarkdigObject
            } catch {
                $message = "There were errors parsing the markdown"
                $exceptionText = ( @($message, $_.ToString()) -join "`n")
                $thisException = [Exception]::new($exceptionText)
                $eRecord =  [System.Management.Automation.ErrorRecord]::new(
                    $thisException,
                    $null,                    # errorId
                    $_.CategoryInfo.Category, # errorCategory
                    $null                     # targetObject
                )
                $PSCmdlet.ThrowTerminatingError( $eRecord )
            }
        }
        #! Get-MarkdownElement performs Depth-First traversal of AST
        foreach ($token in (Get-MarkdownElement $doc)) {
            switch ($token.GetType().FullName) {
                'Markdig.Syntax.ParagraphBlock' {
                    Write-Debug "Line $($token.Line) Column $($token.Column) is a paragraph block"
                    $paraText = $token | Write-MarkdownElement
                    $newText = $paraText
                    foreach ($acronym in $Acronyms.Keys) {
                        if ($newText -match "\b$([regex]::Escape($acronym))\b") {
                            Write-Debug "Replacing $acronym"
                            $newText = $newText -replace "\b$([regex]::Escape($acronym))\b", "<Acr>$acronym</Acr>"
                            Write-Debug " - text is now '$newText'"
                        } else {
                            Write-Debug "$acronym not found in string"
                        }
                    }
                    #! if we made any changes
                    if ($paraText -notlike $newText) {
                        Write-Debug "Updating paragraph in document"
                        # Create a new element with the new text
                        $newElement = $newText | ConvertTo-MarkdigObject
                        if ($null -ne $newElement) {
                            Write-Debug "New element created"
                            try {
                                if ($null -ne $newElement[0].Inline) {
                                    [void]$token.Inline.FirstChild.ReplaceBy($newElement[0].Inline, $true)
                                }
                            } catch {
                                throw "Could not update token at Line $($token.Line) $($token.Column)`n$_"
                            }
                        }
                    }
                }
            }
        }
        $doc | Write-MarkdownElement
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}

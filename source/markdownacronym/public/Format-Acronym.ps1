
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
            throw 'No Acronyms provided to replace in Content'
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
                $message = 'There were errors parsing the markdown'
                $exceptionText = ( @($message, $_.ToString()) -join "`n")
                $thisException = [Exception]::new($exceptionText)
                $eRecord =  [System.Management.Automation.ErrorRecord]::new(
                    $thisException,
                    $null, # errorId
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
                    Write-Debug "Line $($token.Line) Column $($token.Column) is a paragraph block of a $($token.Parent.GetType().FullName)"

                    $token.Inline.ForEach({
                            if ($_.GetType().FullName -like 'Markdig.Syntax.Inlines.LineBreakInline') {
                                continue
                            }
                            $inlineText = ($_ | Write-MarkdownElement)
                            Write-Debug "Evaluating $($_.GetType().FullName) '$inlineText'"
                            $newText = $inlineText
                            foreach ($acronym in $Acronyms.Keys) {
                                if ($newText -match "\b$([regex]::Escape($acronym))\b") {
                                    Write-Debug "- Replacing $acronym"
                                    $newText = $newText -replace "\b$([regex]::Escape($acronym))\b", "<Acr>$acronym</Acr>"
                                } else {
                                    Write-Debug "$acronym not found in string"
                                }
                            }
                            Write-Debug "  - text is now '$newText'"
                            #! if we made any changes
                            if ($inlineText -notlike $newText) {
                                Write-Debug '- Updating paragraph in document'
                                # Create a new element with the new text
                                $newInline = ConvertTo-MarkdigObject -Text $newText
                                if ($null -ne $newInline) {
                                    Write-Debug "  - New $($newInline[0].GetType().FullName) element created"
                                    try {
                                        if ($null -ne $newInline[0].Inline) {
                                            Write-Debug "    - Inline token before: $($_ | Write-MarkdownElement))"
                                            [void]$_.ReplaceBy($newInline[0].Inline, $true)
                                            Write-Debug "    - Inline token after : $($_ | Write-MarkdownElement))"
                                        } else {
                                            Write-Debug '    - new text does not have an Inline'
                                        }
                                    } catch {
                                        throw "Could not update token at Line $($token.Line) $($token.Column)`n$_"
                                    }
                                    Remove-Variable newInline, newInlineText, newText -ErrorAction SilentlyContinue
                                } else {
                                    Write-Debug '  - Did not create new element'
                                }
                            } else {
                                Write-Debug '- No changes to inline element'
                            }
                        })
                }
                default {
                    Write-Debug "Token is a '$($token.GetType.FullName)' skipping"
                }
            }
        }
        $doc | Write-MarkdownElement | Write-Output
        Write-Debug "`n$('-' * 80)`n-- End $($MyInvocation.MyCommand.Name)`n$('-' * 80)"
    }
}

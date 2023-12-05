BeforeAll {
    $sourceFile = Get-SourceFilePath
    if (Test-Path $sourceFile) {
        . $sourceFile
    } else {
        throw "Could not find $sourceFile from $PSCommandPath"
    }
    $dataDirectory = Get-TestDataPath
}

Describe 'Testing the public function Format-Acronym' -Tag @('unit', 'Format-Acronym') {
    Context 'The command is available from the module' {
        BeforeAll {
            $command = Get-Command 'Format-Acronym'
        }

        It 'Should load without error' {
            $command | Should -Not -BeNullOrEmpty
        }
    }

    Context 'GIVEN a process written in markdown with Acronyms and Keywords AND a acronym input file JSON or YAML' {
        Context 'WHEN the build runs' {
            BeforeAll {
                $acronymConfig = Join-Path $dataDirectory 'config.yml'
                if (Test-Path $acronymConfig) {
                    try {
                        $acronyms = Get-Content $acronymConfig | ConvertFrom-Yaml
                    } catch {
                        throw "There was an error parsing the acronym config.`n$_"
                    }
                }

                $inputFile = Join-Path $dataDirectory 'Instructions.md'
                $expectedOutputFile = Join-Path $dataDirectory 'Expected.md'

                $expected = Get-Content $expectedOutputFile -Raw

                $output = Get-Content -Raw $inputFile | Format-Acronym -Acronyms $acronyms -Debug
                $output | Out-File 'testoutput.md'
            }
            It 'THEN the acronyms ad keywords should be updated with a React component' {
                $output | Should -BeLikeExactly $expected -Because "Expected`n$([regex]::Escape($expected) -replace '\n', "\n`n")`nBut it was`n$([regex]::Escape($output) -replace '\n', "\n`n")"
            }
        }
    }
}

BeforeDiscovery {
    $markdownTestData = [System.Collections.ArrayList]::new()
    Get-TestData -Filter { $_.Name -like '*.input.md' }
    | ForEach-Object {
        $testData = @{
            InputFile    = $_.FullName
            ExpectedFile = ($_.FullName -replace '\.input\.md$', '.expected.md')
        }
        [void]$markdownTestData.Add($testData)
    }
}

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

    Context "GIVEN a process written in markdown with Acronyms and Keywords `nAND a acronym input file JSON or YAML" {
        Context 'WHEN the input is <Input>' -ForEach $markdownTestData {
            BeforeAll {
                $acronymConfig = Join-Path $dataDirectory 'config.yml'
                if (Test-Path $acronymConfig) {
                    try {
                        $acronyms = Get-Content $acronymConfig | ConvertFrom-Yaml
                    } catch {
                        throw "There was an error parsing the acronym config.`n$_"
                    }
                }
                $Expected = (Get-Content $ExpectedFile -Raw)
                $output = ((Get-Content $InputFile -Raw) | Format-Acronym -Acronyms $acronyms)

            }
            It 'THEN the acronyms should be updated with a React Acronym tag' {
                $output | Should -BeLikeExactly $Expected
            }
        }
    }
}

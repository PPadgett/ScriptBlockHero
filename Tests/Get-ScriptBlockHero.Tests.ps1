BeforeAll {
    # Start of the Pester setup process with an initial verbose message to indicate the beginning of the setup.
    Write-Verbose "Starting Pester setup process with enhanced analysis for ADO pipeline compatibility." -Verbose

    # Extracting the filename of the script under test from the current Pester test script path.
    $filename = [System.IO.Path]::GetFileName($PSCommandPath).Replace('.Tests.ps1', '.ps1')
    Write-Verbose "Identified script filename for testing as: $filename" -Verbose

    # Calculating the directory path of the script under test based on the current test script's location.
    $directoryPath = Split-Path -Path (Split-Path -Path $PSCommandPath -Parent) -Parent
    Write-Verbose "Calculated directory path for the script under test as: $directoryPath" -Verbose

    # Constructing the full path to the script under test by combining its directory path with the filename.
    $filePath = Join-Path -Path $directoryPath -ChildPath $filename
    Write-Verbose "Constructed full path to the script under test as: $filePath" -Verbose

    try {
        # Checking if the script file exists at the constructed path.
        if (-not (Test-Path -Path $filePath)) {
            throw "Script file not found at the expected path: $filePath. Please verify the file path."
        }

        Write-Verbose "Script file located at the specified path. Proceeding with dot-sourcing and function analysis." -Verbose
        try {
            # Dot-sourcing the script file to load its functions into the current PowerShell session for testing.
            . $filePath
        }
        catch {
            throw "An error occurred while dot-sourcing the script file: $_. Please review the script and attempt again."
        }

        # Reading the script content for AST analysis to identify function definitions.
        Write-Verbose 'Analyzing the Abstract Syntax Tree (AST) to identify function definitions in the script.' -Verbose
        try {
            $scriptContent = Get-Content -Path $filePath -Raw
            $scriptBlockAst = [System.Management.Automation.Language.Parser]::ParseInput($scriptContent, [ref]$null, [ref]$null)
        }
        catch {
            throw "An error occurred while reading the script content for AST analysis: $_. Please review the script and attempt again."
        }

        # Using AST to find all function definitions in the dot-sourced script.
        Write-Verbose 'Identifying function definitions in the dot-sourced script using AST analysis.' -Verbose
        try {
            $functionDefinitions = $scriptBlockAst.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true)
        }
        catch {
            throw "An error occurred during AST analysis to identify function definitions: $_. Please review the script and attempt again."
        }

        # Conditional block to handle the presence or absence of function definitions.
        Write-Verbose 'Checking if any functions were identified within the dot-sourced script.' -Verbose
        if ($functionDefinitions.Count -gt 0) {
            Write-Verbose "AST analysis identified the following functions within the dot-sourced script:" -Verbose
            foreach ($function in $functionDefinitions) {
                Write-Verbose "Function name: $($function.Name)" -Verbose
            }
        } else {
            Write-Verbose "AST analysis did not identify any functions within the dot-sourced script." -Verbose
        }
    }
    catch {
        # Error handling block to catch and report errors during the setup process.
        Write-Error "An error occurred during script processing: $_. Please review the script and attempt again." -ErrorAction Stop
    }
}

Describe "Get-ScriptBlockHero Full Coverage Example Tests" {

    It "Should return an object of type PSCustomObject" {
        $hero = Get-ScriptBlockHero -Type Hero
        $hero | Should -BeOfType [PSCustomObject]
    }

    It "Should have a DateTimeStamp property that is a valid date" {
        $hero = Get-ScriptBlockHero -Type Hero
        $hero.DateTimeStamp | Should -Match '\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}'
    }

    It "Should return 'Cmdlet Crusader' with Power 'Command Mastery' for Hero type" {
        $hero = Get-ScriptBlockHero -Type Hero
        $hero.Details.Name | Should -BeExactly "Cmdlet Crusader"
        $hero.Details.Power | Should -BeExactly "Command Mastery"
    }

    It "Should return 'Pipeline Paladin' with Power 'Seamless Integration' for Champion type" {
        $hero = Get-ScriptBlockHero -Type Champion
        $hero.Details.Name | Should -BeExactly "Pipeline Paladin"
        $hero.Details.Power | Should -BeExactly "Seamless Integration"
    }

    It "Should have a Level that is an integer and within the expected range" {
        $hero = Get-ScriptBlockHero -Type Hero
        $hero.Details.Level | Should -BeOfType [int]
        $currentDay = (Get-Date).Day
        $hero.Details.Level | Should -BeGreaterOrEqual $currentDay
        $hero.Details.Level | Should -BeLessOrEqual ($currentDay + 99)
    }

    It "Should throw an error for unsupported types" {
        { Get-ScriptBlockHero -Type InvalidType } | Should -Throw
    }
}


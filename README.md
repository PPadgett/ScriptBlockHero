# PowerShell Scripting and Pester Testing Framework for ADO Pipeline Testing

## Introduction

This README document outlines a framework for PowerShell scripting and Pester testing designed to facilitate Azure DevOps (ADO) pipeline testing. The framework includes steps to create a repository, clone it, generate script and test files, and integrate with Pester for testing purposes. This document is structured to provide developers and DevOps engineers with a comprehensive understanding of how to apply this framework and the accompanying examples into their own code, especially focusing on the ADO pipeline testing.

## Framework Overview

The framework is divided into two main components:

1. **PowerShell Scripting**: This involves creating PowerShell scripts that are capable of being executed both manually and through automation tools such as Ansible. Scripts are designed with parameters and switch blocks to handle various execution methods and are wrapped for Pester testing.

2. **Pester Testing**: Pester is a PowerShell testing framework that allows for the behavior-driven development (BDD) of PowerShell scripts. In this framework, Pester is used to test the PowerShell scripts, ensuring they perform as expected before deployment through ADO pipelines.

## Step-by-Step Process

### Requirements

It's important to have the right set of tools and PowerShell modules at your disposal. 

Here's what you'll need:

- **Git**: This essential tool allows for version control, enabling you to track and manage changes to your codebase efficiently. It's fundamental for collaborative projects and ensures that everyone on the team can work together seamlessly.
- **PSScriptAnalyzer**: This powerful PowerShell module offers static code analysis, helping to improve your scripts by identifying potential issues and suggesting best practices. It's like having an extra set of eyes on your code to help ensure quality and reliability.
- **Pester**: As a key component for testing in PowerShell, Pester provides a framework for running unit tests. It's instrumental in adopting behavior-driven development (BDD), allowing you to write and run tests that verify your code behaves as expected before it goes into production.

### 1. Create the Repository

- Follow the repository naming standard within the target ADO project. Example: `https://dev.azure.com/HPINCDev/CloudOperations/_git/DevOpsGovernance_BestPractices`

### 2. Clone the Repository

- Clone the newly created repository to your local workspace for development.

    ```powershell
    git clone <https://example.com/your_repo>
    ```

### 3. Generate Pester Script and Test Files

- Within the repository folder, use the following PowerShell command to generate the script and test files:

    ```powershell
    New-Fixture -Name 'Get-ScriptBlockHero'; ni -ItemType Directory -Path '.\Tests' -Force; mi -Path ".\*.Tests.ps1" -Destination '.\Tests\'
    ```

### 4. Script Execution Considerations

- Determine if the script is intended to be executed from the command line by a person or an automation tool.

    When planning the execution of a PowerShell script, it's crucial to identify whether the script is intended for interactive use by an individual or for automation purposes by a tool. This distinction impacts the method of passing parameters and handling outputs. Below, we delve into common execution methods.

    #### Interactive Execution by a User

    **Direct Invocation**: Directly running a script from the PowerShell console by specifying its path and any necessary parameters.

    ```powershell
    .\MyScript.ps1 -Parameter1 'Value1' -Parameter2 'Value2'
    ```

    #### Automated Execution by a Tool

    **Scheduled Tasks**: Automating script execution at specific times or intervals using Windows Task Scheduler.

    ```xml
    <Exec>
        <Command>powershell.exe</Command>
        <Arguments>-File "C:\Path\To\MyScript.ps1" -Parameter 'Value'</Arguments>
    </Exec>
    ```

    #### Remote Execution

    Running scripts on remote machines with PowerShell remoting commands, such as `Invoke-Command`, for centralized management.

    ```powershell
    Invoke-Command -ComputerName Server01, Server02 -FilePath .\RemoteScript.ps1 -ArgumentList 'ParamValue'
    ```

    #### Execution via Ansible

    Ansible can automate the execution of PowerShell scripts on Windows hosts. This is accomplished by leveraging the `win_shell` or `win_command` modules for script execution. Ansible modules allow specifying the path to the PowerShell script and any arguments it requires. Here's a basic example of executing a PowerShell script via an Ansible playbook:

    ```yaml
    - name: Execute PowerShell script on Windows hosts
    hosts: windows
    tasks:
    - name: Run script with Ansible
        win_shell: C:\Path\To\MyScript.ps1 -Parameter1 'Value1' -Parameter2 'Value2'
        args:
        executable: powershell.exe
    ```

Each method of execution may necessitate particular considerations for parameter passing, output capturing, and error handling. Adequate understanding of these aspects ensures that scripts are both designed and executed effectively, tailored to their intended context.

### 5. Write Your Function

To ensure that your PowerShell script is both flexible and easily testable, start by developing your main function with a focus on modularity and reusability. This approach allows for dynamic customization based on the execution context—whether being executed directly by users or through automation tools like Azure DevOps (ADO) pipelines.

#### Example:

```powershell
function Get-ScriptBlockHero {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('Hero', 'Champion')]
        [string]$Type
    )

    Begin {
        Write-Verbose "Initiating Get-ScriptBlockHero"
    }

    Process {
        $dateTimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $text = "Script Block Hero"
        
        # Gets the current day of the month
        $currentDay = (Get-Date).Day
        
        # Generates a random number and adds the current day of the month to it
        $level = (Get-Random -Minimum 1 -Maximum 100) + $currentDay

        # Debug step for the Level
        Write-Debug "Generated Level: $level"

        switch ($Type) {
            'Hero' {
                $heroDetails = @{
                    Name = "Cmdlet Crusader"
                    Power = "Command Mastery"
                    Level = $level # Assigns the calculated level
                }
            }
            'Champion' {
                $heroDetails = @{
                    Name = "Pipeline Paladin"
                    Power = "Seamless Integration"
                    Level = $level # Assigns the calculated level
                }
            }
        }

        $result = [PSCustomObject]@{
            DateTimeStamp = $dateTimeStamp
            Text = $text
            HeroType = $Type
            Details = $heroDetails
        }

        Write-Output $result
    }

    End {
        Write-Verbose "Concluding Get-ScriptBlockHero"
    }
}
```

- #### Main Function Development

    Your main function, `Get-ScriptBlockHero` in this example, should be designed to accept parameters that dictate its behavior. By bringing these parameters up to the script level, you enhance the script's accessibility and flexibility. This practice is crucial for scripts intended for varied execution contexts.

    #### Example:

    ```powershell
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('Hero', 'Champion')]
        [string]$Type,
        [switch]$PesterTesting
    )

    function Get-ScriptBlockHero {
        [CmdletBinding()]
        Param(
            [Parameter(Mandatory = $true)]
            [ValidateSet('Hero', 'Champion')]
            [string]$Type
        )

        # Function logic goes here
    }
    ```

    This design pattern ensures that the script can dynamically adjust its execution based on the input parameters, facilitating more versatile scripting solutions.

### 6. Implement a Switch Block

Incorporate a switch block within your script to handle different execution methods based on passed parameters. This switch block is a critical component for scripts that need to adapt their behavior dynamically, offering a structured approach to control the script's execution flow.

- #### Switch Block Usage

    The switch block within the `Get-ScriptBlockHero` function demonstrates how different functionalities can be executed based on the `$Type` parameter. This mechanism is essential for creating scripts that are capable of handling various scenarios and inputs efficiently.

    ##### Example 01:

    ```powershell
    switch ($PSCmdlet.ParameterSetName) {
        '__AllParameterSets' {
            # This is the default behavior for Advanced Function when no specific parameter sets are defined
            Write-Verbose "Default parameter set in use."

            # Call the Get-ScriptBlockHero function with default parameters or logic
            Get-ScriptBlockHero -Type $Type
        }
    }
    ```

    Utilizing a switch block in this manner allows for clear and maintainable code, making it easier to extend and adapt the script to new requirements over time.

### 7. Prepare for Pester Tests

To prepare your PowerShell script for Pester testing, especially when integrating with Azure DevOps (ADO) pipelines, a specific conditional check is employed within the script. This check involves evaluating `($MyInvocation.MyCommand.Name -and $PSBoundParameters.Count -gt 0)`. This statement serves two primary functions crucial for the testing process:

1. **Determining Script Invocation Context**: `$MyInvocation.MyCommand.Name` is utilized to identify how the script is being invoked. If the script is run directly, this property contains the name of the script file. This check helps in distinguishing between direct execution of the script (e.g., running `.\YourScript.ps1` from the command line) and other forms of invocation, such as dot-sourcing or calling functions within the script from another script. In the context of Pester testing, this differentiation is vital. It allows the script to recognize when it's being executed as part of a test run, enabling it to behave appropriately (e.g., not executing certain initialization code when being tested).

2. **Parameter Presence Check**: `$PSBoundParameters.Count -gt 0` assesses whether any parameters were passed to the script during its invocation. `$PSBoundParameters` is a built-in variable that holds a dictionary of parameters that were bound to the script or function, including their values. Checking if its count is greater than 0 verifies that the script was invoked with parameters. This aspect is particularly relevant when scripts are designed to operate both with and without parameters, adjusting their behavior based on the invocation context. For Pester testing, ensuring that the script recognizes when it's being called with specific test parameters allows for more controlled and predictable test executions.

  - #### Conditional Execution for Testing

    By wrapping the script's execution logic with a check for the `($MyInvocation.MyCommand.Name -and $PSBoundParameters.Count -gt 0)` variables, you can prevent the script from running its primary functionality when being dot-sourced for testing. This approach is fundamental for enabling thorough testing without triggering the script's main execution logic.

    #### Example:

    ```powershell
    # Check if the script is being executed directly with parameters, if not is assumed to be dot-sourced for testing
    if ($MyInvocation.MyCommand.Name -and $PSBoundParameters.Count -gt 0) {
            switch ($PSCmdlet.ParameterSetName) {
            '__AllParameterSets' {
                # This is the default behavior for Advanced Function when no specific parameter sets are defined
                Write-Verbose "Default parameter set in use."

                # Call the Get-ScriptBlockHero function with default parameters or logic
                Get-ScriptBlockHero -Type $Type
            }
        }
    }
    ```
Combining these checks (`($MyInvocation.MyCommand.Name -and $PSBoundParameters.Count -gt 0)`) thus plays a pivotal role in making the script adaptable to different execution contexts, including direct execution and execution as part of automated tests in ADO pipelines. It ensures that the script can intelligently determine its invocation method and whether it was called with parameters, facilitating more accurate and efficient Pester testing by allowing for conditional execution paths based on these factors. This approach enhances the script's compatibility with CI/CD practices by making it more testable and adaptable to automation scenarios.

### 8. Pester Testing Setup

The provided Pester testing setup and the accompanying test cases are crucial for ensuring the quality and reliability of PowerShell scripts, particularly when integrating with Azure DevOps (ADO) pipelines. It doesn't automatically execute its primary logic, thereby allowing Pester tests to run against the script's functions without side effects.

#### BeforeAll Block


- **Global Variable Setting**: `$global:PesterTesting` is set to `$true` to flag the test environment. This allows scripts to conditionally execute code paths that are specifically intended for testing scenarios, ensuring that test executions do not affect production or other environments.
- **Script File Identification and Validation**: Extracts the filename of the script under test and verifies its existence in the expected directory. This step is critical to ensure that the tests are being executed against the correct script file, preventing false positives or negatives caused by testing the wrong script version.
- **Dot-Sourcing the Script File**: By dot-sourcing the script file, it loads its functions into the current PowerShell session, making them available for testing. This step is essential for dynamically analyzing and testing the script's functions without needing to hardcode function names or paths.
- **AST (Abstract Syntax Tree) Analysis**: Utilizes PowerShell's AST to introspectively analyze the script file for function definitions. This advanced technique allows for the identification of all functions within the script, supporting dynamic and comprehensive testing coverage. It ensures that new or modified functions are automatically included in the test scope.

    #### Example:
    ```powershell
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
    ```

### 9. Test Cases

The test cases are designed to validate various aspects of the script `Get-ScriptBlockHero`, offering a full coverage example:

  - **Object Type Verification**: Ensures that the function returns an object of type `PSCustomObject`, validating the structure of the returned value.
  - **Property Validation**: Checks for the existence of a `DateTimeStamp` property and validates its format, ensuring the function outputs data in the expected format.
  - **Content Accuracy**: Tests for specific values within the returned object, such as the name and power of a hero or champion. This step is crucial for verifying the logic and output accuracy of the script.
  - **Range and Type Checks**: Verifies that numeric values (e.g., `Level`) are within a specified range and of the correct type, ensuring the script's output adheres to expected constraints.
  - **Error Handling**: Tests the script's response to unsupported input types, confirming that it gracefully handles errors or invalid data..

    #### Example:
    ```powershell
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
    ```

## Applying the Framework

To apply this framework in your development environment, follow these steps:

1. **Adapt the Script Structure**: Customize the PowerShell script structure according to your project's requirements while following the guidelines for parameters and execution methods.

2. **Customize Pester Tests**: Based on the functionalities of your PowerShell script, write corresponding Pester test cases ensuring full coverage of all script features.

3. **Integration with ADO Pipelines**: Leverage this framework to integrate your scripts and tests within ADO pipelines for automated testing and deployment. Ensure your pipeline is configured to execute Pester tests and report results as part of the CI/CD process.

4. **Continuous Improvement**: Iteratively refine both the PowerShell scripts and Pester tests based on the outcomes of pipeline executions and feedback loops.

## Conclusion

This framework provides a structured approach to PowerShell scripting and Pester testing, specifically tailored for ADO pipeline testing. By adhering to this framework, developers can ensure their scripts are robust, tested, and ready for integration within ADO pipelines, thereby enhancing the reliability and efficiency of the deployment process.

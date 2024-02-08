<#
.SYNOPSIS
This script provides a framework for executing specific functionalities based on the passed parameters. It is designed with a focus on flexibility and integration with automated testing, particularly within Azure DevOps pipelines.

.DESCRIPTION
The script is designed with a specific execution flow in mind, tailored for scenarios where it's integrated into automated processes, such as Azure DevOps (ADO) pipelines. Unlike standard functions or modules that are often meant for direct invocation or import, this script is structured to facilitate conditional execution and testing.

Key features include:
- Script-level parameters are defined to customize execution paths dynamically.
- A switch mechanism is employed to determine the execution flow based on the parameter set passed to the script, allowing for flexible control over its behavior.
- Integration with Pester testing is explicitly considered. The script includes a mechanism ($PesterTesting variable) to prevent automatic execution when sourced, making it suitable for dot sourcing in testing contexts. This feature is particularly useful in ADO pipelines where Pester tests are automated, ensuring that the script's functions are available for testing without initiating the script's primary execution logic.

The design choices made in this script are intentional to accommodate these scenarios, ensuring that it seamlessly fits into CI/CD workflows and supports effective testing practices.

.PARAMETER PesterTesting
A switch parameter that, when set, prevents the script from executing its main functionality directly. This is particularly useful during automated testing, such as within an ADO pipeline, where the script's functions need to be loaded without being executed (dot-sourced).

.EXAMPLE
# To execute the script normally (outside of testing scenarios):
.\Path\To\Script.ps1 -Parameter 'Value'

.EXAMPLE
# To prepare the script for Pester testing in an ADO pipeline:
$PesterTesting = $true
. .\Path\To\Script.ps1

This second example demonstrates how to dot source the script while preventing its automatic execution, making its functions available for testing without triggering the primary workflow.

.NOTES
Version:        1.0
Author:         Preston Padgett
- It's crucial to set the $PesterTesting variable to $true before dot sourcing the script in a testing context to ensure the script does not execute its main logic.
- The script's behavior can be customized through script-level parameters, which should be passed accordingly based on the desired execution flow.
#>
# Check if the script is being dot-sourced for Pester testing
[CmdletBinding()]
Param(
    [ValidateSet('Hero', 'Champion')]
    [string]$Type
)
function Get-ScriptBlockHero {
    <#
    .SYNOPSIS
    Retrieves a hero or champion with specific attributes based on the provided type.

    .DESCRIPTION
    The Get-ScriptBlockHero function generates a hero or champion object with details such as name, power, and level based on the specified type. This function is designed to demonstrate dynamic object creation and the use of switch statements in PowerShell scripting. It provides an example of how to construct and output custom PowerShell objects.

    .PARAMETER Type
    Specifies the type of script block hero to retrieve. The valid options are 'Hero' and 'Champion'. This parameter is mandatory.

    .EXAMPLE
    Get-ScriptBlockHero -Type 'Hero'

    This command generates a hero object with predefined attributes including a name, power, and a dynamically generated level based on the current day.

    .EXAMPLE
    Get-ScriptBlockHero -Type 'Champion'

    Generates a champion object with predefined attributes, showcasing how the function adapts its output based on the input parameter.

    .INPUTS
    None. You cannot pipe objects to Get-ScriptBlockHero.

    .OUTPUTS
    PSCustomObject. The function returns a custom PowerShell object with the properties DateTimeStamp, Text, HeroType, and Details, which include Name, Power, and Level.

    .NOTES
    Version:        1.0
    Author:         Preston Padgett
    Purpose/Change: Initial function creation to demonstrate dynamic object creation and custom object output in PowerShell.

    .LINK
    https://HPINCDev@dev.azure.com/HPINCDev/InfraTech%20Automation%20Hub/_git/PowerShell-HeroesCmdlet-Example
    #>
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

# Check if the script is being executed directly with parameters, if not is assumed to be dot-sourced for testing
if ($MyInvocation.MyCommand.Name -and $PSBoundParameters.Count -gt 0) {
    Write-Verbose "Executing function based on parameter set..."
    # Execute the function based on the parameter set used passed to the script.
    switch ($PSCmdlet.ParameterSetName) {
        '__AllParameterSets' {
            # This is the default behavior for Advanced Function when no specific parameter sets are defined

            # Call the Get-ScriptBlockHero function with script levle parameters.
            Get-ScriptBlockHero -Type $Type
        }
    }
}

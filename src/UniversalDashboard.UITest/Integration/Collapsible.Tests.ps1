param([Switch]$Release)

Import-Module "$PSScriptRoot\Selenium\Selenium.psm1" -Force 

Import-Module "$PSScriptRoot\..\TestFramework.psm1" -Force
$ModulePath = Get-ModulePath -Release:$Release
$BrowserPort = Get-BrowserPort -Release:$Release

Import-Module $ModulePath -Force

Get-UDDashboard | Stop-UDDashboard

Describe "Collapsible" {
    Context "Simple Collapsible" {
        $dashboard = New-UDDashboard -Title "Test" -Content {
            New-UDCollapsible -Id "Collapsible" -Items {
                New-UDCollapsibleItem -Id "First" -Title "First" -Icon user -Content {
                    New-UDCard -Title "First"
                } -Active
                New-UDCollapsibleItem -Id "Second" -Title "Second" -Icon group -Content {
                    New-UDCard -Title "Second"
                }
                New-UDCollapsibleItem -Id "Third" -Title "Third" -Icon user -Content {
                    New-UDCard -Title "Third"
                }
            }

            New-UDCollapsible -Id "Collapsible2" -BackgroundColor "#4945FF" -FontColor "#A938FF" -Items {
                New-UDCollapsibleItem -Id "First-Endpoint" -Title "First" -Icon line_chart -Endpoint {
                    New-UDCard -Title "Endpoint"
                } -Active

                New-UDCollapsibleItem -Id "Collapsible2-Second" -Title "Second" -BackgroundColor "#4CFF6E" -FontColor "#98FF3F" -Icon line_chart -Content  {
                    New-UDCard -Title "Third"
                } 
            }

            New-UDCollapsible -Id "Collapsible with changing icon" -BackgroundColor "#4945FF" -FontColor "#A938FF" -Items {
                New-UDCollapsibleItem -Id "ChangeMyIcon" -Title "First" -Icon line_chart -Content {
                    New-UDCard -Title "Endpoint"

                    New-UDButton -Text "Change Icon" -Id "changeIcon" -OnClick {
                        Set-UDElement -Id "ChangeMyIcon-icon" -Attributes @{
                            className = 'fa fa-user'
                        }
                    }

                } -Active
            }
        }

        $Server = Start-UDDashboard -Port 10001 -Dashboard $dashboard 
        $Driver = Start-SeFirefox
        Enter-SeUrl -Driver $Driver -Url "http://localhost:$BrowserPort"

        It "should have title text" {
            $Element = Find-SeElement -Id "First-header" -Driver $Driver
            $Element.Text| should be "First"
        }

        It "should have body text" {
            $Element = Find-SeElement -Id "First-body" -Driver $Driver
            $Element.Text| should be "First"
        }

        It "should have active class" {
            Find-SeElement -Id "First-header" -Driver $Driver | Get-SeElementAttribute -Attribute "class" | Should be "collapsible-header active"
        }

        It "should have title text for endpoint" {
            Start-Sleep 1

            $Element = Find-SeElement -Id "First-Endpoint-header" -Driver $Driver
            $Element.Text | should be "First"
        }

        It "should have colors for collapsible" {
            Find-SeElement -Id "Collapsible2" -Driver $Driver | Get-SeElementAttribute -Attribute "style" | Should be "background-color: rgb(73, 69, 255); color: rgb(169, 56, 255);" 
        }

        It "should have colors for collapsible item" {
            Find-SeElement -Id "Collapsible2-Second-header" -Driver $Driver | Get-SeElementAttribute -Attribute "style" | Should be "background-color: rgb(255, 255, 255); color: rgb(0, 0, 0);" 
            Find-SeElement -Id "Collapsible2-Second" -Driver $Driver | Get-SeElementAttribute -Attribute "style" | Should be "background-color: rgb(31, 77, 255); color: rgb(255, 255, 255);" 
        }

        It "should change icon on click" {
            Find-SeElement -Id "ChangeMyIcon-icon" -Driver $Driver | Get-SeElementAttribute -Attribute "className" | Should be "fa fa-line-chart  " 
            Find-SeElement -Id "changeIcon" -Driver $Driver | Invoke-SeClick
            Find-SeElement -Id "ChangeMyIcon-icon" -Driver $Driver | Get-SeElementAttribute -Attribute "className" | Should be "fa fa-user" 
        }

        Stop-SeDriver $Driver
        Stop-UDDashboard -Server $Server 
    }
}
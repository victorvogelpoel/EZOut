function Out-FormatData
{
    <#
    .Synopsis
        Takes a series of format views and format actions and outputs a format data XML
    .Description
        A Detailed Description of what the command does
    .Example                
        # Create a quick view for any XML element.  
        # Piping it into Out-FormatData will make one or more format views into a full format XML file
        # Piping the output of that into Add-FormatData will create a temporary module to hold the formatting data
        # There's also a Remove-FormatData and 
        Write-FormatView -TypeName "System.Xml.XmlNode" -Wrap -Property "Xml" -VirtualProperty @{
            "Xml" = { 
                $strWrite = New-Object IO.StringWriter
                ([xml]$_.Outerxml).Save($strWrite)
                "$strWrite"
            }
        } | 
            Out-FormatData

    #>
    [OutputType([string])]
    param( 
    # The Format XML Document.  The XML document can be supplied directly, 
    # but it's easier to use Write-FormatView to create it
    [Parameter(Mandatory=$true,
        ValueFromPipeline=$true)]
    [ValidateScript({
        if ((-not $_.View) -and (-not $_.Control)) {
            throw "The root of a format XML most contain either a View or a Control element"
        }
        return $true
    })]
    [Xml]
    $FormatXml        
    )
    
    begin {
        $views = ""
        $controls = ""        
    }
    process {
        if ($FormatXml.View) {
            $views += "<View>$($FormatXml.View.InnerXml)</View>"
        } elseif ($FormatXml.Control) {
            $controls += "<Control>$($FormatXml.Control.InnerXml)</Control>" 
        }
    }
    
    end {
        $configuration = "<Configuration>"
        if ($Controls) {
            $Configuration+="<Controls>$Controls</Controls>"
        }
        if ($Views) {
            $Configuration+="<ViewDefinitions>$Views</ViewDefinitions>"
        }

        $configuration+= "</Configuration>"

        $xml = [xml]$Configuration
        $strWrite = New-Object IO.StringWriter
        $xml.Save($strWrite)
        return "$strWrite"
    }
}
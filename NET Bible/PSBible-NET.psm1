class BibleReferenceResult {
    [string] $Reference
    [string] $Book
    [string] $Chapter
    [string] $Verse
    [string] $Text
    [string] $URL
}

# Making this class assisted with when I wanted to combine verses into a passage
class BibleVerse {
    [string] $Reference
    [string] $Book
    [string] $Chapter
    [string] $Verse
    [string] $Text
}

# https://michaellwest.blogspot.com/2013/07/powershell-bible-scripture-function.html
function Get-BibleVerse {
    <#
        .SYNOPSIS
            Calls the bible.org api and returns the specified scriptures.
 
        .DESCRIPTION
            Calls the bible.org api to return the specified book-chapter-verse,
            random verse, or verse of the day.
 
        .PARAMETER Random
            Indicates the scripture returned should be random.
 
        .PARAMETER VerseOfTheDay
            Indicates the scripture returned should be the verse of the day.
 
        .PARAMETER Book
            Indicates the book to return, such as Matthew, Mark, Luke, or John.
 
        .PARAMETER Chapter
            Indicates the chapter of the book to fetch.
 
        .PARAMETER Verse
            Indicates the single verse of the chapter in that book.
 
        .EXAMPLE
            PS C:\> Get-BibleVerse -Random
 
        .EXAMPLE
            PS C:\> Get-BibleVerse -VerseOfTheDay -Type Json -Formatting Plain
 
        .EXAMPLE
            PS C:\> Get-BibleVerse -Book Ephesians -Chapter 5 -Verse 25 -Type Json
        
        .EXAMPLE
            PS C:\> # Get complete text as one string
            $CompleteVerse = ""
            Get-BibleVerse -Book "Matthew" -Chapter 22 -Verse 15 -EndVerse 22 -Type Json | ConvertFrom-Json | Foreach-Object { $CompleteVerse += $_.text }
            $CompleteVerse

        .NOTES
            -- Created by --
            Michael West
            2013-07-23
            http://michaellwest.blogspot.com

            -- Extended for a range of verses by --
            Dag Calafell
            2018-01-19
            https://dynamicsax365trix.blogspot.com
 
        .LINK
            http://labs.bible.org/api_web_service
    #>
    [CmdletBinding(DefaultParameterSetName="Default")]
    param(
        [Parameter(ParameterSetName="Random")]
        [switch]$Random,
 
        [Parameter(ParameterSetName="Votd")]
        [switch]$VerseOfTheDay,
 
        [Parameter(ParameterSetName="Default")]
        [ValidateNotNullOrEmpty()]
        [string]$Book="Genesis",
         
        [Parameter(ParameterSetName="Default")]
        [ValidateScript({$_ -gt 0})]
        [int]$Chapter = 1,
 
        [Parameter(ParameterSetName="Default")]
        [ValidateScript({$_ -gt -1})]
        [int]$Verse=1,

        [ValidateScript({$_ -gt -1})]
        [int]$EndVerse=1,
 
        [ValidateSet("Json","Xml","Text")]
        [string]$Type="Text",
 
        [ValidateSet("Full","Para","Plain")]
        [string]$Formatting="Plain"
    )
 
    # Base url
    $url = "http://labs.bible.org/api/?passage="
 
    # Build GET parameters
    if($PSCmdlet.ParameterSetName -eq "Votd") {
        $url += "votd"
    } elseif ($PSCmdlet.ParameterSetName -eq "Random") {
        $url += "random"
    } else {
        #Searching for a specific passage
        $url += "$($Book)+$($Chapter)"
        if($Verse) {
            $url += ":$($Verse)"
        }
        if($EndVerse) {
            $url += "-$($EndVerse)"
        }
    }
    $url += "&type=$($Type)&formatting=$($Formatting)"
    $url = $url.ToLower()

    $result = Invoke-WebRequest -Uri $url
    if($result) {
        $result.Content
    }
}

function Get-BibleVerses {
    <#
        .SYNOPSIS
            Reads the Bible verse(s) and returns them in a set to be used any way you like.
 
        .DESCRIPTION
            Calls the bible.org api to return the specified scripture passages.  It can handle ranges of verses within the same chapter.
 
        .PARAMETER ScriptureReference
            Indicates the book to return, such as Matthew, Mark, Luke, or John.
 
        .EXAMPLE
            PS C:\> Get-BibleVerses "John 3:16" | Format-Table -AutoSize
 
        .EXAMPLE
            PS C:\> Get-BibleVerses "John 3:16" | Export-Csv -Path "Verses.csv" -NoTypeInformation
 
        .EXAMPLE
            PS C:\> Get-BibleVerses "Matthew 22:15-22
            Titus 3:1" | Select-Object Reference, Text | Format-Table -AutoSize

            Reference        Text                                                                                                                                                                                                                                            
            ---------        ----                                                                                                                                                                                                                                            
            Matthew 22:15-22 Then the Pharisees went out and planned together to entrap him with his own words.  They sent to him their disciples...
            Titus 3:1        Remind them to be subject to rulers and authorities, to be obedient, to be ready for every good work
	    
        .EXAMPLE
            PS C:\> $v = Read-Host "Verse to look up"
            Get-BibleVerses $v

        .EXAMPLE
            PS C:\> # Return the Bible verses in a long string by using SingleString
            Get-BibleVerses "Matthew 22:15-17
            Titus 3:1" -Formatting SingleString

            Matthew 22:15-22 - Then the Pharisees went out and planned together to entrap him with his own words.  They sent to him their disciples along with the Herodians, saying, “Teacher, we know that you are truthful, and teach the way of God in accordance with the truth. You do not court anyone’s favor because you show no partiality. Tell us then, what do you think? Is it right to pay taxes to Caesar or not?”

            Titus 3:1 - Remind them to be subject to rulers and authorities, to be obedient, to be ready for every good work.

        .EXAMPLE
            PS C:\> Get-BibleVerses (Import-Csv "MyBibleVerses.txt") | Format-Table

            Reference        Book      Chapter Verse Text                                                                                                                                                                                                                    
            ---------        ----      ------- ----- ----                                                                                                                                                                                                                    
            Matthew 22:15-22 Matthew   22            Then the Pharisees went out and planned together to entrap him with his own words.  They sent to him their d...
            1 Peter 2:13-17  1 Peter   2             Be subject to every human institution for the Lord’s sake, whether to a king as supreme  or to governors as ...
            Titus 3:1        Titus     3       1     Remind them to be subject to rulers and authorities, to be obedient, to be ready for every good work.

        .NOTES
            Dag Calafell
            2018-01-19
            https://dynamicsax365trix.blogspot.com
 
        .LINK
            http://labs.bible.org/api_web_service
            https://dynamicsax365trix.blogspot.com
    #>
    [CmdletBinding(DefaultParameterSetName="Default")]
    param(
        [Parameter(ParameterSetName="Default",
            ValueFromPipelineByPropertyName=$true,
            Mandatory=$true,
            Position=0)]
        [ValidateNotNullOrEmpty()]
        [string[]]$ScriptureReference="John 3:16",
 
        [ValidateSet("SingleString","Set")]
        [string]$Formatting="Set"
    )

    If ($ScriptureReference.Length -gt 1)
    {
        $text = ""
        ForEach ($line in $ScriptureReference)
        {
            $text += $line
        }
        
        $ScriptureReference = $text
    }

    # Read in a bunch of verses
    # Adapted from: http://www.regexlib.com/RETester.aspx?regexp_id=2288
    $regex = new-object System.Text.RegularExpressions.Regex("(?<Book>(?:(?:[123]|I{1,3})\s*)?(?:[A-Z][a-zA-Z]+|Song of Songs|Song of Solomon)).?\s*(?<Chapter>1?[0-9]?[0-9]):\s*(?<FromVerseNum>\d{1,3})(?:[,-]\s*(?<ToVerseNum>\d{1,3}))*", [System.Text.RegularExpressions.RegexOptions]::MultiLine)
    $regexMatches = $regex.Matches($ScriptureReference);

    $bibleVerses = @()

    foreach ($match in $regexMatches)
    {
        $groups = $match.Groups;
        $book         = $groups[1].Value
        $chapter      = $groups[2].Value
        $fromVerseNum = $groups[3].Value
        $toVerseNum   = $groups[4].Value

        if (-not $groups[4].Success)
        {
            $thisVerse = [BibleVerse]::new()
            $thisVerse.Reference = $groups[0].Value
            $thisVerse.Book      = $book
            $thisVerse.Chapter   = $chapter
            $thisVerse.Verse     = $fromVerseNum
            $thisVerse.Text      = ((Get-BibleVerse -Book $book -Chapter $chapter -Verse $fromVerseNum -Type Json | ConvertFrom-Json)[0] | Select-Object Text).Text
            
            $bibleVerses += $thisVerse
        }
        else
        {
            $CompleteVerse = ""
            Get-BibleVerse -Book $book -Chapter $chapter -Verse $fromVerseNum -EndVerse $toVerseNum -Type Json | ConvertFrom-Json | Foreach-Object { $CompleteVerse += $_.text }

            $thisVerse = [BibleVerse]::new()
            $thisVerse.Reference = $groups[0].Value
            $thisVerse.Book      = $book
            $thisVerse.Chapter   = $chapter
            $thisVerse.Text      = $CompleteVerse

            $bibleVerses += $thisVerse
        }
    }

    If ($Formatting -eq "Set") {
        $bibleVerses
    }
    Else {
        $bibleVerses | ForEach-Object {
            "{0} - {1}" -f $_.Reference, $_.Text
            ""
        }
    }
}

function Get-BibleReferences {
    <#
        .SYNOPSIS
            Finds scripture references within the provided text.
 
        .DESCRIPTION
            Uses regular expressions to find references to the Bible and returns them as a set.
 
        .PARAMETER Text
            The text to parse for scripture references.
 
        .EXAMPLE
            PS C:\> Get-BibleReferences "Titus 3:1  Really any text can be here -- 1 Timothy 2:1-2 -" | Format-Table -AutoSize

            Reference       Book      Chapter Verses From To
            ---------       ----      ------- ------ ---- --
            Titus 3:1       Titus     3       1      1      
            1 Timothy 2:1-2 1 Timothy 2       1-2    1    2 

        .NOTES
            Dag Calafell
            2018-01-20
            https://dynamicsax365trix.blogspot.com/
 
        .LINK
            https://dynamicsax365trix.blogspot.com/
    #>
    [CmdletBinding(DefaultParameterSetName="Default")]
    param(
        [Parameter(ParameterSetName="Default",
            ValueFromPipelineByPropertyName=$true,
            Mandatory=$true,
            Position=0)]
        [ValidateNotNullOrEmpty()]
        [string[]]$text
    )

    $regex = new-object System.Text.RegularExpressions.Regex("(?<Book>(?:(?:[123]|I{1,3})\s*)?(?:[A-Z][a-zA-Z]+|Song of Songs|Song of Solomon)).?\s*(?<Chapter>1?[0-9]?[0-9]):\s*(?<FromVerseNum>\d{1,3})(?:[,-]\s*(?<ToVerseNum>\d{1,3}))*", [System.Text.RegularExpressions.RegexOptions]::MultiLine)
    $regexMatches = $regex.Matches($text)

    foreach ($match in $regexMatches)
    {
        $groups = $match.Groups
        $book         = $groups[1].Value
        $chapter      = $groups[2].Value
        $fromVerseNum = $groups[3].Value
        $toVerseNum   = $groups[4].Value

        $object = New-Object –TypeName PSObject
        $object | Add-Member –MemberType NoteProperty –Name Reference –Value $groups[0].Value
        $object | Add-Member –MemberType NoteProperty –Name Book –Value $book
        $object | Add-Member –MemberType NoteProperty –Name Chapter –Value $chapter

        if ($groups[4].Success)
        {
            $object | Add-Member –MemberType NoteProperty –Name Verses –Value ("{0}-{1}" -f $fromVerseNum, $toVerseNum)
            $object | Add-Member –MemberType NoteProperty –Name From –Value $fromVerseNum
            $object | Add-Member –MemberType NoteProperty –Name To –Value $toVerseNum
        }
        else
        {
            $object | Add-Member –MemberType NoteProperty –Name Verses –Value $fromVerseNum
            $object | Add-Member –MemberType NoteProperty –Name From –Value $fromVerseNum
            $object | Add-Member –MemberType NoteProperty –Name To –Value ""
        }

        # Return the info
        $object
    }
}

function Get-InternetSearchUrl {
    <#
        .SYNOPSIS
            Gets the url for an internet search
 
        .DESCRIPTION
            Returns the url to search for some text on Google or Bing.
 
        .PARAMETER SearchFor
            The text to search for.
 
        .PARAMETER Use
            The search engine to use.  Supported  Bing or Google
 
        .EXAMPLE
            PS C:\> Get-InternetSearchUrl "pfSense" Bing

        .NOTES
            Dag Calafell
            2018-01-20
            https://dynamicsax365trix.blogspot.com/
 
        .LINK
            https://dynamicsax365trix.blogspot.com/
    #>
    [CmdletBinding()]
    Param(
	    [Parameter(Mandatory=$True,Position=0)]
	    [String]$SearchFor,
	
	    [Parameter(Mandatory=$True,Position=1)]
        [ValidateSet("Google","Bing")]
	    [String]$Use
    )

    $SearchFor = $SearchFor -Replace "\s+", "+"

    Switch ($Use) {
	    "Google" {
		    $Query = "https://www.google.com/search?q=$SearchFor"
	    }
	    "Bing" {
		    $Query = "http://www.bing.com/search?q=$SearchFor"
	    }
	    Default {
            $Query = "No Search Engine Specified"
        }
    }
	 
    $Query
}

function Get-BibleReferencesOnTopic {
    <#
        .SYNOPSIS
            Gets the url for an internet search
 
        .DESCRIPTION
            Looks at the first page of Google results, goes to each web page and searches for Bible verses.
 
        .PARAMETER Topic
            The topic to search for.
 
        .EXAMPLE
            PS C:\> Get-BibleReferencesOnTopic "Luther Law and Gospel" -Formatting SingleString -Verbose

        .EXAMPLE
            PS C:\> Get-BibleReferencesOnTopic "Luther Law and Gospel" | Format-Table

        .NOTES
            To see all of the urls which are queried, use the -Verbose option.
            Dag Calafell
            2018-01-20
            https://dynamicsax365trix.blogspot.com/
 
        .LINK
            https://dynamicsax365trix.blogspot.com/
    #>
    [CmdletBinding()]
    Param(
	    [Parameter(Mandatory=$True,Position=0)]
	    [String]$Topic,
 
        [ValidateSet("SingleString","Set")]
        [string]$Formatting="Set"
    )

    #$isVerbose = $PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent

    # Prevent "Could not create SSL/TLS secure channel" error
    [Net.ServicePointManager]::SecurityProtocol =  [System.Security.Authentication.SslProtocols] "tls, tls11, tls12"

    # Query Google
    $searchUrl = Get-InternetSearchUrl $Topic Google
    Write-Verbose ("Querying {0}" -f $searchUrl)
    $requestResult = Invoke-WebRequest -Uri $searchUrl -DisableKeepAlive -UseBasicParsing -ErrorAction SilentlyContinue

    if ($requestResult.StatusCode -eq 200)
    {
        # Had to add ` characters for the PowerShell parser
        $regex = new-object System.Text.RegularExpressions.Regex("<a href=`"/url\?q=([^`"]+)&amp;sa=U&amp;ved=", [System.Text.RegularExpressions.RegexOptions]::MultiLine)
        $regexMatches = $regex.Matches($requestResult.Content)

        $results = @()

        # Loop through the web sites found via Google
        foreach ($match in $regexMatches)
        {
            $url = $match.Groups[1].Value
        
            # $url   # for debugging
            # Get the contents of that web site
            $requestResult = Invoke-WebRequest -Uri $url -DisableKeepAlive -UseBasicParsing -ErrorAction SilentlyContinue
            if ($requestResult.StatusCode -eq 200)
            {
                $r = Get-BibleReferences $requestResult.Content

                Write-Verbose ("Found {0} Bible verses in web page at {1}" -f $r.Length, $url)

                $r | ForEach-Object {
                
                    <#
                    $thisVerse = [BibleReferenceResult]::new()
                    $thisVerse.Reference = $_.Reference
                    $thisVerse.Book      = $_.Book
                    $thisVerse.Chapter   = $_.Chapter
                    $thisVerse.Verse     = $_.Verses
                    #$thisVerse.Text      = ((Get-BibleVerse -Book $book -Chapter $chapter -Verse $fromVerseNum -Type Json | ConvertFrom-Json)[0] | Select-Object Text).Text
                    #>
                    
                    $results += $_
                }

            }
            #else { "Not Responding" }   # for debugging
        }

        # Sort and remove duplicates
        $results = $results | Select-Object Reference | Sort-Object Reference | Get-Unique -AsString
        
        # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
        # Add scripture text
        # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

        If ($Formatting -eq "Set") {
            $results = $results | % { Get-BibleVerses $_.Reference -Formatting Set }
        } else {
            $results = $results | % { Get-BibleVerses $_.Reference -Formatting SingleString }
        }

        # Return values
        $results
    }
}

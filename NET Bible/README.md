# PSBible-NET
> Dag Calafell, III

A collection of PowerShell commands returning Bible text from the [NET Bible](https://bible.org/).

## Commands

- Get-BibleReferencesOnTopic - Given some search terms, this command looks at the first page of Google results, goes to each web page and searches for Bible verses then returns them in a set.
- Get-BibleReferences - Parses a string to find references to the Bible.
- Get-BibleVerse - Calls the bible.org api and returns the specified scriptures.
- Get-BibleVerses - Reads the Bible verse(s) and returns them in a set.
- Get-InternetSearchUrl - Creates a URL for an internet search on Bing or Google

## Examples

### Random Bible Verse

```PowerShell
Get-BibleVerse -Random
```
> Psalms 119:55 I remember your name during the night, O Lord,and I will keep your law.

### Searching for Scripture References on a Topic
The following command will parse the top ten results on Google for Bible verses and return them in a table

```PowerShell
Get-BibleReferencesOnTopic "Luther Law and Gospel" | Format-Table
```

> Reference           Book          Chapter Verse Text
> ---------           ----          ------- ----- ----                                                                      
> 1 Cor. 4:4          1 Cor         4       4     For I am not aware of anything against myself, but I am not acquitted because of this. The one who judges me is the Lord.                                                                                        
> 1 Corinthians 1:21  1 Corinthians 1       21    For since in the wisdom of God the world by its wisdom did not know God, God was pleased to save those who believe by the foolishness of preaching.                                                              
> 1 Peter 5:12        1 Peter       5       12    Through Silvanus, whom I know to be a faithful brother, I have written to you briefly, in order to encourage you and testify that this is the true grace of God. Stand fast in it.                               
> 2 Cor. 3:6-9        2 Cor         3             who made us adequate to be servants of a new covenant not based on the letter but on the Spirit, for the letter kills, but the Spirit gives life.  But if the ministry that produced death – carved in letters...
> Deuteronomy 26:5-13 Deuteronomy   26            Then you must affirm before the Lord your God, “A wandering Aramean was my ancestor, and he went down to Egypt and lived there as a foreigner with a household few in number, but there he became a great, pow...
> ...

## Related
- [Bible.org](http://www.bible.org) - Makers of the NET Bible
- [Dynamics 365 Trix](https://dynamicsax365trix.blogspot.com) - Blog about Dynamics 365 for Finance and Operations, formerly Dynamics AX.

## Contribute

Contributions are always welcome!

## License

[![CC0](https://licensebuttons.net/p/zero/1.0/88x31.png)](https://creativecommons.org/publicdomain/zero/1.0/)

To the extent possible under law, [Dag Calafell](http://calafell.me/) has waived all copyright and related or neighboring rights to this work.
Class HtmlFragment {
    [String]$Value

    HtmlFragment (
        [String]$Value
    ) {
        $this.Value = $Value
    }

    [HtmlFragment]Update([switch]$UseCachedLbiOnly) {
        return $this
    }

    [String]Text([String]$Indent = '') {
        # It ignores $Indent. See derived classes.
        return $this.Value
    }

    [String]LastLineIndent([String]$PreviousIndent = '') {
        if ( $this.Value -match '(?<indent>\n\s*)(?:.*)$' ) {
            return $Matches['indent']
        }

        return $PreviousIndent
    }
}

Class LibItem : HtmlFragment {
    [String]$FileName
    [String]$Begin
    [String]$End

    Static [Hashtable] $Cache = @{} # See Reset-LbiCache

    LibItem (
        [String]$Value,
        [String]$FileName,
        [String]$Begin = "<!-- #BeginLibraryItem `"$FileName`" -->",
        [String]$End = "<!-- #EndLibraryItem -->"
    ) : base($Value) {
        $this.FileName = $FileName
        $this.Begin = $Begin
        $this.End = $End
    }

    [HtmlFragment]Update([switch]$UseCachedLbiOnly) {
        if ( $this.FileName -in $this::Cache.Keys ) {
            Write-Verbose "Read from the cache. Key='$This.FileName'"
            $this.Value = $this::Cache[$this.FileName]
        }
        elseif ( $UseCachedLbiOnly ) {
            Write-Warning "Lbi '$this.FileName' was not found in the cache and the UseCachedLbiOnly is switch on. Inner text is not changed."
        }
        else {
            try {
                $this.Value = Read-LibItem $this.FileName
            }
            catch {
                Write-Warning "Lbi '$this.FileName' was not readed. Inner text is not changed."
            }
        }

        return $this
    }

    [String]Text([String]$Indent = '') {
        $Text = ([HtmlFragment]$this).Text($Indent)

        if ( $Indent -and ($Indent -ne '\n') ) {
            $Text = $Text -replace '\n', $Indent
        }

        return -join ($this.Begin, $Text, $this.End)
    }

    [String]LastLineIndent([String]$PreviousIndent = '') {
        # A LibItem never changes the indent. See HtmlFragment
        return $PreviousIndent
    }
}

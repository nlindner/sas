# SAS Package for Sublime Text #

A fork of RPardee's SAS programming package (.tmlanguage and .YAML-tmlanguage), developed in Sublime Text 3. Focused on SAS's PROC SQL and MACRO language, because that's where I spend 90% of my time. 

If you have any syntax highlighting problems, please don't hesitate to submit an issue with sample code.

As of 2017-02-05, development will use sublime-syntax instead of YAML-tmlanguage/tmlanguage. 
  - Using `pop: true` along with a new "escaped" repository to recognize SAS syntax for masking unmatched quotation marks and parentheses [See SAS® 9.4 Macro Language - Summary of Macro Quoting Functions and the Characters That They Mask](http://support.sas.com/documentation/cdl/en/mcrolref/69726/HTML/default/viewer.htm#p0pwrvnlcooi3tn0z3g1755ebcng.htm)

## USAGE PATTERNS THAT DIFFER FROM ORIGINAL RPARDEE REPOSITORY ##
  - Unlike the SAS coding-style implicitly expected in RPardee's repository, my personal preference is to exclude spaces before semi-colons. It's very likely that my regex patterns fail to allow for an optional space before a semi-colon. Sorry about that!
  - At least in SAS EG, if a PROC SQL step is opened in a macro, then unless a QUIT is issued before the macro terminates, SAS' status will just show a "running" until you issue a STOP PROCESS. Heaven knows what SAS chooses to do in a scheduled process with a macro or or data step like that. Because of that, the scoping here requires that DATA step ends with RUN and PROC SQL (and other procs) end with QUIT. 
  - I've limited DATA step's begin-capture scope, I don't use data step or the specialized PROCs enough to have seen any problems resulting from this. 

### Other useful packages I use in conjunction with this ###
  - I disable Sublime Text's default SQL syntax and instead use customized/expanded SQL syntax highlighting [my fork of tosher's TSQLEasy](https://github.com/nlindner/TSQLEasy). That allows me to minimize SQL-syntax additions within this SAS syntax
  - The macro "do" block (if/else/else if...then do) is MUCH easier to work with after installing [FacelessUser's BracketHighlighter package](https://packagecontrol.io/packages/BracketHighlighter). My SAS-specific additions are in my [Sublime Setup](https://github.com/nlindner/Nicole_Miscellaneous) repo under bh_core.sublime-settings

## WishList ##
  - "metamacro": beginning match still does not capture across line breaks. 
      - `(?s:(?i:((%)(macro\b\s+)([A-Za-z0-9_]+\b)?(.+?)(;))))` SHOULD work 
      - Instead, Sublime throws "Error in regex: undefined group option in regex (?s:(?i:((%)(macro\b\s+)([A-Za-z0-9_]+\b)?(.+?)(;))))"
  - For all patterns included in "sas-stuff", Separate out these keywords between allowed in datastep vs. in opencode. Scope those separately, then do some push/pop to only do syntax highlighting for SAS functions if they are within %sysfunc().



#SAS Package for Sublime Text

A fork of RPardee's SAS programming package, developed in Sublime Text 3. Focused on SAS's PROC SQL and MACRO language, because that's where I spend 90% of my time. 
- At least in SAS EG, if a PROC SQL step is opened in a macro, then unless a QUIT is issued before the macro terminates, SAS' status will just show a "running" until you issue a STOP PROCESS. Heaven knows what SAS chooses to do in a scheduled process with a macro or or data step like that. Because of that, the scoping requires that DATA step ends with RUN and PROC SQL (and other procs) end with QUIT. 
- I've limited DATA step's begin-capture scope, I don't use data step or the specialized PROCs enough to have seen any problems resulting from this. 

Other useful packages I use in conjunction with this:
- The great [jbrooksuk's Improved​SQL syntax highlighting](https://packagecontrol.io/packages/ImprovedSQL), which means that I'm able to minimize SQL-syntax additions 
- The macro "do" block (if/else/else if...then do) is MUCH easier to work with after installing [FacelessUser's BracketHighlighter package](https://packagecontrol.io/packages/BracketHighlighter). I'll post my SAS-specific additions to bh_core.sublime-settings

If you have any syntax highlighting problems, please don't hesitate to submit an issue with sample code.


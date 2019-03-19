// v1.0.0.0
// *********************************************************************************
// *
// *   .htmlFile
// *      by nel (NELMVN)
// *
// *   A lightweight library that allows you to create, write, and design your own
// *   HTML file. It is more faster than .bat to .txt conversion and compatible in
// *   Internet Explorer, Google Chrome, Avast Secure Browser, Mozilla Firefox,
// *   etc.
// *
// *********************************************************************************
// *
// *    Functions
// *
// *        function HTML_new takes string directory, real fontSize returns integer
// *            -   Create a new .html file.
// *
// *        function HTML_print takes string str returns nothing
// *        function HTML_println takes string str returns nothing
// *
// *        function HTML_end takes nothing returns nothing
// *            -   Close the generated .html file.
// *
// *********************************************************************************
// *
// *    Issues:
// *
// *        - print() may handle up to 252 characters.
// *        - println() may handle up to 248 characters.
// *        - Use '<br>' instead of '\r\n' in print() and println().
// *
// *********************************************************************************
// *
// *    Note:
// *
// *        Put this on your map's custom script code.
// *
// *********************************************************************************

function HTML_new takes string directory, real fontSize returns nothing
    call PreloadGenClear()
    call PreloadGenStart()
    call Preload("<html><body class=\"x\"><style>.x { font-size: 0; }.y { font-size: " + R2S(fontSize) + "; }</style><div class=\"y\"><!--")
    set udg_HTML_Directory = directory
endfunction

function HTML_print takes string str returns nothing
    call Preload("-->" + str + "<!--")
endfunction

function HTML_println takes string str returns nothing
    call Preload("-->" + str + "<br><!--")
endfunction

function HTML_end takes nothing returns nothing
    call Preload("--></div></body></html><!--\r\n\r\n\r\nMade by github.com/NELMVN\r\n\r\n\r\n")
    call PreloadGenEnd(udg_HTML_Directory + ".html")
    set udg_HTML_Directory = null
endfunction

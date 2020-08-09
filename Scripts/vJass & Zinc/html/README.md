## Examples:

```vb
scope HelloWorld1 initializer main
    private function main takes nothing returns nothing
        call InitHTML()

            // CSS
            call InsertHTML("<style> #wc3 { color: red; } </style>")

            // HTML
            call InsertHTML("<div id='root'>")
                call InsertHTML("Hello, World!<br>")
                call InsertHTML("<span id='wc3'>Warcraft 3</span> is awesome.")
            call InsertHTML("</div>")

        call EndHTML("example//index1")
    endfunction
endscope
```

```vb
scope HelloWorld2 initializer main
    private function main takes nothing returns nothing
        call InitHTML()

            // CSS
            call InsertHTML("<style>/*")
                call InsertCSSJS("#wc3  { color: red; }")
                call InsertCSSJS("#wc3b { color: blue; }")
            call InsertHTML("*/</style>")

            // Javascript
            call InsertHTML("<script>/*")
                call InsertCSSJS("function buttonClicked() {")
                    call InsertCSSJS("console.log('Hello!');")
                    call InsertCSSJS("console.log('World'); ")
                call InsertCSSJS("}")
            call InsertHTML("*/</script>")

            // HTML
            call InsertHTML("<div id='root'>")
                call InsertHTML("Hello, World!<br>")
                call InsertHTML("<span id='wc3'>Warcraft 3</span> is <span id='wc3b'>awesome</span>.")

                // Add Button
                call InsertHTML("<br><button type='button'onclick='buttonClicked()'>Click Me!</button>")
            call InsertHTML("</div>")

        call EndHTML("example//index2")
    endfunction
endscope
```

## (Optional) .pld to .html

If you are looking for a tool for automatic conversion, click [this](https://github.com/NELMVN/.pld2.html)

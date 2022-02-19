# Properties for data types

The available data types are:

* text
* html
* image
* video
* code
* license

Each one of them can have different properties as shown in the following table

| **type**  | **prop 0**   | **prop 1** | **prop 2**     | **prop 3**   |
|-----------|--------------|------------|----------------|--------------|
| *text*    | true / false | text       |                |              |
| *html*    | true / false | html       |                |              |
| *image*   | true / false | image      | local / remote |              |
| *video*   | true / false | video      |                |              |
| *code*    | true / false | code       | C / Python ... | true / false |
| *license* | true / false | license    |                |              |

The properties respect the same structure until **prop 1** and become object specific from there. The first two properties are whether a specific block should be shown in the final template for a page (thus *true* or *false*) and the name of the type (*text*, *html*, *image*...)

The third property for images represents whether they should be stored locally in the repository or if they are a URL locator to a remote image. Code has two extra parameters; the first one is the name of the programming language (*C*, *C++*...), and the second one is whether the text field should be used or not as the name for the code. This last property becomes handy whey having multiple code listings in a page for them to have their own filenames.

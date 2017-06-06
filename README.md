# asciidoc-timer

An awk script to generate a timing report from a script producing asciidoc
output.

For this to work, the scripts needs to output as soon as possible, pausing
inbetween outputs to perform commands. This way, the duration of these pauses
can be measured to generate timing.

## Usage

Simply pipe the command output into awk. The `-Wi` flag makes awk process input
as soon as it is received, which is required for this to function.

```
script-generating-asciidoc-output | awk -Wi -f asciidoc-timer.awk
```

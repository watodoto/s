#!/bin/bash
# we need this because pipe bash is really shitty so we gotta execute it locally in order for it to even run right
# why?
# fuck if i know bro.

curl -fsSL "http://wato.qd.je/script/script.sh" -o /tmp/script.sh && bash /tmp/script.sh

#!/usr/bin/env bash
set -e

if [ ! -x "$HOME/flutter/bin/flutter" ]; then
  git clone --depth 1 --branch stable https://github.com/flutter/flutter.git "$HOME/flutter"
fi

"$HOME/flutter/bin/flutter" config --no-analytics
"$HOME/flutter/bin/flutter" pub get
"$HOME/flutter/bin/flutter" build web --release

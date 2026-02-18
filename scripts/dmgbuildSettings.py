# dmgbuild settings for Please.app
# Usage: dmgbuild -s scripts/dmgbuildSettings.py -D app=Please.app "Please" Please-1.0.0.dmg

import os

# -- Volume settings --
format = "UDBZ"
size = None  # auto-calculate
files = [os.environ.get("app", defines.get("app", "Please.app"))]
symlinks = {"Applications": "/Applications"}

# -- Window appearance --
background = "builtin-arrow"
show_status_bar = False
show_tab_view = False
show_toolbar = False
show_pathbar = False
show_sidebar = False

window_rect = ((200, 120), (640, 280))
default_view = "icon-view"

icon_size = 128
text_size = 14

# -- Icon positions --
icon_locations = {
    os.path.basename(files[0]): (140, 120),
    "Applications": (500, 120),
}

# -- Volume icon (use the app's icon) --
# dmgbuild will use the app's icon automatically

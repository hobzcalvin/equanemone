from __future__ import print_function
import json
import sys

if len(sys.argv) < 4:
    print("Usage: " + __file__ + " <width> <height> <depth> [<tentacle-spacing> <pixel-height>]")
    sys.exit(0)


if len(sys.argv) == 6:
    spacing = float(sys.argv[4])
    pixheight = float(sys.argv[5])
else:
    spacing = 0.5
    pixheight = 0.05

width = int(sys.argv[1])
height = int(sys.argv[2])
depth = int(sys.argv[3])

print("Layout: %dx%dx%d, space %f, height %f" % (width, height, depth, spacing, pixheight), file=sys.stderr)

xoff = width*spacing / 2 * -1
yoff = height*pixheight / 2 * -1
zoff = depth*spacing / 2 * -1

pixels = []

for i in range(width):
    for k in range(depth):
        for j in range(height):
            pixels.append({
                #"point": [i*spacing, j*pixheight, k*spacing],
                "line": [
                    [ i*spacing+xoff, j*pixheight+yoff, (depth-k-1)*spacing+zoff],
                    [ i*spacing+xoff, (j+1)*pixheight+yoff, (depth-k-1)*spacing+zoff],
                ]
            })

print(json.dumps(pixels))

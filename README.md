ABOUT
=====

Equanemone is a three-dimensional LED display. This is a Processing project to control it. It uses PixelPusher to drive the LEDs.

SETUP
=====

- Install Processing 2.2.1, NOT 3.x, from processing.org
- Clone this repository in your Processing Sketchbook folder, e.g. `~/Documents/Processing/` on OSX
- Sketch > Import Library > Add Library
  - install PixelPusher by Jas Strong and Matt Stone
  - install The MidiBus by Severin Smith
  - install Leap Motion for Processing by Darius Morawiec (NOT LeapMotion by Michael Heuer)
- Download and install the toxiclibs collection from toxiclibs.org: https://bitbucket.org/postspectacular/toxiclibs/downloads/toxiclibs-complete-0020.zip
Extract all folders into your Processing libraries folder, which is inside the sketchbook folder.
- Open the equanemone sketch, hit "Run", and you should see the 3D preview appear and start showing stuff!

WRITING PLUGINS
===============
Each plugin is a subclass of the `EquanPlugin` class and lives in its own file. Click the down-arrow button to the right of the file tab manager and choose New Tab to add a new file to the project. The file should have the same name of your plugin's class.
The list of plugins currently used are defined by the `Class[] plugins = { ... }` declaration in the main `equanemone` file. Add your class name there, probably at the top of the list, to add it to the rotation.

`EquanPlugin` is an abstract class that sets up certain things every plugin needs. Your plugin class should all the `EquanPlugin` constructor and implement at least the `draw()` method. `draw()` is called when it's time for your plugin to draw another frame. You should draw on the canvas `PGraphics` object, named `c`. `c` is `w` pixels wide and `h*d` pixels tall, where `w`, `h`, and `d` are the width, height, and depth currently configured for the display.

Developer "Diary" of the Project
================================

May 14 2013
-----------

(This project was started about a month ago, but I'm just now starting to write a log of what I'm working on).

Yesterday I finally got the graph plotting properly. Before I had points plotting but the scale had just been hardcoded in for testing and was also inaccurate. So now I'm using a proper scale and translation so the graph appears where it should be.

Today I need to create an "Expression" class which will manage some things like this internally. It will handle the evaluation of the expression over a given range, it'll supply all the needed points. It will also handle things like expression "alternatives" and "sweep" values, as the expression is being interacted with, for example. This is in the view right now for prototyping but it ought to be in its own class.


May 17 2013
-----------

Last time I created an Expression class to better model what I'm trying to do. It's incomplete but now it's the proper place for the expression-related code.

Today I will let it communicate with the plot view better so that when it generates points to plot, they will actually fill the screen, not just a small arbitrary region of it.


May 21 2013
-----------

Wasted most of two days trying to figure out some stupid bugs:

1. The value of the expression being set was supposed to be a copy property, but since I had overridden the setter, I wasn't doing the copy myself. ruh-roh.
2. The expression parser appears to have a nasty bug where it keeps some state around even if you create a second instance of it. So if your expression fails to parse in a certain way, then the next time around the parser is in a bad state and can't parse. I'm guessing this has to do with it throwing an exception, which breaks the normal flow and skips any cleanup. Really, cleanup shouldn't be needed, but this is a shitty parser. Will look elsewhere for a better one, probably.

At least now though the plot view works and can properly resize and everything.

Next:

1. Show alternative plots while scrubbing. So the original plot should always be visible, but it should also show the plot of whatever the scrubbed expression looks like during a scrub.

2. Annotate the plot with the name of the functions being plotted during a scrub.

3. Annotate the plot with the values of the expression as you mouse over the graph ("when x = 5, y = 2x+3 -> 13")


May 23 2013
-----------

Today I got drag start/end messages sending for the text view and also started work on a "compare" view for the plot so that two functions can be compared during a drag.


July 2 2013
-----------

After an unfortunately long hiatus, I'm back working on this project, trying to get it wrapped up. June was a busy month.

Tonight I finished up with comparing labels. Next, I'd like to look at doing smoother number scrubbing, maybe with decimal precision (just single digit)?
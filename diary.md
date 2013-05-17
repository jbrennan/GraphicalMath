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
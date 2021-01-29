# Task
The doc page: https://package.elm-lang.org/packages/elm/core/latest/Task

Taks and commands look very similar. Some people like me like to get mixed up, like in [this forum](https://discourse.elm-lang.org/t/elm-design-question-task-vs-cmd-msg/3890)  
Here are some info:
- It is only when it is passed to `Task.perform` or `Task.attempt` as an argument that it is converted to Cmd and thus be executed by Elm runtime.

## Task.perform & Task.attempt
The task is basically divided by these 2 base methods.  
- `Task.perform` is to run a task where you are sure it will succeed. Usually used for time related stuff.
- `Task.attempt` is a task to run that will have some errors returning

## Time zone example
The current timezone is local to the user's browser. We can get it when the program runs locally.  
So the obvious way to do is to have a `timezone` data store in the model. When you init the program, you run a command to fetch the current timezone. Store it, and the view will use the current timezone to print out the timestamp.

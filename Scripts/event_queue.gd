class_name EventQueue

var initial
var befores
var afters

# queue checks for "before" reactions to the next event to resolve (ie the front of the queue) #
# if a before reaction is found, it enters at the front of the queue, and reactions for it are then checked #
# The queue remembers where in the reactions it's checking it found a before, and once it's resolved, continues checking #
# Repeat as necessary. Resolve a Move when all possible Reactions are checked #
# When a move resolves, "After" reactions are checked for and added to the end of the queue #
# Repeat as necessary until the queue is empty #


!start.

+!start
	<-
	.wait(2000);
	get_info_as_percept;
	!add_second_source;
	clear_my_percepts;
	!give_output.

+!add_second_source
	<-
	+info[source(second_source)].

+!give_output :
	info[source(second_source)]
	<-
	.print("I have retained belief from a second source when my percepts were cleared.");
	.print("Sam is very sorry for doubting Jason, and promises never to do it again.").

+!give_output :
	not info[source(second_source)]
	<-
	.print("I have lost belief from a second source when my percepts were cleared.");
	.print("Jason sucks.").
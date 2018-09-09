{ include("common-cartago.asl") }

!org::g1[scheme(banana)].
!org::g2.

+!org::g1[scheme(Scheme)]
<-
	!action::commit(Scheme);
	!org::g1[scheme(Scheme)];
	.
+!org::g2
<-
	.wait(1000);
	!action::delete(action,commit(_));
	!action::commit(maca);
	.

+!action::commit(Action)
	: count(B)
<-
	.print("Doing ",Action," at ",B);
	!!action::enviar;
	.wait({+count(C)});
	-action::sent;
	.print("Success ",C);
	.

@envia[atomic]
+!action::enviar
<-  .wait(800);
	+action::sent;
	inc;
	.
+!action::update_percepts
	: action::sent
<-
	.print("An action has been sent to the Server, I have to wait for the perceptions to be updated");
	.wait({-action::sent});
	.
@forgetParticularGoal[atomic]
+!action::delete(Module,Goal)
	: not action::sent
<-  if (.desire(Module::Goal) | .intend(Module::Goal)){
		.print("Yes I do ",Module," ",Goal);
	} else{
		.print("I dont have desire ",Module,"::",Goal);
//		.wait(para);
	}
	.drop_desire(Module::Goal);
	.drop_intention(Module::Goal);
	.
+!action::delete(Module,Goal)
<-
	!action::update_percepts;
	!action::delete(Module,Goal);
	.

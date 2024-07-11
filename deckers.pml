/* from https://spinroot.com/spin/Man/Manual.html */

#define true	1
#define false	0
#define Aturn	false
#define Bturn	true

bool x, y, t;

proctype A()
{	x = true;
	t = Bturn;
	(y == false || t == Aturn);
	/* critical section */
	x = false
}

proctype B()
{	y = true;
	t = Aturn;
	(x == false || t == Bturn);
	/* critical section */
	y = false
}

init
{	run A(); run B()
}
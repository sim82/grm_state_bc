states door {
closed:
    state DEMO, false, 0, CheckOpenDoor , None, closed
opened: 
    state DEMO, false, 300, CheckCloseDoor , None, blocked
close:
    state DEMO, false, 64, DecOpen, None, closed
open:
    state DEMO, false, 64, IncOpen, None, opened
blocked: 
    state DEMO, false, 0, CheckDoorBlocked, None, blocked
}

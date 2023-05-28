states door {
	state DEMO, false, 0, CheckOpenDoor , None, closed } 


function bla {
    1u8 2i32 trap
    not if
        2u8 3i32 trap
    then
    3u8 4i32 trap
}

function WeaponAttackCheckIdle {
    1u8 trap 
    not if
        @attack gostate
    then
    0u8 trap
    not if
        @lower gostate
    then
}

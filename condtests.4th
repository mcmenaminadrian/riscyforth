: test2 if ." 1 " if ." 2 " else ." 2F " then ." 2D " else ." 1F " then ." 1D " cr ;
: iftest0 if ." Passed " else ." Failed " if ." In failure " then ." Out of failure" then ." all done" cr ;
: iftest1 dup if ." Passed first test.." 100 > if ." Passed second test..." else ." Failed second test..." then ." Second test complete" then ." All tests complete..." cr ;

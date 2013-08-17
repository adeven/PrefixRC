use Test::More;

BEGIN {
    use_ok('PrefixRC') || print "Bail out!";
    use_ok('PrefixRC::Start') || print "Bail out!";
    use_ok('PrefixRC::Stop') || print "Bail out!";
    use_ok('PrefixRC::Status') || print "Bail out!";
}

done_testing;

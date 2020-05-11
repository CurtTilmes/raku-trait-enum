use Test;
use NativeCall;

use Trait::Enum;

enum FooType <A B C>;

class Foo is repr('CStruct')
{
    has int32 $.enum-foo-type is enum(FooType);
    has int32 $.enum-foo-writeable is rw is enum(FooType);
}

my $foo = Foo.new(enum-foo-type => 2, enum-foo-writeable => 1);

is $foo.foo-type, C, 'Returns enumerated type';
is +$foo.foo-type, 2, 'Numifies';

is $foo.foo-writeable, B, 'Writeable enumerated type';
is +$foo.foo-writeable, 1, 'Writable numifies';

$foo.foo-writeable(A);
is $foo.foo-writeable, A, 'Write enumeration';

$foo.foo-writeable(1);
is $foo.foo-writeable, B, 'Write Int';

$foo.foo-writeable('C');
is $foo.foo-writeable, C, 'Write Str';

$foo.foo-writeable(17);
nok $foo.foo-writeable, 'Undefined enumeration';

throws-like { $foo.foo-writeable('bad') }, X::AdHoc, 'Bad value';

done-testing;

role Trait::Enum[::Enum]
{
    method compose(Mu $package)
    {
        my $attr = self;
        die "Trait::Enum attributes must start with 'enum-'"
            unless $attr.name.starts-with('$!enum-');

        my $method = $attr.name.substr(7);  # Get rid of '$!enum-'

        $package.^add_multi_method($method, method ()
            { Enum(self."enum-$method"()) });

        if $attr.rw
        {
            $package.^add_multi_method($method, method (Int:D $i)
            {
                self."enum-$method"() = $i
            });
            $package.^add_multi_method($method, method (Enum:D $enum)
            {
                self."enum-$method"() = +$enum
            });
            $package.^add_multi_method($method, method (Str:D $str)
            {
                self."enum-$method"() = Enum::{$str}
            });
        }

        callsame;
    }
}

multi sub trait_mod:<is>(Attribute:D $attr, :$enum!) is export
{
    $attr does Trait::Enum[$enum]
}

=begin pod

=head1 NAME

Trait::Enum - Raku 'is enum' trait for enumerated types in CStruct classes

=head1 SYNOPSIS

  use Trait::Enum;

  enum FooType <A B C>;

  class Foo is repr('CStruct') {
      has int32 $.enum-foo-type is enum(FooType);
      has int32 $.enum-foo-writeable is rw is enum(FooType);
  }

  my $foo = Foo.new(enum-foo-type => 2, enum-foo-writeable => 1);

  say $foo.foo-type;             # C        -- Returns enumeration value
  say ~$foo.foo-type;            # 'C'      -- which stringifies
  say +$foo.foo-type;            # 2        -- and numifies

  say $foo.foo-writeable;        # B
  say +$foo.foo-writeable;       # 1

  $foo.foo-writeable(A);         # Can write a enumeration value
  $foo.foo-writeable(1);         # Or an Int
  $foo.foo-writeable('C');       # Or a Str

  $foo.foo-writeable(17);        # Ok to write a bad integer
  say $foo.foo-writeable;        # FooType, undefined enumeration

  $foo.foo-writeable('bad');     # Bad string throws exception

=head1 DESCRIPTION

This is a temporary, experimental trait mainly because Raku Native
C<CStruct> classes don't currently allow enumerated types in them.
Once they do, this module will be retired.  In the mean time, it makes
it very easy to map enumerations into CStruct structures making them
more friendly to interact with from Raku.

The trait can only be added on attributes named with the prefix
'enum-'.  It adds an additional accessor method without that prefix.
(You can still use the 'enum-' accessor methods with the original
type.)  The new accessor method returns the specified enum.

Naturally this trait must be used only with integer fields (int32,
int16, etc.)

If the attribute is also 'rw', three additional multi methods for
writing to the attribute either an Int, a Str, or an actual enumerated
value.

=head1 LICENSE

This work is subject to the Artistic License 2.0.

=end pod

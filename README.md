# TypedArray

This gem provides new type `TypedArray` which is direct successor of ruby `Array` class. 
`TypedArray` requires to specify a type of its elements and allows to add only elements of this type.  

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'typed_array'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install typed_array

## Usage

### Creation

`TypedArray` has a read-only attribute `:item_class` which specifies the class of its elements.
Any attempt to add elements of different class will cause `ArgumentError` exception with corresponding message.
 
`TypedArray` instance can be created in the same way as ordinary `Array`. 
If it is created from the list of elements than the class of first non-nil element
is considered as `:item_class` and all other elements should be either of the same class or `nil`.

```ruby
ta = TypedArray[nil, 1, 2, 3]   # => [nil, 1, 2, 3]
ta.item_class                   # => Fixnum
ta << 5                         # => [nil, 1, 2, 3, 5]
ta << :a                        # ArgumentError: assigned item(s) should be of the type Fixnum
ta << nil                       # => [nil, 1, 2, 3, 5, nil]

ta = TypedArray[1, :a, 'b']     # ArgumentError: all arguments should be of the same type

ta = TypedArray[nil, nil]       # ArgumentError: [] constructor requires at least one non-nil element
```

If it is created without elements than the first argument of constructor call should be the class of its future elements. 

```ruby
ta = TypedArray.new(Fixnum)     # []
ta.item_class                   # => Fixnum
ta << nil                       # => [nil]
ta << 1                         # => [nil, 1] 
ta << :a                        # ArgumentError: assigned item(s) should be of the type Fixnum
```

### Comparison

Two `TypedArray`s are considered as equal if and only if both of them have the same `:item_class` and elements.
`TypedArray` is considered as equal (in terms of :== operator) to an ordinary `Array` if they have the same elements.
`TypedArray` is always considered as non-equal (in terms of :eql? operator) to an ordinary `Array`.

```ruby
TypedArray[1, 2, 3] == TypedArray[1, 2, 3]        # => true
TypedArray[1, 2, 3] == TypedArray[1, 2, 4]        # => false
TypedArray.new(Fixnum) == TypedArray.new(Fixnum)  # => true 
TypedArray.new(Fixnum) == TypedArray.new(Symbol)  # => false
TypedArray[1, 2, 3] == [1, 2, 3]                  # => true
TypedArray[1, 2, 3] == [1, 2, 4]                  # => false
TypedArray.new(Fixnum) == []                      # => true 
TypedArray[1, 2, 3].eql? TypedArray[1, 2, 3]      # => true
TypedArray[1, 2, 3].eql? [1, 2, 3]                # => false
```

### Inherited Array behaviour

All `Array` methods that are supposed to return an array/slice of elements of original array will returns `TypedArray` in case of `TypedArray`.
```ruby
TypedArray[1, 2, 3][1..2]                               # => [2, 3]
TypedArray[1, 2, 3][1..2].class                         # => TypedArray
TypedArray[1, 2, 3][1..2].item_class                    # => Fixnum
```

Any operations between `TypedArray`s with the same `:item_class` will return `TypedArray`. 
Any operations between `TypedArray`s with different `:item_class`es will return `Array`. 
Any operations between `TypedArray` and `Array` will return `Array`. 

```ruby
TypedArray[1, 2, 3]  | TypedArray[2, 4]                 # => [1, 2, 3, 4]
(TypedArray[1, 2, 3] | TypedArray[2, 4]).class          # => TypedArray
(TypedArray[1, 2, 3] | TypedArray[2, 4]).item_class     # => Fixnum

TypedArray[1, 2, 3]  | TypedArray[:a, :b]               # => [1, 2, 3, :a, :b]
(TypedArray[1, 2, 3] | TypedArray[:a, :b]).class        # => Array
(TypedArray[1, 2, 3] | TypedArray[:a, :b]).item_class   # NoMethodError: undefined method `item_class' for [1, 2, 3, :a, :b]:Array

TypedArray[1, 2, 3]  | [2, 4]                           # => [1, 2, 3, 4]
(TypedArray[1, 2, 3] | [2, 4]).class                    # => Array
(TypedArray[1, 2, 3] | [2, 4]).item_class               # NoMethodError: undefined method `item_class' for [1, 2, 3, :a, :b]:Array

TypedArray[1, 2, 3]  | [:a, :b]                         # => [1, 2, 3, :a, :b]
(TypedArray[1, 2, 3] | [:a, :b]).class                  # => Array
(TypedArray[1, 2, 3] | [:a, :b]).item_class             # NoMethodError: undefined method `item_class' for [1, 2, 3, :a, :b]:Array
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/akoltun/typed_array.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

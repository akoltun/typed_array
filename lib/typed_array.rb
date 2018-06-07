require "typed_array/version"

class TypedArray < Array
  attr_reader :item_class

  def self.[](*args)
    klasses = args.compact.map(&:class).uniq
    raise ArgumentError, '[] constructor requires at least one non-nil element' if klasses.empty?
    raise ArgumentError, 'all arguments should be of the same type' if klasses.size > 1
    self.new(klasses.first).push(*args)
  end

  def initialize(item_class, *args)
    @item_class = item_class
    validate_assigned_items(*args) if args.size > 0
    super(*args)
  end

  def ==(item)
    (!item.is_a?(TypedArray) || item_class == item.item_class) && super
  end

  def eql?(item)
    item.is_a?(TypedArray) && item_class == item.item_class && super
  end

  def [](*args)
    if args.size == 2 || (args.size == 1 && args.first.is_a?(Range))
      self.class.new(item_class).push(*super)
    else
      super
    end
  end

  def []=(*args)
    if (args.size == 3 || (args.size == 2 && args.first.is_a?(Range))) && args.last.is_a?(Array)
      validate_assigned_items(args.last)
    else
      validate_assigned_items([args.last])
    end

    super
  end

  def concat(items)
    validate_assigned_items(items)
    super
  end

  def <<(item)
    validate_assigned_items([item])
    super
  end

  def insert(index, *items)
    validate_assigned_items(items)
    super
  end

  def push(*items)
    validate_assigned_items(items)
    super
  end

  def unshift(*items)
    validate_assigned_items(items)
    super
  end

  def pop(*args)
    if args.size > 0
      TypedArray.new(item_class).concat(super)
    else
      super
    end
  end

  def shift(*args)
    if args.size > 0
      TypedArray.new(item_class).concat(super)
    else
      super
    end
  end

  def reverse
    TypedArray.new(item_class).concat(super)
  end

  def rotate(count=1)
    TypedArray.new(item_class).concat(super)
  end

  def sort(*args)
    TypedArray.new(item_class).concat(super)
  end

  def sort_by(&block)
    if block_given?
      TypedArray.new(item_class).concat(super)
    else
      super
    end
  end

  def select(&block)
    if block_given?
      TypedArray.new(item_class).concat(super)
    else
      super
    end
  end

  def values_at(*args)
    TypedArray.new(item_class).concat(super)
  end

  def reject(&block)
    if block_given?
      TypedArray.new(item_class).concat(super)
    else
      super
    end
  end

  def replace(items)
    validate_assigned_items(items)
    super
  end

  def fill(*args, &block)
    if block_given?
      super(*args) do |index|
        value = block.call(index)
        validate_assigned_items([value])
        value
      end
    else
      validate_assigned_items([args.first])
      super
    end
  end

  def slice(*args)
    copy_item_class(super)
  end

  def slice!(*args)
    copy_item_class(super)
  end

  def +(items)
    validate_assigned_items(items)
    TypedArray.new(item_class).concat(super)
  end

  def *(*args)
    copy_item_class(super)
  end

  def -(items)
    TypedArray.new(item_class).concat(super)
  end

  def &(items)
    TypedArray.new(item_class).concat(super)
  end

  def |(items)
    if items.is_a?(TypedArray) && items.item_class == item_class
      TypedArray.new(item_class).concat(super)
    else
      super
    end
  end

  def uniq(&block)
    copy_item_class(super)
  end

  def compact
    TypedArray.new(item_class).concat(super)
  end

  def shuffle(*args)
    TypedArray.new(item_class).concat(super)
  end

  def sample(*args)
    if args.size > 0 && !args.first.is_a?(Hash)
      TypedArray.new(item_class).concat(super)
    else
      super
    end
  end

  def product(*args)
    if args.all? { |items| items.is_a?(TypedArray) && items.item_class == item_class }
      super.map { |items| TypedArray.new(item_class).concat(items) }
    else
      super
    end
  end

  def take(*args)
    TypedArray.new(item_class).concat(super)
  end

  def take_while(&block)
    if block_given?
      TypedArray.new(item_class).concat(super)
    else
      super
    end
  end

  def drop(*args)
    TypedArray.new(item_class).concat(super)
  end

  def drop_while(&block)
    if block_given?
      TypedArray.new(item_class).concat(super)
    else
      super
    end
  end

  private

  def validate_assigned_items(items)
    unless items.all? { |item| item.nil? || item.class == item_class }
      raise ArgumentError, "assigned item(s) should be of the type #{item_class}"
    end
  end

  def copy_item_class(typed_array)
    typed_array.instance_variable_set(:@item_class, item_class) if typed_array.is_a? TypedArray
    typed_array
  end

end
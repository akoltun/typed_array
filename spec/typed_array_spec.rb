RSpec.describe TypedArray do
  class TestTypedArrayItem
    attr_accessor :test
  end

  class TestTypedArrayWrongItem
    attr_accessor :wrong
  end

  it 'requires a type to create an array' do
    expect { TypedArray.new }.to raise_error ArgumentError, 'wrong number of arguments (0 for 1+)'
  end

  [1, 'abc', :abc, 1.1, { a: 1 }, [1, 'a', :b], Time.now, TestTypedArrayItem.new].each do |item|
    context "Array of #{item.class.name}" do
      let(:typed_array) { TypedArray[item] }

      it "creates array of type #{item.class.name}" do
        expect(TypedArray.new(item.class).item_class).to eq item.class
      end

      context '#[]' do
        it 'with all items of the same type creates TypedArray' do
          expect(TypedArray[item, item].item_class).to eq item.class
        end

        it 'with items of different type raises error' do
          expect { TypedArray[item, TestTypedArrayWrongItem.new] }.to raise_error ArgumentError, 'all arguments should be of the same type'
        end

        it 'allows nil items' do
          expect(TypedArray[nil, item].item_class).to eq item.class
        end

        it "doesn't allows all items to be nil" do
          expect { TypedArray[nil, nil] }.to raise_error ArgumentError, "[] constructor requires at least one non-nil element"
        end
      end

      context ':==' do
        it 'returns true if both arrays are TypedArray and have the same elements' do
          expect(TypedArray[item, nil] == TypedArray[item, nil]).to be_truthy
        end

        it 'returns true if both arrays are TypedArray without elements and have the same item class' do
          expect(TypedArray.new(item.class) == TypedArray.new(item.class)).to be_truthy
        end

        it 'returns false if compared array is not a TypedArray even if it has the same elements' do
          expect(TypedArray[item, nil] == [item, nil]).to be_truthy
        end

        it 'returns false if both arrays are TypedArray but contain different elements' do
          expect(TypedArray[item, nil] == TypedArray[item]).to be_falsey
        end

        it 'returns false if both arrays are TypedArray without elements but have different item classes' do
          expect(TypedArray.new(item.class) == TypedArray.new(TestTypedArrayWrongItem.new)).to be_falsey
        end
      end

      context ':eql' do
        it 'returns true if both arrays are TypedArray and have the same elements' do
          expect(TypedArray[item, nil].eql?(TypedArray[item, nil])).to be_truthy
        end

        it 'returns true if both arrays are TypedArray without elements and have the same item class' do
          expect(TypedArray.new(item.class).eql?(TypedArray.new(item.class))).to be_truthy
        end

        it 'returns false if compared array is not a TypedArray even if it has the same elements' do
          expect(TypedArray[item, nil].eql?([item, nil])).to be_falsey
        end

        it 'returns false if both arrays are TypedArray but contain different elements' do
          expect(TypedArray[item, nil].eql?(TypedArray[item])).to be_falsey
        end

        it 'returns false if both arrays are TypedArray without elements but have different item classes' do
          expect(TypedArray.new(item.class).eql?(TypedArray.new(TestTypedArrayWrongItem.new))).to be_falsey
        end
      end

      context ':[]' do
        it '[index] returns indexed item' do
          expect(typed_array[0]).to eql item
          expect(typed_array).to eq TypedArray[item]
        end

        it '[start, length] returns TypedArray' do
          expect(typed_array[0, 1]).to be_a TypedArray
          expect(typed_array[0, 1]).to eq TypedArray[item]
          expect(typed_array).to eq TypedArray[item]
        end

        it '[range] returns TypedArray' do
          expect(typed_array[0..-1]).to be_a TypedArray
          expect(typed_array[0..-1]).to eq TypedArray[item]
          expect(typed_array).to eq TypedArray[item]
        end
      end

      context ':[]=' do
        it 'assigns an item of the same type as TypedArray item' do
          expect(typed_array[2] = item).to eql item
          expect(typed_array).to eq TypedArray[item, nil, item]
          expect(typed_array).to be_a TypedArray
        end

        it 'raises when assign item of different type' do
          expect { typed_array[2] = TestTypedArrayWrongItem.new }.to raise_error ArgumentError, "assigned item(s) should be of the type #{item.class}"
        end

        it 'assigns an array of items of the same type as TypedArray item' do
          expect(typed_array[1, 2] = [item, nil]).to eql [item, nil]
          expect(typed_array).to eq TypedArray[item, item, nil]
          expect(typed_array).to be_a TypedArray
        end

        it 'raises when assign array of items of different type' do
          expect { typed_array[1, 2] = [item, nil, TestTypedArrayWrongItem.new] }.to raise_error ArgumentError, "assigned item(s) should be of the type #{item.class}"
        end

        it 'assigns an array of items of the same type as TypedArray item' do
          expect(typed_array[1..2] = [item, nil]).to eql [item, nil]
          expect(typed_array).to eq TypedArray[item, item, nil]
          expect(typed_array).to be_a TypedArray
        end

        it 'raises when assign array of items of different type' do
          expect { typed_array[1..2] = [item, nil, TestTypedArrayWrongItem.new] }.to raise_error ArgumentError, "assigned item(s) should be of the type #{item.class}"
        end
      end

      context ':concat' do
        it 'adds items of the same type as TypedArray item to the end of TypedArray' do
          expect(typed_array.concat([nil, item])).to eql(typed_array).and be_a TypedArray
          expect(typed_array).to eq TypedArray[item, nil, item]
          expect(typed_array).to be_a TypedArray
        end

        it 'raises when add items contain at least one item of another type' do
          expect { TypedArray[item].concat([item, nil, TestTypedArrayWrongItem.new]) }.to raise_error ArgumentError, "assigned item(s) should be of the type #{item.class}"
        end

        it 'allows to concat only nil items' do
          expect(typed_array.concat([nil, nil])).to eql(typed_array).and be_a TypedArray
          expect(typed_array).to eq TypedArray[item, nil, nil]
          expect(typed_array).to be_a TypedArray
        end
      end

      context ':<<' do
        it 'adds item of the same type as TypedArray item to the end of TypedArray' do
          expect(typed_array << item).to eql(typed_array).and be_a TypedArray
          expect(typed_array).to eq TypedArray[item, item]
          expect(typed_array).to be_a TypedArray
        end

        it 'adds nil to the end of TypedArray' do
          expect(typed_array << nil).to eql(typed_array).and be_a TypedArray
          expect(typed_array).to eq TypedArray[item, nil]
          expect(typed_array).to be_a TypedArray
        end

        it 'adds chain of items of the same type as TypedArray item to the end of TypedArray' do
          expect(typed_array << item << item << nil << item).to eql(typed_array).and be_a TypedArray
          expect(typed_array).to eq TypedArray[item, item, item, nil, item]
          expect(typed_array).to be_a TypedArray
        end

        it 'raises when add item of another type' do
          expect { typed_array << TestTypedArrayWrongItem.new }.to raise_error ArgumentError, "assigned item(s) should be of the type #{item.class}"
        end

        it 'raises when at least of the items in the chain is of another type' do
          expect { typed_array << item << nil << TestTypedArrayWrongItem.new << item }.to raise_error ArgumentError, "assigned item(s) should be of the type #{item.class}"
        end
      end

      context ':push' do
        it 'adds items of the same type as TypedArray item or nil to the end of TypedArray' do
          expect(typed_array.push(item, nil, item)).to eql(typed_array).and be_a TypedArray
          expect(typed_array).to eq TypedArray[item, item, nil, item]
          expect(typed_array).to be_a TypedArray
        end

        it 'raises when add item of another type' do
          expect { typed_array.push(item, nil, TestTypedArrayWrongItem.new) }.to raise_error ArgumentError, "assigned item(s) should be of the type #{item.class}"
        end
      end

      context ':pop' do
        let(:typed_array) { TypedArray[item, nil, item] }

        it 'removes last element from TypedArray and returns it' do
          expect(typed_array.pop).to eq item
          expect(typed_array).to eq TypedArray[item, nil]
          expect(typed_array).to be_a TypedArray
        end

        it 'removes last elements from TypedArray and returns them' do
          expect(typed_array.pop(2)).to eq(TypedArray[nil, item]).and be_a(TypedArray)
          expect(typed_array).to eq TypedArray[item]
          expect(typed_array).to be_a TypedArray
        end
      end

      context ':shift' do
        let(:typed_array) { TypedArray[item, nil, item] }

        it 'removes first element from TypedArray and returns it' do
          expect(typed_array.shift).to eq item
          expect(typed_array).to eq TypedArray[nil, item]
          expect(typed_array).to be_a TypedArray
        end

        it 'removes first elements from TypedArray and returns them' do
          expect(typed_array.shift(2)).to eq(TypedArray[item, nil]).and be_a(TypedArray)
          expect(typed_array).to eq TypedArray[item]
          expect(typed_array).to be_a TypedArray
        end
      end

      context ':unshift' do
        it 'adds items of the same type as TypedArray item or nil at the beginning of TypedArray' do
          expect(typed_array.unshift(item, nil, item)).to eql(typed_array).and be_a TypedArray
          expect(typed_array).to eq TypedArray[item, nil, item, item]
          expect(typed_array).to be_a TypedArray
        end

        it 'raises when add item of another type' do
          expect { typed_array.unshift(item, nil, TestTypedArrayWrongItem.new) }.to raise_error ArgumentError, "assigned item(s) should be of the type #{item.class}"
        end
      end

      context ':insert' do
        let(:typed_array) { TypedArray[item, nil, item] }

        it 'inserts items of the same type as TypedArray item or nil to the index position of TypedArray' do
          expect(typed_array.insert(2, nil, item)).to eql(typed_array).and be_a TypedArray
          expect(typed_array).to eq TypedArray[item, nil, nil, item, item]
          expect(typed_array).to be_a TypedArray
        end

        it 'raises when insert item of another type' do
          expect { typed_array.insert(2, item, nil, TestTypedArrayWrongItem.new) }.to raise_error ArgumentError, "assigned item(s) should be of the type #{item.class}"
        end
      end

      context ':reverse' do
        let(:typed_array) { TypedArray[item, nil]}

        it 'returns TypedArray with items in reverse order' do
          expect(typed_array.reverse).to be_a TypedArray
          expect(typed_array.reverse).to eq TypedArray[nil, item]
        end
      end

      context ':reverse!' do
        let(:typed_array) { TypedArray[item, nil]}

        it 'reverse the order of items in TypedArray and returns it' do
          expect(typed_array.reverse!).to eql(typed_array).and be_a TypedArray
          expect(typed_array).to eq TypedArray[nil, item]
          expect(typed_array).to be_a TypedArray
        end
      end

      context ':rotate' do
        let(:typed_array) { TypedArray[item, item, nil] }

        it 'returns rotated TypedArray' do
          expect(typed_array.rotate(1)).to be_a TypedArray
          expect(typed_array.rotate(1)).to eq TypedArray[item, nil, item]
        end
      end

      context ':rotate!' do
        let(:typed_array) { TypedArray[item, item, nil] }

        it 'rotates items in TypedArray and returns ' do
          expect(typed_array.rotate!(1)).to eql(typed_array).and be_a TypedArray
          expect(typed_array).to eq TypedArray[item, nil, item]
          expect(typed_array).to be_a TypedArray
        end
      end

      context ':sort' do
        let(:typed_array) { TypedArray[item, item] }

        it 'sorts items and returns TypedArray' do
          expect(typed_array.sort).to be_a TypedArray
        end

        it 'sorts items and returns TypedArray' do
          expect(typed_array.sort { |a, b| a <=> b }).to be_a TypedArray
        end
      end

      context ':sort!' do
        let(:typed_array) { TypedArray[item, item] }

        it 'sorts items and returns TypedArray' do
          expect(typed_array.sort!).to eq typed_array
          expect(typed_array).to be_a TypedArray
        end

        it 'sorts items and returns TypedArray' do
          expect(typed_array.sort! { |a, b| a <=> b }).to eql(typed_array).and be_a TypedArray
          expect(typed_array).to be_a TypedArray
        end
      end

      context ':sort_by' do
        let(:typed_array) { TypedArray[item, item] }

        it 'sorts items and returns TypedArray' do
          expect(typed_array.sort_by { |a| a }).to be_a TypedArray
        end

        it 'returns Enumerator' do
          expect(typed_array.sort_by).to be_a Enumerator
        end
      end

      context ':sort_by!' do
        let(:typed_array) { TypedArray[item, item] }

        it 'sorts items and returns TypedArray' do
          expect(typed_array.sort_by! { |a| a }).to eql(typed_array).and be_a TypedArray
          expect(typed_array).to be_a TypedArray
        end

        it 'returns Enumerator' do
          expect(typed_array.sort_by!).to be_a Enumerator
        end
      end

      context ':select' do
        let(:typed_array) { TypedArray[item, item] }

        it 'returns TypedArray' do
          expect(typed_array.select { |a| true }).to be_a TypedArray
          expect(typed_array.select { |a| true }).to eq TypedArray[item, item]
        end

        it 'returns Enumerator' do
          expect(typed_array.select).to be_a Enumerator
        end
      end

      context ':select!' do
        let(:typed_array) { TypedArray[item, item] }

        it 'returns TypedArray' do
          expect(typed_array.select! { |a| false }).to eql(typed_array).and be_a TypedArray
          expect(typed_array).to be_a TypedArray
        end

        it 'returns nil' do
          expect(typed_array.select! { |a| true }).to be_nil
          expect(typed_array).to be_a TypedArray
          expect(typed_array).to eq TypedArray[item, item]
        end

        it 'returns Enumerator' do
          expect(typed_array.select!).to be_a Enumerator
        end
      end

      context ':keep_if' do
        let(:typed_array) { TypedArray[item, item] }

        it 'returns TypedArray' do
          expect(typed_array.keep_if { |a| true }).to be_a TypedArray
          expect(typed_array.keep_if { |a| true }).to eq TypedArray[item, item]
        end
      end

      context ':values_at' do
        let(:typed_array) { TypedArray[item, nil, item] }
        it 'returns TypedArray' do
          expect(typed_array.values_at(1, 2)).to be_a TypedArray
          expect(typed_array.values_at(1, 2)).to eq TypedArray[nil, item]
        end
      end

      context ':delete' do
        it 'deletes item' do
          typed_array.delete(item)
          expect(typed_array).to eq TypedArray.new(item.class)
          expect(typed_array).to be_a TypedArray
        end
      end

      context ':delete_at' do
        it 'deletes item' do
          typed_array.delete_at(0)
          expect(typed_array).to eq TypedArray.new(item.class)
          expect(typed_array).to be_a TypedArray
        end
      end

      context ':delete_if' do
        it 'returns TypedArray without deleted item' do
          expect(typed_array.delete_if { |a| true }).to eq(TypedArray.new(item.class)).and be_a TypedArray
          expect(typed_array).to eq TypedArray.new(item.class)
        end

        it 'returns Enumerator' do
          expect(typed_array.delete_if).to be_a Enumerator
        end
      end

      context ':reject' do
        it 'returns TypedArray without rejected item' do
          expect(typed_array.reject { |a| true }).to eq TypedArray.new(item.class)
          expect(typed_array.reject { |a| true }).to be_a TypedArray
          expect(typed_array).to eq TypedArray[item]
        end

        it 'returns Enumerator' do
          expect(typed_array.sort_by).to be_a Enumerator
        end
      end

      context ':reject!' do
        it 'deletes rejected item from TypedArray' do
          typed_array.reject! { |a| true }
          expect(typed_array).to eq TypedArray.new(item.class)
          expect(typed_array).to be_a TypedArray
        end
      end

      context ':replace' do
        it 'with all items of the same type as the TypedArray it creates a new one' do
          expect(typed_array.replace([item, item])).to eq TypedArray[item, item]
          expect(typed_array.replace([item, item]).item_class).to eq item.class
        end

        it 'with items of type different from the one of the TypedArray it raises error' do
          expect { typed_array.replace([item, TestTypedArrayWrongItem.new]) }.to raise_error ArgumentError, "assigned item(s) should be of the type #{item.class.name}"
        end

        it 'allows to replace by only nil items' do
          expect(typed_array.replace([nil, nil]).item_class).to eq item.class
        end
      end

      context ':clear' do
        it 'deletes all items' do
          expect(typed_array.clear).to eql(typed_array).and be_a TypedArray
          expect(typed_array).to be_a TypedArray
          expect(typed_array).to eq TypedArray.new(item.class)
        end
      end

      context ':fill' do
        it 'fills array with nil' do
          expect(typed_array.fill(nil)).to eql(typed_array).and be_a TypedArray
          expect(typed_array).to be_a TypedArray
          expect(typed_array).to eq (TypedArray.new(item.class) << nil)
        end

        it 'fills array with the item of the same type as TypedArray' do
          (typed_array = TypedArray.new(item.class)) << nil
          expect(typed_array.fill(item)).to eql(typed_array).and be_a TypedArray
          expect(typed_array).to be_a TypedArray
          expect(typed_array).to eq TypedArray[item]
        end

        it 'raises error when called with the item of another type' do
          expect{ typed_array.fill(TestTypedArrayWrongItem.new) }.to raise_error ArgumentError, "assigned item(s) should be of the type #{item.class}"
        end
      end

      context ':slice' do
        it 'slice(index) returns indexed item' do
          expect(typed_array.slice(0)).to eql item
          expect(typed_array).to eq TypedArray[item]
        end

        it 'slice(start, length) returns TypedArray' do
          expect(typed_array.slice(0, 1)).to be_a TypedArray
          expect(typed_array.slice(0, 1)).to eq TypedArray[item]
          expect(typed_array).to eq TypedArray[item]
        end

        it 'slice(range) returns TypedArray' do
          expect(typed_array.slice(0..-1)).to be_a TypedArray
          expect(typed_array.slice(0..-1)).to eq TypedArray[item]
          expect(typed_array).to eq TypedArray[item]
        end
      end

      context ':slice!' do
        it 'slice!(index) returns indexed item' do
          expect(typed_array.slice!(0)).to eql item
          expect(typed_array).to eq TypedArray.new(item.class)
        end

        it 'slice!(start, length) returns TypedArray' do
          expect(typed_array.slice!(0, 1)).to eq(TypedArray[item]).and be_a TypedArray
          expect(typed_array).to eq TypedArray.new(item.class)
        end

        it 'slice!(range) returns TypedArray' do
          expect(typed_array.slice!(0..-1)).to eq(TypedArray[item]).and be_a TypedArray
          expect(typed_array).to eq TypedArray.new(item.class)
        end
      end

      context ':+' do
        it 'adds items of the same type as TypedArray item to the end of TypedArray' do
          expect(typed_array + [nil, item]).to be_a TypedArray
          expect(typed_array + [nil, item]).to eq TypedArray[item, nil, item]
        end

        it 'raises when add items contain at least one item of another type' do
          expect { TypedArray[item] + [item, nil, TestTypedArrayWrongItem.new] }.to raise_error ArgumentError, "assigned item(s) should be of the type #{item.class}"
        end

        it 'allows to add only nil items' do
          expect(typed_array + [nil, nil]).to be_a TypedArray
          expect(typed_array + [nil, nil]).to eq TypedArray[item, nil, nil]
        end
      end

      context ':+=' do
        it 'adds items of the same type as TypedArray item to the end of TypedArray' do
          typed_array = TypedArray[item]
          expect(typed_array += [nil, item]).to eql(typed_array).and be_a(TypedArray)
          expect(typed_array).to eq TypedArray[item, nil, item]
          expect(typed_array).to be_a TypedArray
        end

        it 'raises when add items contain at least one item of another type' do
          expect { TypedArray[item] += [item, nil, TestTypedArrayWrongItem.new] }.to raise_error ArgumentError, "assigned item(s) should be of the type #{item.class}"
        end

        it 'allows to concat only nil items' do
          typed_array = TypedArray[item]
          expect(typed_array += [nil, nil]).to eql(typed_array).and be_a TypedArray
          expect(typed_array).to eq TypedArray[item, nil, nil]
          expect(typed_array).to be_a TypedArray
        end
      end

      context ':*' do
        it 'multiplies TypedArray' do
          expect(typed_array * 3).to be_a TypedArray
          expect(typed_array * 3).to eq TypedArray[item, item, item]
        end
      end

      context ':-' do
        let(:typed_array) { TypedArray[item, item, nil, item] }
        it 'removes items' do
          expect(typed_array - [item]).to be_a TypedArray
          expect((typed_array - [item]).item_class).to eq item.class
          expect(typed_array - [item]).to eq TypedArray.new(item.class).push(nil)
        end
      end

      context ':&' do
        let(:typed_array) { TypedArray[item, item, nil, item] }
        it 'intersected TypedArray' do
          expect(typed_array & [nil]).to be_a TypedArray
          expect((typed_array & [nil]).item_class).to eq item.class
          expect(typed_array & [nil]).to eq TypedArray.new(item.class).push(nil)
        end
      end

      context ':|' do
        let(:typed_array) { TypedArray[item, item, item] }

        it 'returns TypedArray if both are TypedArray of the same type' do
          expect(typed_array | TypedArray[nil, item]).to be_a TypedArray
          expect((typed_array | TypedArray[nil, item]).item_class).to eq item.class
          expect(typed_array | TypedArray[nil, item]).to eq TypedArray[item, nil]
        end

        it 'returns Array if at least one argument is not a TypedArray' do
          expect(typed_array | [nil, item]).to be_a Array
          expect(typed_array | [nil, item]).not_to be_a TypedArray
          expect([nil, item] | typed_array).to be_a Array
          expect([nil, item] | typed_array).not_to be_a TypedArray
        end

        it 'returns Array if both are TypedArray but of different types' do
          expect(typed_array | TypedArray[TestTypedArrayWrongItem.new]).to be_a Array
          expect(typed_array | TypedArray[TestTypedArrayWrongItem.new]).not_to be_a TypedArray
        end
      end

      context ':uniq' do
        let(:typed_array) { TypedArray[item, item, item] }

        it 'returns uniqied TypedArray' do
          expect(typed_array.uniq).to be_a TypedArray
          expect(typed_array.uniq).to eq TypedArray[item]
        end

        it 'returns uniqied TypedArray' do
          expect(typed_array.uniq { |a| a }).to be_a TypedArray
          expect(typed_array.uniq { |a| a }).to eq TypedArray[item]
        end
      end

      context ':uniq!' do
        let(:typed_array) { TypedArray[item, item, item] }

        it 'returns uniqued TypedArray' do
          expect(typed_array.uniq!).to eql(typed_array).and be_a TypedArray
          expect(typed_array).to be_a TypedArray
          expect(typed_array).to eq TypedArray[item]
        end

        it 'returns uniqued TypedArray' do
          expect(typed_array.uniq! { |a| a }).to eql(typed_array).and be_a TypedArray
          expect(typed_array).to be_a TypedArray
          expect(typed_array).to eq TypedArray[item]
        end
      end

      context ':compact' do
        let(:typed_array) { TypedArray[item, nil, item] }

        it 'returns compacted TypedArray' do
          expect(typed_array.compact).to be_a TypedArray
          expect(typed_array.compact).to eq TypedArray[item, item]
        end
      end

      context ':compact!' do
        let(:typed_array) { TypedArray[item, nil, item] }

        it 'returns compacted TypedArray' do
          expect(typed_array.compact!).to eql(typed_array).and be_a TypedArray
          expect(typed_array).to be_a TypedArray
          expect(typed_array).to eq TypedArray[item, item]
        end
      end

      context ':shuffle' do
        let(:typed_array) { TypedArray[item, nil, item] }

        it 'returns shuffled TypedArray' do
          expect(typed_array.shuffle).to be_a TypedArray
          expect(typed_array.shuffle.item_class).to eq item.class
          expect(typed_array.shuffle.size).to eq 3
        end
      end

      context ':shuffle!' do
        let(:typed_array) { TypedArray[item, nil, item] }

        it 'returns shuffled TypedArray' do
          expect(typed_array.shuffle!).to eql(typed_array).and be_a(TypedArray)
          expect(typed_array.item_class).to eq item.class
          expect(typed_array.size).to eq 3
        end
      end

      context ':sample' do
        let(:typed_array) { TypedArray[item, nil, item] }

        it 'returns an element' do
          expect(typed_array.sample).to be_a(item.class).or be_nil
        end

        it 'returns TypedArray' do
          expect(typed_array.sample(2)).to be_a TypedArray
          expect(typed_array.sample(2).item_class).to eq item.class
        end
      end

      context ':permutation' do
        let(:typed_array) { TypedArray[item, nil, item] }

        it 'returns array of TypedArrays' do
          expect(typed_array.permutation { |a| a } ).to eql(typed_array).and be_a TypedArray
        end
      end

      context ':combination' do
        let(:typed_array) { TypedArray[item, nil, item] }

        it 'returns array of TypedArrays' do
          expect(typed_array.combination(2) { |a| a } ).to eql(typed_array).and be_a TypedArray
        end
      end

      context ':repeated_permutation' do
        let(:typed_array) { TypedArray[item, nil, item] }

        it 'returns array of TypedArrays' do
          expect(typed_array.repeated_permutation(2) { |a| a } ).to eql(typed_array).and be_a TypedArray
        end
      end

      context ':repeated_combination' do
        let(:typed_array) { TypedArray[item, nil, item] }

        it 'returns array of TypedArrays' do
          expect(typed_array.repeated_combination(2) { |a| a } ).to eql(typed_array).and be_a TypedArray
        end
      end

      context ':product' do
        let(:typed_array) { TypedArray[item, nil, item] }

        it 'returns original TypedArray when called with wblock' do
          expect(typed_array.product([1, 2]) { |a| a }).to eql(typed_array).and be_a TypedArray
          expect(typed_array.product([1, 2]) { |a| a }.item_class).to eq item.class
        end

        it 'returns an array of TypedArrays when called with TypedArrays of the same type' do
          expect(typed_array.product(TypedArray[item, nil], TypedArray[nil, item])).to be_a Array
          typed_array.product(TypedArray[item, nil], TypedArray[nil, item]).each do |a|
            expect(a).to be_a TypedArray
            expect(a.item_class).to eq item.class
          end
        end

        it 'returns an array of Arrays when called with TypedArrays of different types' do
          expect(typed_array.product(TypedArray[item, nil], TypedArray[nil, TestTypedArrayWrongItem.new])).to be_a Array
          typed_array.product(TypedArray[item, nil], TypedArray[nil, TestTypedArrayWrongItem.new]).each do |a|
            expect(a).to be_a Array
          end
        end

        it 'returns an array of Arrays when called with non-TypedArray arguments' do
          expect(typed_array.product(TypedArray[item, nil], [nil, item])).to be_a Array
          typed_array.product(TypedArray[item, nil], [nil, item]).each do |a|
            expect(a).to be_a Array
          end
        end
      end

      context ':take' do
        let(:typed_array) { TypedArray[item, nil, item] }

        it 'returns TypedArray' do
          expect(typed_array.take(2)).to be_a TypedArray
          expect(typed_array.take(2)).to eq TypedArray[item, nil]
        end
      end

      context ':take_while' do
        let(:typed_array) { TypedArray[item, nil, item] }

        it 'returns TypedArray' do
          expect(typed_array.take_while { |a| a.respond_to?(:empty?) ? !a.empty? : a }).to be_a TypedArray
          expect(typed_array.take_while { |a| a.respond_to?(:empty?) ? !a.empty? : a }).to eq TypedArray[item]
        end

        it 'returns Enumerator' do
          expect(typed_array.take_while).to be_a Enumerator
        end
      end

      context ':drop' do
        let(:typed_array) { TypedArray[item, nil, item] }

        it 'returns TypedArray' do
          expect(typed_array.drop(1)).to be_a TypedArray
          expect(typed_array.drop(1)).to eq TypedArray[nil, item]
        end
      end

      context ':drop_while' do
        let(:typed_array) { TypedArray[item, nil, item] }

        it 'returns TypedArray' do
          expect(typed_array.drop_while { |a| a.respond_to?(:empty?) ? !a.empty? : a }).to be_a TypedArray
          expect(typed_array.drop_while { |a| a.respond_to?(:empty?) ? !a.empty? : a }).to eq TypedArray[nil, item]
        end
      end
    end
  end
end

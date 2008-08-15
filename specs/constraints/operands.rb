require File.dirname(__FILE__) + '/../spec_helper'

describe 'operand', :shared => true do
  it 'should not shadow method missing' do
    lambda do
      @operand.does_not_exist
    end.should raise_error(NoMethodError)
  end
end

describe 'variable operand', :shared => true do
  it 'should fall back to the underlying variable' do
    lambda do 
      @operand.assigned?
    end.should_not raise_error
  end

  it_should_behave_like 'operand'
end

describe 'enum operand', :shared => true do
  it 'should fall back to the underlying enum' do
    lambda do 
      @operand[0]
    end.should_not raise_error
  end

  it_should_behave_like 'operand'
end

describe Gecode::Constraints::Operand do
  before do
    model = Gecode::Model.new
    @operand = Object.new
    class <<@operand
      include Gecode::Constraints::Operand
    end
  end

  it 'should raise error if #model is not defined' do
    lambda do
      @operand.model
    end.should raise_error(NotImplementedError)
  end

  it 'should raise error if #construct_receiver is not defined' do
    lambda do
      @operand.must
    end.should raise_error(NotImplementedError)
  end
end

describe Gecode::Constraints::Int::IntOperand do
  before do
    model = Gecode::Model.new
    @operand, _ = general_int_operand(model)
  end

  it_should_behave_like 'variable operand'
end

describe Gecode::Constraints::Int::ShortCircuitEqualityOperand, ' (not subclassed)' do
  before do
    @model = Gecode::Model.new
    @operand = Gecode::Constraints::Int::ShortCircuitEqualityOperand.new(@model)
  end

  it 'should raise error if #constrain_equal is called' do
    lambda do
      @operand.to_int_var
      @model.solve!
    end.should raise_error(NotImplementedError)
  end
end

describe Gecode::Constraints::Int::ShortCircuitRelationsOperand, ' (not subclassed)' do
  before do
    @model = Gecode::Model.new
    @operand = Gecode::Constraints::Int::ShortCircuitRelationsOperand.new(@model)
  end

  it 'should raise error if #constrain_equal is called' do
    lambda do
      @operand.to_int_var
      @model.solve!
    end.should raise_error(NotImplementedError)
  end
end

describe Gecode::Constraints::IntEnum::IntEnumOperand do
  before do
    model = Gecode::Model.new
    @operand, _ = general_int_enum_operand(model)
  end

  it_should_behave_like 'enum operand'
end

describe Gecode::Constraints::Bool::BoolOperand do
  before do
    model = Gecode::Model.new
    @operand, _ = general_bool_operand(model)
  end

  it_should_behave_like 'variable operand'
end

describe Gecode::Constraints::Bool::ShortCircuitEqualityOperand, ' (not subclassed)' do
  before do
    @model = Gecode::Model.new
    @operand = Gecode::Constraints::Bool::ShortCircuitEqualityOperand.new(@model)
  end

  it 'should raise error if #constrain_equal is called' do
    lambda do
      @operand.to_bool_var
      @model.solve!
    end.should raise_error(NotImplementedError)
  end
end

describe Gecode::Constraints::BoolEnum::BoolEnumOperand do
  before do
    model = Gecode::Model.new
    @operand, _ = general_bool_enum_operand(model)
  end

  it_should_behave_like 'enum operand'
end

describe Gecode::Constraints::Set::SetOperand do
  before do
    model = Gecode::Model.new
    @operand, _ = general_set_operand(model)
  end

  it_should_behave_like 'variable operand'
end

describe Gecode::Constraints::Set::ShortCircuitEqualityOperand, ' (not subclassed)' do
  before do
    @model = Gecode::Model.new
    @operand = Gecode::Constraints::Set::ShortCircuitEqualityOperand.new(@model)
  end

  it 'should raise error if #constrain_equal is called' do
    lambda do
      @operand.to_set_var
      @model.solve!
    end.should raise_error(NotImplementedError)
  end
end

describe Gecode::Constraints::Set::ShortCircuitRelationsOperand, ' (not subclassed)' do
  before do
    @model = Gecode::Model.new
    @operand = Gecode::Constraints::Set::ShortCircuitRelationsOperand.new(@model)
  end

  it 'should raise error if #constrain_equal is called' do
    lambda do
      @operand.to_set_var
      @model.solve!
    end.should raise_error(NotImplementedError)
  end
end

describe Gecode::Constraints::SelectedSet::SelectedSetOperand do
  before do
    model = Gecode::Model.new
    @operand, ops = general_selected_set_operand(model)
    @enum, @set = ops
  end

  it 'should raise error if set enum operand is not given' do
    lambda do
      Gecode::Constraints::SelectedSet::SelectedSetOperand.new(:foo, @set)
    end.should raise_error(TypeError)
  end

  it 'should raise error if set operand is not given' do
    lambda do
      Gecode::Constraints::SelectedSet::SelectedSetOperand.new(@enum, :foo)
    end.should raise_error(TypeError)
  end

  it_should_behave_like 'operand'
end

describe Gecode::Constraints::SetElements::SetElementsOperand do
  before do
    model = Gecode::Model.new
    @operand, @set = general_set_elements_operand(model)
  end

  it 'should raise error if set operand is not given' do
    lambda do
      Gecode::Constraints::SetElements::SetElementsOperand.new(:foo)
    end.should raise_error(TypeError)
  end

  it_should_behave_like 'operand'
end

describe Gecode::Constraints::SetEnum::SetEnumOperand do
  before do
    model = Gecode::Model.new
    @operand, _ = general_set_enum_operand(model)
  end

  it_should_behave_like 'enum operand'
end

describe Gecode::Constraints::FixnumEnum::FixnumEnumOperand do
  before do
    model = Gecode::Model.new
    @operand, _ = general_fixnum_enum_operand(model)
  end

  it 'should raise error if constraint receiver is called' do
    lambda do
      @operand.must
    end.should raise_error(NotImplementedError)
  end

  it_should_behave_like 'enum operand'
end
